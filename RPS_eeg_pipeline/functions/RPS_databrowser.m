function [ cfgArtifacts ] = RPS_databrowser( cfg, data )
% RPS_DATABROWSER displays a certain rock, paper, scissors project dataset 
% using a appropriate scaling.
%
% Use as
%   RPS_databrowser( cfg, data )
%
% where the input can be the result of RPS_IMPORTDATASET or
% RPS_PREPROCESSING
%
% The configuration options are
%   cfg.dyad        = number of dyad (no default value)
%   cfg.part        = number of participant (default: 1)
%   cfg.condition   = condition (default: 2 or 'PredDiff', see RPS data structure)
%   cfg.threshArt   = Nx2 matrix with threshold artifact segments (default: [])
%   cfg.manArt      = Nx2 matrix with manual artifact segments (default: [])
%   cfg.channel     = channels of interest (default: 'all')
%   cfg.ylim        = vertical scaling (default: [-100 100]);
%   cfg.blocksize   = duration in seconds for cutting the data up (default: [])
%   cfg.plotevents  = 'yes' or 'no' (default: 'yes'), if it is no raw data
%                     you have to specify cfg.dyad otherwise the events
%                     will be not found and therefore not plotted
%
% This function requires the fieldtrip toolbox
%
% See also RPS_IMPORTALLCONDITIONS, RPS_PREPROCESSING, RPS_SEGMENTATION, 
% RPS_DATASTRUCTURE, FT_DATABROWSER

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
dyad        = ft_getopt(cfg, 'dyad', []);
part        = ft_getopt(cfg, 'part', 1);
cond        = ft_getopt(cfg, 'condition', 2);
threshArt   = ft_getopt(cfg, 'threshArt', []);
manArt      = ft_getopt(cfg, 'manArt', []);
channel     = ft_getopt(cfg, 'channel', 'all');
ylim        = ft_getopt(cfg, 'ylim', [-100 100]);
blocksize   = ft_getopt(cfg, 'blocksize', []);
plotevents  = ft_getopt(cfg, 'plotevents', 'yes');

if isempty(dyad)                                                            % if dyad number is not specified
  event = [];                                                               % the associated markers cannot be loaded and displayed
else                                                                        % else, load the stimulus markers 
  source = '/data/pt_01843/eegData/DualEEG_RPS_rawData/';
  condLetters = {'FP', 'PD', 'PS', 'C'};
  filename = sprintf('DualEEG_RPS_%s_%02d.vhdr', condLetters{cond}, dyad);
  path = strcat(source, filename);
  event = ft_read_event(path);
end

if ~ismember(part, [1, 2])                                                  % check cfg.participant definition
  error('cfg.part has to be 1 or 2');
end

cond = RPS_checkCondition( cond );                                          % check cfg.condition definition    
switch cond
  case 1
    dataPlot = data.FP;
  case 2
    dataPlot = data.PD;
  case 3
    dataPlot = data.PS;
  case 4
    dataPlot = data.C;
  otherwise
    error('Condition %d is not valid', cond);
end

% -------------------------------------------------------------------------
% Configure and start databrowser
% -------------------------------------------------------------------------
cfg                               = [];
cfg.ylim                          = ylim;
cfg.blocksize                     = blocksize;
cfg.viewmode                      = 'vertical';
cfg.artfctdef.threshold.artifact  = threshArt;
cfg.artfctdef.xxx.artifact        = manArt;
cfg.continuous                    = 'no';
cfg.channel                       = channel;
cfg.plotevents                    = plotevents;
cfg.event                         = event;
cfg.showcallinfo                  = 'no';

fprintf('Databrowser - Condition: %d - Participant: %d\n', cond, part);

switch part
  case 1
    if nargout > 0
      cfgArtifacts = ft_databrowser(cfg, dataPlot.part1);
    else
      ft_databrowser(cfg, dataPlot.part1);
    end
  case 2
    if nargout > 0
      cfgArtifacts = ft_databrowser(cfg, dataPlot.part2);
    else
      ft_databrowser(cfg, dataPlot.part2);
    end
end

end
