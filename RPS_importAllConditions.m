function [ data ] = RPS_importAllConditions( cfg )
% RPS_IMPORTALLCONDITIONS imports the data of all four conditions of a
% single dyad
%
% Use as
%   [ data ] = = RPS_importAllConditions( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01843/eegData/DualEEG_RPS_rawData/')
%   cfg.part      = number of participant
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
path      = ft_getopt(cfg, 'path', []);
part      = ft_getopt(cfg, 'part', []);

if isempty(path)
  error('No source path is specified!');
end

if isempty(part)
  error('No specific participant is defined!');
end

% -------------------------------------------------------------------------
% Data import
% -------------------------------------------------------------------------
cfg = [];
cfg.path = path;
cfg.part = part;

% Condition 'FreePlay'
cfg.condition = 'FP';
fprintf('Condition FreePlay...\n');
data.FP = RPS_importDataset( cfg );

% Condition 'PredDiff'
cfg.condition = 'PD';
fprintf('Condition PredDiff...\n');
data.PD = RPS_importDataset( cfg );

% Condition 'PredSame'
cfg.condition = 'PS';
fprintf('Condition PredSame...\n');
data.PS = RPS_importDataset( cfg );

% Condition 'Control'
cfg.condition = 'C';
fprintf('Condition Control...\n');
data.C = RPS_importDataset( cfg );
