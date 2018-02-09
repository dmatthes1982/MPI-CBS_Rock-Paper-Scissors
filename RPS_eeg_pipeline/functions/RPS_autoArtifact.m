function [ cfgAutoArt ] = RPS_autoArtifact( cfg, data )
% RPS_AUTOARTIFACT marks timeslots as an artifact in which the values of 
% specified channels exceeds a min-max level or a defined range.
%
% Use as
%   [ cfgAutoArt ] = RPS_autoArtifact(cfg, data)
%
% where data has to be a result of RPS_PREPROCESSING or RPS_CONCAT
%
% The configuration options are
%   cfg.channel = cell-array with channel labels (default: {'Cz', 'O1', 'O2'}))
%   cfg.continuous  = data is continuous ('yes' or 'no', default: 'no')
%   cfg.trl         = trial definition (always necessary, generate with RPS_GENTRL) 
%   cfg.method      = type of artifact detection (0: lower/upper limit, 1: range)
%   cfg.min         = lower limit in uV for cfg.method = 0 (default: -75) 
%   cfg.max         = upper limit in uV for cfg.method = 0 (default: 75)
%   cfg.range       = range in uV for cfg.method = 1 (default: 200)
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_GENTRL, RPS_PREPROCESSING, RPS_CONCATDATA, 
% FT_ARTIFACT_THRESHOLD

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
chan        = ft_getopt(cfg, 'channel', {'Cz', 'O1', 'O2'});
continuous  = ft_getopt(cfg, 'continuous', 'no');
trl         = ft_getopt(cfg, 'trl', []);
method      = ft_getopt(cfg, 'method', 0);

switch method
  case 0
    minVal    = ft_getopt(cfg, 'min', -75);
    maxVal    = ft_getopt(cfg, 'max', 75);
  case 1
    range     = ft_getopt(cfg, 'range', 200);
  otherwise
    error('Only 0: lower/upper limit or 1: range are supported methods.');
end

if isempty(cfg.trl)
  error('cfg.trl is missing. You can use JAI_genTrl to generate the trl matrix');
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/RPS_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Artifact detection settings
% -------------------------------------------------------------------------
ft_info off;

cfg                               = [];
cfg.continuous                    = continuous;
cfg.artfctdef.threshold.channel   = chan;                                   % specify channels of interest
cfg.artfctdef.threshold.bpfilter  = 'no';                                   % use no additional bandpass
if method == 0
  cfg.artfctdef.threshold.min     = minVal;                                 % minimum threshold
  cfg.artfctdef.threshold.max     = maxVal;                                 % maximum threshold
elseif method == 1
  cfg.artfctdef.threshold.range   = range;                                  % range
end
cfg.showcallinfo                  = 'no';

% -------------------------------------------------------------------------
% Estimate artifacts
% -------------------------------------------------------------------------
cfgTmp.part1 = [];                                                          % build output structure
cfgTmp.part2 = [];
cfgTmp.bad1Num = []; 
cfgTmp.bad2Num = [];
cfgTmp.trialsNum = [];

cfgAutoArt.FP = cfgTmp;                                                     % allocate one output structure for each condition
cfgAutoArt.FP.trialsNum = size(trl.FP, 1);                                  % set number of trials 
cfgAutoArt.PD = cfgTmp;
cfgAutoArt.PD.trialsNum = size(trl.PD, 1);
cfgAutoArt.PS = cfgTmp;
cfgAutoArt.PS.trialsNum = size(trl.PS, 1);
cfgAutoArt.C = cfgTmp;
cfgAutoArt.C.trialsNum = size(trl.C, 1);

for condition = 1:1:8
  switch condition
    case 1
      fprintf('Estimate artifacts in participant 1...\n');
      fprintf('Condition FreePlay...\n');
      dataTmp = data.FP.part1;
      cfg.trl = trl.FP;
    case 2
      fprintf('Condition PredDiff...\n');
      dataTmp = data.PD.part1;
      cfg.trl = trl.PD;
    case 3
      fprintf('Condition PredSame...\n');
      dataTmp = data.PS.part1;
      cfg.trl = trl.PS;
    case 4
      fprintf('Condition Control...\n');
      dataTmp = data.C.part1;
      cfg.trl = trl.C;
    case 5
      fprintf('Estimate artifacts in participant 2...\n');
      fprintf('Condition FreePlay...\n');
      dataTmp = data.FP.part2;
      cfg.trl = trl.FP;
    case 6
      fprintf('Condition PredDiff...\n');
      dataTmp = data.PD.part2;
      cfg.trl = trl.PD;
    case 7
      fprintf('Condition PredSame...\n');
      dataTmp = data.PS.part2;
      cfg.trl = trl.PS;
    case 8
      fprintf('Condition Control...\n');
      dataTmp = data.C.part2;
      cfg.trl = trl.C;
  end
  
  cfgTmp    = ft_artifact_threshold(cfg, dataTmp);
  cfgTmp    = keepfields(cfgTmp, {'artfctdef', 'showcallinfo'});
  badNum    = calcBadNum( cfgTmp.artfctdef.threshold );
  fprintf('%d segments of 1 second with artifacts detected!\n', badNum);
  
  throwWarning = 0;
  
  if condition < 5
    if badNum == sum(generalDefinitions.trialNum1sec{condition})
      throwWarning = 1;
    end 
  else
    if badNum == sum(generalDefinitions.trialNum1sec{condition - 4})
      throwWarning = 1;
    end 
  end
  
   if throwWarning == 1
    warning('All trials are marked as bad, it is recommended to recheck the channels quality!');
  end
  
  switch condition
    case 1
      cfgAutoArt.FP.part1       = cfgTmp;
      cfgAutoArt.FP.bad1Num     = badNum;
    case 2
      cfgAutoArt.PD.part1       = cfgTmp;
      cfgAutoArt.PD.bad1Num     = badNum;
    case 3
      cfgAutoArt.PS.part1       = cfgTmp;
      cfgAutoArt.PS.bad1Num     = badNum;
    case 4
      cfgAutoArt.C.part1        = cfgTmp;
      cfgAutoArt.C.bad1Num      = badNum;
    case 5
      cfgAutoArt.FP.part2       = cfgTmp;
      cfgAutoArt.FP.bad2Num     = badNum;
    case 6
      cfgAutoArt.PD.part2       = cfgTmp;
      cfgAutoArt.PD.bad2Num     = badNum;
    case 7
      cfgAutoArt.PS.part2       = cfgTmp;
      cfgAutoArt.PS.bad2Num     = badNum;
    case 8
      cfgAutoArt.C.part2        = cfgTmp;
      cfgAutoArt.C.bad2Num      = badNum;
  end  
end

ft_info on;

end

% -------------------------------------------------------------------------
% SUBFUNCTION which estimates segments of one second with artifacts
% -------------------------------------------------------------------------
function [ bNum ] = calcBadNum( threshold )

if isempty(threshold.artifact)
  bNum = 0;
  return;
end

begtrl = find(threshold.trl(:,1) <= threshold.artifact(1,1), 1, 'last');    % find first segment with artifacts
endtrl = find(threshold.trl(:,2) >= threshold.artifact(end,2), 1, 'first'); % find last segment with artifacts

trlMask = zeros(900,1);

for i = begtrl:endtrl
  if any(threshold.trl(i,1) <= threshold.artifact(:,1) & ...
         threshold.trl(i,2) >= threshold.artifact(:,2))
    trlMask(i) = 1;
  end
end

bNum = sum(trlMask);                                                        % calc number of bad segments

end
