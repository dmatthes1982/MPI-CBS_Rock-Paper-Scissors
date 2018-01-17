function [ data ] = RPS_specialSeg( data )
% RPS_SPECIALSEG segments only the resting state trials 'S 20' into 
% subsegments with a duration of 5 seconds
%
% Use as
%   [ data ] = RPS_specialSeg( data )
%
% where the input data can be the result from RPS_IMPORTDATASET or
% RPS_PREPROCESSING
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_IMPORTDATASET, RPS_PREPROCESSING, FT_REDEFINETRIAL,
% RPS_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Basic segmentation settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.feedback        = 'no';
cfg.showcallinfo    = 'no';

% -------------------------------------------------------------------------
% Segmentation
% -------------------------------------------------------------------------
fprintf('Subsegment resting state trials with participant 1...\n');
ft_info off;
ft_warning off;
fprintf('Condition FreePlay...\n');
cfg.trl = estimTrialDef(data.FP.part1);
data.FP.part1 = ft_redefinetrial(cfg, data.FP.part1);
ft_info off;
ft_warning off;
fprintf('Condition PredDiff...\n');
cfg.trl = estimTrialDef(data.PD.part1);
data.PD.part1 = ft_redefinetrial(cfg, data.PD.part1);
ft_info off;
ft_warning off;
fprintf('Condition PredSame...\n');
cfg.trl = estimTrialDef(data.PS.part1);
data.PS.part1 = ft_redefinetrial(cfg, data.PS.part1);
ft_info off;
ft_warning off;
fprintf('Condition Control...\n');
cfg.trl = estimTrialDef(data.C.part1);
data.C.part1 = ft_redefinetrial(cfg, data.C.part1);
    
fprintf('Subsegment resting state trials with participant 2...\n');
ft_info off;
ft_warning off;
fprintf('Condition FreePlay...\n');
cfg.trl = estimTrialDef(data.FP.part2);
data.FP.part2 = ft_redefinetrial(cfg, data.FP.part2);
ft_info off;
ft_warning off;
fprintf('Condition PredDiff...\n');
cfg.trl = estimTrialDef(data.PD.part2);
data.PD.part2 = ft_redefinetrial(cfg, data.PD.part2);
ft_info off;
ft_warning off;
fprintf('Condition PredSame...\n');
cfg.trl = estimTrialDef(data.PS.part2);
data.PS.part2 = ft_redefinetrial(cfg, data.PS.part2);
ft_info off;
ft_warning off;
fprintf('Condition Control...\n');
cfg.trl = estimTrialDef(data.C.part2);
data.C.part2 = ft_redefinetrial(cfg, data.C.part2);

ft_info on;
ft_warning on;

end

function trl = estimTrialDef( dataTmp )

trialinfo = dataTmp.trialinfo; 
sampleinfo = dataTmp.sampleinfo;

numOfOldTrials = length(trialinfo);
StimS20        = find(ismember(trialinfo, 20));
numOfS20       = length(StimS20);
numOfSubseq    = (sampleinfo(StimS20(1),2) - ...
                   sampleinfo(StimS20(1),1)+1)/500/5;
numOfNewTrials = numOfOldTrials + (numOfS20 * numOfSubseq) - numOfS20;

trl = zeros(numOfNewTrials, 4);
j = 1;

for i = 1:1:numOfOldTrials
  if trialinfo(i) ~= 20
    trl(j, 1) = sampleinfo(i, 1);
    trl(j, 2) = sampleinfo(i, 2);
    trl(j, 4) = trialinfo(i);
    j = j + 1;
  else
    for k = 1:1:numOfSubseq
      trl(j, 1) = sampleinfo(i, 1) + (k-1)*2500;
      trl(j, 2) = sampleinfo(i, 1) + k*2500 - 1;
      trl(j, 4) = trialinfo(i);
      j = j + 1;
    end
  end
end

end
