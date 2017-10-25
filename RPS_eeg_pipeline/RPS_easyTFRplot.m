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
%   cfg.condition   = condition (default: 2 or 'PredDiff', see RPS_DATASTRUCTURE)
%   cfg.phase       = phase (default: 11 or 'Prediction', see RPS_DATASTRUCTURE)
%   cfg.electrode   = number of electrode (default: 'Cz')
%   cfg.trial       = numbers of trials (i.e.: 1, 'all', [1:60], [1,12,25,53] (default: 1)
%   cfg.freqlimits  = [begin end] (default: [2 50])
%   cfg.timelimits  = [begin end] (default: [0 3])
%
% This function requires the fieldtrip toolbox
%
% See also FT_SINGLEPLOTTFR, RPS_TIMEFREQANALYSIS

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part    = ft_getopt(cfg, 'part', 1);
cond    = ft_getopt(cfg, 'condition', 2);
phase = ft_getopt(cfg, 'phase', 11);
elec    = ft_getopt(cfg, 'electrode', 'Cz');
trl     = ft_getopt(cfg, 'trial', 1);
freqlim = ft_getopt(cfg, 'freqlimits', [2 50]);
timelim = ft_getopt(cfg, 'timelimits', [0 3]);

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

if part == 1                                                                % get trialinfo
  trialinfo = dataPlot.part1.trialinfo;
elseif part == 2
  trialinfo = dataPlot.part2.trialinfo;
end

phase = RPS_checkPhase( phase );                                            % check cfg.phase
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
      error('The selected dataset contains only %d trials.', numTrials);
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

if part == 1                                                                % get labels
  label = dataPlot.part1.label;                                             
elseif part == 2
  label = dataPlot.part2.label;
end

if isnumeric(elec)
  if elec < 1 || elec > 32
    error('cfg.elec hast to be a number between 1 and 32 or a existing label like ''Cz''.');
  end
else
  elec = find(strcmp(label, elec));
  if isempty(elec)
    error('cfg.elec hast to be a existing label like ''Cz''or a number between 1 and 32.');
  end
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

switch part
  case 1
    ft_singleplotTFR(cfg, dataPlot.part1);
    title(sprintf('Cond.: %d - Part.: %d - Phase.: %d - Trial of Phase: %s - Elec.: %s', ...
          cond, part, phase, trlInCond, ...
          strrep(dataPlot.part1.label{elec}, '_', '\_')));   
  case 2
    ft_singleplotTFR(cfg, dataPlot.part2);
    title(sprintf('Cond.: %d - Part.: %d - Phase.: %d - Trial of Phase: %s - Elec.: %s', ...
          cond, part, phase, trlInCond, ...
          strrep(dataPlot.part2.label{elec}, '_', '\_')));
end

xlabel('time in sec');                                                      % set xlabel
ylabel('frequency in Hz');                                                  % set ylabel

ft_warning on;

end