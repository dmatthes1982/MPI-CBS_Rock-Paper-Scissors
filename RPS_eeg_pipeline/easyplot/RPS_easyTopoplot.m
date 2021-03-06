function RPS_easyTopoplot(cfg , data)
% RPS_EASYTOPOPLOT is a function, which makes it easier to plot the
% topographic distribution of the power over the head.
%
% Use as
%   RPS_easyTopoplot(cfg, data)
%
%  where the input data have to be a result from RPS_PWELCH.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%                     0 - plot the averaged data
%                     1 - plot data of participant 1
%                     2 - plot data of participant 2   
%   cfg.condition   = condition (default: 2 or 'PredDiff', see RPS_DATASTRUCTURE)
%   cfg.phase       = phase (default: 11 or 'Prediction', see RPS_DATASTRUCTURE)
%   cfg.baseline    = baseline phase (default: [], can by any valid phase)
%                     the values of the baseline phase will be subtracted
%                     from the values of the selected phase (cfg.phase)
%   cfg.freqlim     = limits for frequency in Hz (e.g. [6 9] or 10) (default: 10)
%   cfg.zlim        = limits for color dimension, 'maxmin', 'maxabs', 'zeromax', 'minzero', or [zmin zmax] (default = 'maxmin')
%   cfg.showeogv    = 'yes' or 'no' (default: 'no'), show vertical eye electrodes in topoplot
%
% This function requires the fieldtrip toolbox
%
% See also RPS_PWELCH, RPS_DATASTRUCTURE

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part      = ft_getopt(cfg, 'part', 1);
condition = ft_getopt(cfg, 'condition', 2);
phase     = ft_getopt(cfg, 'phase', 11);
baseline  = ft_getopt(cfg, 'baseline', []);
freqlim   = ft_getopt(cfg, 'freqlim', 10);
zlim      = ft_getopt(cfg, 'zlim', 'maxmin');
showeogv  = ft_getopt(cfg, 'showeogv', 'no');

filepath = fileparts(mfilename('fullpath'));                                % add utilities folder to path
addpath(sprintf('%s/../utilities', filepath));

condition = RPS_checkCondition( condition );                                % check cfg.condition definition   
switch condition
  case 1
    data = data.FP;
  case 2
    data = data.PD;
  case 3
    data = data.PS;
  case 4
    data = data.C;
  otherwise
    error('Condition %d is not valid', condition);
end

if ~ismember(part, [0,1,2])                                                 % check cfg.part definition
  error('cfg.part has to be either 0, 1 or 2');
end

switch part                                                                 % check validity of cfg.part
  case 0
    if isfield(data, 'part1')
      warning backtrace off;
      warning('You are using dyad-specific data. Please specify either cfg.part = 1 or cfg.part = 2');
      warning backtrace on;
      return;
    end
  case 1
    if ~isfield(data, 'part1')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    data = data.part1;
  case 2
    if ~isfield(data, 'part2')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    data = data.part2;
end

trialinfo = data.trialinfo;                                                 % get trialinfo

phase = RPS_checkPhase( phase );                                            % check cfg.phase definition
if isempty(find(trialinfo == phase, 1))
  error('The selected dataset contains no condition %d.', phase);
else
  trialNum = ismember(trialinfo, phase);
end

if ~isempty(baseline)
  baseline    = RPS_checkPhase( baseline );                                 % check cfg.baseline definition
  if isempty(find(trialinfo == baseline, 1))
    error('The selected dataset contains no condition %d.', baseline);
  else
    baseNum = ismember(trialinfo, baseline);
  end
end

if numel(freqlim) == 1
  freqlim = [freqlim freqlim];
end

% -------------------------------------------------------------------------
% Generate topoplot
% -------------------------------------------------------------------------
load(sprintf('%s/../layouts/mpi_002_customized_acticap32.mat', ...
              filepath), 'lay');

if strcmp(showeogv, 'no')
  tf = ~ismember(lay.label, {'V1','V2'});                                   %#ok<NODEF>
  lay.pos     = lay.pos(tf,:);
  lay.label   = lay.label(tf);
  lay.width   = lay.width(tf);
  lay.height  = lay.height(tf);
end

cfg               = [];
cfg.parameter     = 'powspctrm';
cfg.xlim          = freqlim;
cfg.zlim          = zlim;
cfg.trials        = trialNum;
cfg.colormap      = 'jet';
cfg.marker        = 'on';
cfg.colorbar      = 'yes';
cfg.style         = 'both';
cfg.gridscale     = 200;                                                    % gridscale at map, the higher the better
cfg.layout        = lay;
cfg.showcallinfo  = 'no';

if ~isempty(baseline)                                                       % subtract baseline condition
  data.powspctrm(trialNum,:,:) = data.powspctrm(trialNum,:,:) - ...
                                  data.powspctrm(baseNum,:,:);
end

ft_topoplotER(cfg, data);

if part == 0                                                                % set figure title
  if isempty(baseline)
    title(sprintf('Power - Condition %d - Phase %d - Freqrange [%d %d]',...
              condition, phase, freqlim));
  else
    title(sprintf(['Power - Condition %d - Phase %d-%d - Freqrange ' ...
              '[%d %d]'], condition, phase, baseline, freqlim));
  end
else
  if isempty(baseline)
    title(sprintf(['Power - Participant %d - Condition %d - Phase ' ...
              '%d - Freqrange [%d %d]'], part, condition, phase, ...
              freqlim));
  else
    title(sprintf(['Power - Participant %d - Condition %d - '...
              'Phase %d-%d - Freqrange [%d %d]'], part, condition, ...
              phase, baseline, freqlim));
  end
end

set(gcf, 'Position', [0, 0, 750, 550]);
movegui(gcf, 'center');
              
end
