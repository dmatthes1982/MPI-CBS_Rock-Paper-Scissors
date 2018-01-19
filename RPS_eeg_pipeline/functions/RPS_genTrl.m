function [ trl ] = RPS_genTrl( cfg, data )
% RPS_GENTRL is a function which generates a trl fragmentation of 
% continuous data for subsequent artifact detection. This function could be 
% used when the actual segmentation of the data is not needed for the 
% subsequent steps (i.e. in line with the estimation of eye artifacts)
%
% Use as
%   [ trl ] = RPS_genTrl( cfg, data )
%
% where the input data have to be the result from RPS_CONCATDATA
%
% The configuration options are 
%   cfg.length  = trial length in milliseconds (default: 200, choose even number)
%   cfg.overlap = amount of overlapping in percentage (default: 0, permitted values: 0 or 50)
%
% This function requires the fieldtrip toolbox
%
% See also RPS_CONCATDATA

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
trlDuration   = ft_getopt(cfg, 'length', 200);
overlap       = ft_getopt(cfg, 'overlap', 0);

trl.FP = generateTrlfragmentation(data.FP, trlDuration, overlap);
trl.PD = generateTrlfragmentation(data.PD, trlDuration, overlap);
trl.PS = generateTrlfragmentation(data.PS, trlDuration, overlap);
trl.C  = generateTrlfragmentation(data.C, trlDuration, overlap);

end

% -------------------------------------------------------------------------
% SUBFUNCTION for trl generation
% -------------------------------------------------------------------------
function trlDef = generateTrlfragmentation( dataCond, tdur, overl  )

if mod(tdur, 2)
  error('Choose even number for trial leght!');
else
  trlLength = dataCond.part1.fsample * tdur / 1000;
end

numOfOrgTrials  = size(dataCond.part1.trialinfo, 1);
numOfTrials     = zeros(1, numOfOrgTrials);
trialinfo       = dataCond.part1.trialinfo;
sampleinfo      = dataCond.part1.sampleinfo;

switch overl
  case 0
    for i = 1:numOfOrgTrials
      numOfTrials(i) = fix((sampleinfo(i,2) - sampleinfo(i,1) +1) ...
                    / trlLength);
                    
    end
  case 50
    for i = 1:numOfOrgTrials
      numOfTrials(i) = 2 * fix((sampleinfo(i,2) - sampleinfo(i,1) +1) ...
                    / trlLength) - 1;
                    
    end
  otherwise
    error('Currently there is only overlapping of 0 or 50% permitted');
end

numOfAllTrials = sum(numOfTrials);

% -------------------------------------------------------------------------
% Generate trial matrix
% -------------------------------------------------------------------------
trlDef       = zeros(numOfAllTrials, 4);
endsample = 0;

switch overl
  case 0
    for i = 1:numOfOrgTrials
      begsample = endsample + 1;
      endsample = begsample + numOfTrials(i) - 1;
      trlDef(begsample:endsample, 1) = sampleinfo(i,1):trlLength: ...
                                    (numOfTrials(i)-1) * trlLength + ...
                                    sampleinfo(i,1);
      trlDef(begsample:endsample, 3) = 0:trlLength: ...
                                    (numOfTrials(i)-1) * trlLength;
      trlDef(begsample:endsample, 2) = trlDef(begsample:endsample, 1) ... 
                                    + trlLength - 1;
      trlDef(begsample:endsample, 4) = trialinfo(i);
    end
  case 50
    for i = 1:numOfOrgTrials
      begsample = endsample + 1;
      endsample = begsample + numOfTrials(i) - 1;
      trlDef(begsample:endsample, 1) = sampleinfo(i,1):trlLength/2: ...
                                    (numOfTrials(i)-1) * (trlLength/2) + ...
                                    sampleinfo(i,1);
      trlDef(begsample:endsample, 3) = 0:trlLength/2: ...
                                    (numOfTrials(i)-1) * (trlLength/2);
      trlDef(begsample:endsample, 2) = trlDef(begsample:endsample, 1) ... 
                                    + trlLength - 1;
      trlDef(begsample:endsample, 4) = trialinfo(i);
    end
end

end

