function RPS_easyPLVplot( cfg, data )
% RPS_EASYPLVPLOT is a function, which makes it easier to plot the PLV 
% values of a specific condition from the RPS-data-structure.
%
% Use as
%   RPS_easyPLVplot( cfg, data )
%
% where the input data has to be the result of RPS_PHASELOCKVAL
%
% The configuration options are
%   cfg.condition = condition (default: 2 or 'PredDiff', see RPS data structure)
%   cfg.phase     = phase (default: 11 or 'Prediction', see RPS data structure)
%   cfg.elecPart1 = number of electrode of participant 1 (default: 'Cz')
%   cfg.elecPart2 = number of electrode of participant 2 (default: 'Cz')
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_DATASTRUCTURE, PLOT, RPS_PHASELOCKVAL

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
cond      = ft_getopt(cfg, 'condition', 2);
phase     = ft_getopt(cfg, 'phase', 11);
elecPart1 = ft_getopt(cfg, 'elecPart1', 'Cz');
elecPart2 = ft_getopt(cfg, 'elecPart2', 'Cz');

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

trialinfo = dataPlot.dyad.trialinfo;                                        % get trialinfo

phase = RPS_checkPhase( phase );                                            % check cfg.phase definition and translate it into trl number    
trl  = find(trialinfo == phase);
if isempty(trl)
  error('The selected dataset contains no condition %d.', phase);
end

label = dataPlot.dyad.label;                                                % get labels

if isnumeric(elecPart1)                                                     % check cfg.electrode definition
  if elecPart1 < 1 || elecPart1 > 32
    error('cfg.elecPart1 hast to be a number between 1 and 32 or a existing label like ''Cz''.');
  end
else
  elecPart1 = find(strcmp(label, elecPart1));                            
  if isempty(elecPart1)
    error('cfg.elecPart1 hast to be a existing label like ''Cz''or a number between 1 and 32.');
  end
end

if isnumeric(elecPart2)                                                     % check cfg.electrode definition
  if elecPart2 < 1 || elecPart2 > 32
    error('cfg.elecPart2 hast to be a number between 1 and 32 or a existing label like ''Cz''.');
  end
else
  elecPart2 = find(strcmp(label, elecPart2));
  if isempty(elecPart2)
    error('cfg.elecPart2 hast to be a existing label like ''Cz''or a number between 1 and 32.');
  end
end

% -------------------------------------------------------------------------
% Plot PLV course
% -------------------------------------------------------------------------
%plot(dataPlot.dyad.time{trl}, data.dyad.PLV{trl}{elecPart1,elecPart2}(:));
plot(dataPlot.dyad.PLV{trl}{elecPart1,elecPart2}(:));
title(sprintf('Cond.: %d - Phase: %d - Elec.: %s - %s', cond, phase, ...
              strrep(dataPlot.dyad.label{elecPart1}, '_', '\_'), ...
              strrep(dataPlot.dyad.label{elecPart2}, '_', '\_')));      

xlabel('samples');
%xlabel('time in seconds');
ylabel('phase locking value');

end
