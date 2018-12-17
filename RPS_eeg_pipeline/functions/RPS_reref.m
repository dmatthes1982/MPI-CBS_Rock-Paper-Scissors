function [ data ] = RPS_reref( cfg, data )
% RPS_REREF does the re-referencing of eeg data, 
%
% Use as
%   [ data ] = RPS_reref(cfg, data)
%
% The configuration option is
%   cfg.refchannel        = re-reference channel (default: 'TP10')
%
% This function requires the fieldtrip toolbox.
%
% See also FT_PREPROCESSING, RPS_DATASTRUCTURE

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check the config option
% -------------------------------------------------------------------------
refchannel        = ft_getopt(cfg, 'refchannel', 'TP10');

% -------------------------------------------------------------------------
% Re-Referencing
% -------------------------------------------------------------------------
cfg               = [];
cfg.reref         = 'yes';                                                  % enable re-referencing
if ~iscell(refchannel)
  cfg.refchannel    = {refchannel, 'REF'};                                  % specify new reference
else
  cfg.refchannel    = [refchannel, {'REF'}];
end
cfg.implicitref   = 'REF';                                                  % add implicit channel 'REF' to the channels
cfg.refmethod     = 'avg';                                                  % average over selected electrodes
cfg.channel       = 'all';                                                  % use all channels
cfg.trials        = 'all';                                                  % use all trials
cfg.feedback      = 'no';                                                   % feedback should not be presented
cfg.showcallinfo  = 'no';                                                   % prevent printing the time and memory after each function call

fprintf('<strong>Re-reference data of participant 1...</strong>\n');
fprintf('Condition FreePlay...\n');
data.FP.part1 = ft_preprocessing(cfg, data.FP.part1);

fprintf('Condition PredDiff...\n');
data.PD.part1 = ft_preprocessing(cfg, data.PD.part1);

fprintf('Condition PredSame...\n');
data.PS.part1 = ft_preprocessing(cfg, data.PS.part1);

fprintf('Condition Control...\n');
data.C.part1  = ft_preprocessing(cfg, data.C.part1);

fprintf('<strong>Re-reference data of participant 2...</strong>\n');
fprintf('Condition FreePlay...\n');
data.FP.part2 = ft_preprocessing(cfg, data.FP.part2);

fprintf('Condition PredDiff...\n');
data.PD.part2 = ft_preprocessing(cfg, data.PD.part2);

fprintf('Condition PredSame...\n');
data.PS.part2 = ft_preprocessing(cfg, data.PS.part2);

fprintf('Condition Control...\n');
data.C.part2  = ft_preprocessing(cfg, data.C.part2);

end
