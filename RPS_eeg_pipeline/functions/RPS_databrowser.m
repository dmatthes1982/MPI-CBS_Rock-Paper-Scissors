function cfgArtifacts = RPS_databrowser( cfg, data )
% RPS_DATABROWSER displays a certain rock, paper, scissor project dataset 
% using a appropriate scaling.
%
% Use as
%   RPS_databrowser( cfg, data )
%
% where the input can be the result of RPS_IMPORTDATASET or
% RPS_PREPROCESSING
%
% The configuration options are
%   cfg.dyad      = number of dyad (no default value)
%   cfg.part      = number of participant (default: 1)
%   cfg.condition = condition (default: 2 or 'PredDiff', see RPS data structure)
%   cfg.artifact  = Nx2 matrix with artifact segments (default: [])
%   cfg.channel   = channels of interest (default: 'all')
%
% This function requires the fieldtrip toolbox
%
% See also RPS_IMPORTALLCONDITIONS, RPS_PREPROCESSING, RPS_SEGMENTATION, 
% RPS_DATASTRUCTURE, FT_DATABROWSER

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
dyad      = ft_getopt(cfg, 'dyad', []);
part      = ft_getopt(cfg, 'part', 1);
cond      = ft_getopt(cfg, 'condition', 2);
artifact  = ft_getopt(cfg, 'artifact', []);
channel   = ft_getopt(cfg, 'channel', 'all');

if isempty(dyad)                                                            % if dyad number is not specified
  event = [];                                                               % the associated markers cannot be loaded and displayed
else                                                                        % else, load the stimulus markers 
  source = '/data/pt_01843/eegData/DualEEG_RPS_rawData/';
  condLetters = {'FP', 'PD', 'PS', 'C'};
  filename = sprintf('DualEEG_RPS_%s_%02d.vhdr', condLetters{cond}, dyad);
  path = strcat(source, filename);
  event = ft_read_event(path);
end

if part < 1 || part > 2                                                     % check cfg.participant definition
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
cfg.ylim                          = [-100 100];
cfg.viewmode                      = 'vertical';
cfg.artfctdef.threshold.artifact  = artifact;
cfg.continuous                    = 'no';
cfg.channel                       = channel;
cfg.event                         = event;
cfg.showcallinfo                  = 'no';

fprintf('Databrowser - Condition: %d - Participant: %d\n', cond, part);

switch part
  case 1
    cfgArtifacts = ft_databrowser(cfg, dataPlot.part1);
  case 2
    cfgArtifacts = ft_databrowser(cfg, dataPlot.part2);
end

end
