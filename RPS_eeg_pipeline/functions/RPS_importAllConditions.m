function [ data, cfg_manart ] = RPS_importAllConditions( cfg )
% RPS_IMPORTALLCONDITIONS imports the data of all four conditions of a
% single dyad
%
% Use as
%   [ data, cfg_manart ] = RPS_importAllConditions( cfg )
%
% The configuration options are
%   cfg.path        = source path' (i.e. '/data/pt_01843/eegData/DualEEG_RPS_rawData/')
%   cfg.dyad        = number of dyad
%   cfg.continuous  = 'yes' or 'no' (default: 'no')
%
% You can use relativ path specifications (i.e. '../../MATLAB/data/') or 
% absolute path specifications like in the example. Please be aware that 
% you have to mask space signs of the path names under linux with a 
% backslash char (i.e. '/home/user/test\ folder')
%
% This function requires the fieldtrip toolbox.
%
% See also FT_PREPROCESSING, RPS_DATASTRUCTURE, RPS_IMPORTDATASET

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path        = ft_getopt(cfg, 'path', []);
dyad        = ft_getopt(cfg, 'dyad', []);
continuous  = ft_getopt(cfg, 'continuous', 'no');

if isempty(path)
  error('No source path is specified!');
end

if isempty(dyad)
  error('No specific participant is defined!');
end

% -------------------------------------------------------------------------
% Data import
% -------------------------------------------------------------------------
cfg = [];
cfg.path = path;
cfg.dyad = dyad;
cfg.continuous = continuous;

% Condition 'FreePlay'
cfg.condition = 'FP';
fprintf('Condition FreePlay...\n');
[data.FP, cfg_manart.FP] = RPS_importDataset( cfg );

% Condition 'PredDiff'
cfg.condition = 'PD';
fprintf('Condition PredDiff...\n');
[data.PD, cfg_manart.PD] = RPS_importDataset( cfg );

% Condition 'PredSame'
cfg.condition = 'PS';
fprintf('Condition PredSame...\n');
[data.PS, cfg_manart.PS] = RPS_importDataset( cfg );

% Condition 'Control'
cfg.condition = 'C';
fprintf('Condition Control...\n');
[data.C, cfg_manart.C] = RPS_importDataset( cfg );

end
