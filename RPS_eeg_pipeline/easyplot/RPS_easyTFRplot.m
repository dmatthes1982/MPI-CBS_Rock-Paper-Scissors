function RPS_easyTFRplot(cfg, data)
% RPS_EASYTFRPLOT is a function, which makes it easier to plot a
% time-frequency-spectrum of a specific condition and trial from the 
% RPS_DATASTRUCTURE.
%
% Use as
%   RPS_easyTFRPlot(cfg, data)
%
% where the input data is a results from RPS_TIMEFREQANALYSIS.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%                     0 - plot the averaged data
%                     1 - plot data of participant 1
%                     2 - plot data of participant 2
%   cfg.condition   = condition (default: 2 or 'PredDiff', see RPS_DATASTRUCTURE)
%   cfg.phase       = phase (default: 11 or 'Prediction', see RPS_DATASTRUCTURE)
%   cfg.electrode   = number of electrode (default: 'Cz')
%   cfg.trial       = numbers of trials (i.e.: 1, 'all', [1:60], [1,12,25,53] (default: 1)
%   cfg.freqlim     = [begin end] (default: [2 50])
%   cfg.timelim     = [begin end] (default: [0 3])
%
% This function requires the fieldtrip toolbox
%
% See also FT_SINGLEPLOTTFR, RPS_TIMEFREQANALYSIS

% Copyright (C) 2017-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part      = ft_getopt(cfg, 'part', 1);
condition = ft_getopt(cfg, 'condition', 2);
phase     = ft_getopt(cfg, 'phase', 11);
elec      = ft_getopt(cfg, 'electrode', 'Cz');
trl       = ft_getopt(cfg, 'trial', 1);
freqlim   = ft_getopt(cfg, 'freqlim', [2 50]);
timelim   = ft_getopt(cfg, 'timelim', [0 3]);

filepath = fileparts(mfilename('fullpath'));
addpath(sprintf('%s/../utilities', filepath));

condition = RPS_checkCondition( condition );                                % check cfg.condition definition
switch condition
  case 1
    dataPlot = data.FP;
  case 2
    dataPlot = data.PD;
  case 3
    dataPlot = data.PS;
  case 4
    dataPlot = data.C;
  otherwise
    error('Condition %d is not valid', condition);
end

switch part                                                                 % check validity of cfg.part
  case 0
    if isfield(dataPlot, 'part1')
      warning backtrace off;
      warning('You are using dyad-specific data. Please specify either cfg.part = 1 or cfg.part = 2');
      warning backtrace on;
      return;
    end
  case 1
    if ~isfield(dataPlot, 'part1')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    dataPlot = dataPlot.part1;
  case 2
    if ~isfield(dataPlot, 'part2')
      warning backtrace off;
      warning('You are using data averaged over dyads. Please specify cfg.part = 0');
      warning backtrace on;
      return;
    end
    dataPlot = dataPlot.part2;
end

phase = RPS_checkPhase( phase );                                            % check cfg.phase
trialinfo = dataPlot.trialinfo;
trials  = find(trialinfo == phase);                                         % check if trials with defined phase exist
if isempty(trials)
  error('The selected dataset contains no phase %d.', phase);
else
  if ~isnumeric(trl)                                                        % check cfg.trl
    if strcmp(trl, 'all')
      trlInCond = 'all';
      trl = trials;
    else
      error('The cfg.trl variable holds an unknown string: %s', trl);
    end
  else
    numTrials = length(trials);
    trl = unique(trl);
    if numTrials < max(trl)
      error('The selected dataset contains only %d trials for phase %d.',... 
              numTrials, phase);
    else
      trlInCond = sprintf('[%d', trl(1));
      if length(trl) > 1
        for i=2:1:length(trl)
          trlInCond = strcat(trlInCond, sprintf(',%d',trl(i)));
        end
      end
      trlInCond = strcat(trlInCond, ']');
      trl = trials(trl);
    end
  end
end

label = dataPlot.label;                                                     % get labels

if isnumeric(elec)                                                          % check cfg.electrode
  for i=1:length(elec)
    if elec(i) < 1 || elec(i) > 32
      error('cfg.elec has to be a numbers between 1 and 32 or a existing labels like {''Cz''}.');
    end
  end
else
  if ischar(elec)
    elec = {elec};
  end
  tmpElec = zeros(1, length(elec));
  for i=1:length(elec)
    tmpElec(i) = find(strcmp(label, elec{i}));
    if isempty(tmpElec(i))
      error('cfg.elec has to be a cell array of existing labels like ''Cz''or a vector of numbers between 1 and 32.');
    end
  end
  elec = tmpElec;
end

% -------------------------------------------------------------------------
% Plot time frequency spectrum
% -------------------------------------------------------------------------
ft_warning off;

cfg                 = [];                                                       
cfg.maskstyle       = 'saturation';
cfg.xlim            = timelim;
cfg.ylim            = freqlim;
cfg.zlim            = 'maxmin';
cfg.trials          = trl';
cfg.channel         = elec;
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output

colormap jet;                                                               % use the older and more common colormap

ft_singleplotTFR(cfg, dataPlot);
labelString = strjoin(dataPlot.label(elec), ',');
title(sprintf('Cond.: %d - Part.: %d - Phase: %d - Trial of Phase: %s - Elec.: %s', ...
      condition, part, phase, trlInCond, labelString));

xlabel('time in sec');                                                      % set xlabel
ylabel('frequency in Hz');                                                  % set ylabel

ft_warning on;

end
