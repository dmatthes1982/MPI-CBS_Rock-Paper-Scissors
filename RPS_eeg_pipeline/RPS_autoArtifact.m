function [ cfgAutoArt ] = RPS_autoArtifact( cfg, data )
% RPS_AUTOARTIFACT marks timeslots as an artifact in which the level of 
% 'Cz', 'O1' and 'O2' exceeds or fall below +/- 75 mV.
%
% Use as
%   [ cfgAutoArt ] = RPS_autoArtifact(cfg, data)
%
% where data has to be a result of RPS_PREPROCESSING
%
% The configuration options are
%   cfg.channel = cell-array with channel labels (default: {'Cz', 'O1', 'O2'}))
%   cfg.min     = lower limit in uV (default: -75)
%   cfg.max     = upper limit in uV (default: 75)
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_PREPROCESSING, FT_ARTIFACT_THRESHOLD

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
chan      = ft_getopt(cfg, 'channel', {'Cz', 'O1', 'O2'});
minVal    = ft_getopt(cfg, 'min', -75);
maxVal    = ft_getopt(cfg, 'max', 75);

% -------------------------------------------------------------------------
% Artifact detection settings
% -------------------------------------------------------------------------
ft_info off;

cfg                               = [];
cfg.continuous                    = 'no';                                   % data are already trial based
cfg.artfctdef.threshold.channel   = chan;                                   % specify channels of interest
cfg.artfctdef.threshold.bpfilter  = 'no';                                   % use no additional bandpass
cfg.artfctdef.threshold.min       = minVal;                                 % minimum threshold
cfg.artfctdef.threshold.max       = maxVal;                                 % maximum threshold
cfg.showcallinfo                  = 'no';

% -------------------------------------------------------------------------
% Estimate artifacts
% -------------------------------------------------------------------------
cfgTmp.part1 = [];                                                          % build output structure
cfgTmp.part2 = [];
cfgTmp.bad1Num = []; 
cfgTmp.bad2Num = [];
cfgTmp.trialsNum = [];

cfgAutoArt.FP = cfgTmp;
cfgAutoArt.PD = cfgTmp;
cfgAutoArt.PS = cfgTmp;
cfgAutoArt.C = cfgTmp;

for condition = 1:1:8
  switch condition
    case 1
      fprintf('Estimate artifacts in participant 1...\n');
      fprintf('Condition FreePlay...\n');
      dataTmp = data.FP.part1;
    case 2
      fprintf('Condition PredDiff...\n');
      dataTmp = data.PD.part1;
    case 3
      fprintf('Condition PredSame...\n');
      dataTmp = data.PS.part1;
    case 4
      fprintf('Condition Control...\n');
      dataTmp = data.C.part1;
    case 5
      fprintf('Estimate artifacts in participant 2...\n');
      fprintf('Condition FreePlay...\n');
      dataTmp = data.FP.part2;
    case 6
      fprintf('Condition PredDiff...\n');
      dataTmp = data.PD.part2;
    case 7
      fprintf('Condition PredSame...\n');
      dataTmp = data.PS.part2;
    case 8
      fprintf('Condition Control...\n');
      dataTmp = data.C.part2;
  end
  
  trialsNum = length(dataTmp.trial);
  cfg.trl   = ft_findcfg(dataTmp.cfg, 'trl');

  cfgTmp    = ft_artifact_threshold(cfg, dataTmp);
  cfgTmp    = keepfields(cfgTmp, {'artfctdef', 'showcallinfo'});
  badNum    = length(cfgTmp.artfctdef.threshold.artifact);
  fprintf('%d artifacts detected!\n', badNum);
  
  switch condition
    case 1
      cfgAutoArt.FP.part1       = cfgTmp;
      cfgAutoArt.FP.trialsNum   = trialsNum;
      cfgAutoArt.FP.bad1Num     = badNum;
    case 2
      cfgAutoArt.PD.part1       = cfgTmp;
      cfgAutoArt.PD.trialsNum   = trialsNum;
      cfgAutoArt.PD.bad1Num     = badNum;
    case 3
      cfgAutoArt.PS.part1       = cfgTmp;
      cfgAutoArt.PS.trialsNum   = trialsNum;
      cfgAutoArt.PS.bad1Num     = badNum;
    case 4
      cfgAutoArt.C.part1        = cfgTmp;
      cfgAutoArt.C.trialsNum    = trialsNum;
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
