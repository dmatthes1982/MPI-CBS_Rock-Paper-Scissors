function [ data ] = RPS_timeFreqanalysis( cfg, data )
% RPS_TIMEFREQANALYSIS performs a time frequency analysis.
%
% Use as
%   [ data ] = RPS_timeFreqanalysis(cfg, data)
%
% where the input data have to be the result from RPS_IMPORTDATASET,
% RPS_PREPROCESSING or RPS_SEGMENTATION
%
% The configuration options are
%   config.foi = frequency of interest - begin:resolution:end (default: 2:1:50)
%   config.toi = time of interest - begin:resolution:end (default: 4:0.4:2.8)
%   
% This function requires the fieldtrip toolbox.
%
% See also RPS_IMPORTDATASET, RPS_PREPROCESSING, RPS_SEGMENTATION, 
% RPS_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
foi       = ft_getopt(cfg, 'foi', 2:1:50);
toi       = ft_getopt(cfg, 'toi', 0.4:0.4:2.8);

% -------------------------------------------------------------------------
% TFR settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.method          = 'wavelet';
cfg.output          = 'pow';
cfg.channel         = 'all';                                                % calculate spectrum for specified channel
cfg.trials          = 'all';                                                % calculate spectrum for every trial  
cfg.keeptrials      = 'yes';                                                % do not average over trials
cfg.pad             = 'maxperlen';                                          % do not use padding
cfg.taper           = 'hanning';                                            % hanning taper the segments
cfg.foi             = foi;                                                  % frequencies of interest
cfg.width           = 7;                                                    % wavlet specific parameter 1 (default value)
cfg.gwidth          = 3;                                                    % wavlet specific parameter 2 (default value) 
cfg.toi             = toi;                                                  % time of interest
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output

% -------------------------------------------------------------------------
% Time-Frequency Response (Analysis)
% -------------------------------------------------------------------------
fprintf('Calc TFRs of participant 1...\n');
ft_warning off;
fprintf('Condition FreePlay...\n');
data.FP.part1 = ft_freqanalysis(cfg, data.FP.part1);
ft_warning off;
fprintf('Condition PredDiff...\n');
data.PD.part1 = ft_freqanalysis(cfg, data.PD.part1);
ft_warning off;
fprintf('Condition PredSame...\n');
data.PS.part1 = ft_freqanalysis(cfg, data.PS.part1);
ft_warning off;
fprintf('Condition Control...\n');
data.C.part1 = ft_freqanalysis(cfg, data.C.part1);

  
fprintf('Calc TFRs of participant 2...\n');
ft_warning off;
fprintf('Condition FreePlay...\n');
data.FP.part2 = ft_freqanalysis(cfg, data.FP.part2);
ft_warning off;
fprintf('Condition PredDiff...\n');
data.PD.part2 = ft_freqanalysis(cfg, data.PD.part2);
ft_warning off;
fprintf('Condition PredSame...\n');
data.PS.part2 = ft_freqanalysis(cfg, data.PS.part2);
ft_warning off;
fprintf('Condition Control...\n');
data.C.part2 = ft_freqanalysis(cfg, data.C.part2); 

ft_warning on;

end
