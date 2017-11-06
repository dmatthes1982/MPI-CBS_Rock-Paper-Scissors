function RPS_easyMPLVplot( cfg, data )
% RPS_EASYMPLVPLOT is a function, which makes it easier to plot the mean 
% PLV values from all electrodes of a specific condition from the 
% RPS_DATASTRUCTURE.
%
% Use as
%   RPS_easyPLVplot( cfg, data )
%
% where the input data has to be the result of RPS_PHASELOCKVAL
%
% The configuration options are
%   cfg.condition = condition (default: 2 or 'PredDiff', see RPS_DATASTRUCTURE)
%   cfg.phase     = phase (default: 11 or 'Prediction', see RPS_DATASTRUCTURE)
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_DATASTRUCTURE, PLOT, RPS_PHASELOCKVAL, RPS_CALCMEANPLV

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
cond      = ft_getopt(cfg, 'condition', 2);
phase     = ft_getopt(cfg, 'phase', 11);

cond = RPS_checkCondition( cond );                                          % check cfg.condition definition    
switch cond
  case 1
    if isfield(data.FP, 'dyad')
      dataPlot = data.FP.dyad;
    else
      dataPlot = data.FP;
    end
  case 2
    if isfield(data.PD, 'dyad')
      dataPlot = data.PD.dyad;
    else
      dataPlot = data.PD;
    end
  case 3
    if isfield(data.PS, 'dyad')
      dataPlot = data.PS.dyad;
    else
      dataPlot = data.PS;
    end
  case 4
    if isfield(data.C, 'dyad')
      dataPlot = data.C.dyad;
    else
      dataPlot = data.C;
    end
  otherwise
    error('Condition %d is not valid', cond);
end

trialinfo = dataPlot.trialinfo;                                             % get trialinfo

phase = RPS_checkPhase( phase );                                            % check cfg.phase definition and translate it into trl number    
trl  = find(trialinfo == phase);
if isempty(trl)
  error('The selected dataset contains no phase %d.', phase);
end

% -------------------------------------------------------------------------
% Plot mPLV representation
% -------------------------------------------------------------------------
label = dataPlot.label;
components = 1:1:length(label);

colormap jet;
imagesc(components, components, dataPlot.mPLV{trl});
set(gca, 'XTick', components,'XTickLabel', label);                          % use labels instead of numbers for the axis description
set(gca, 'YTick', components,'YTickLabel', label);
set(gca,'xaxisLocation','top');                                             % move xlabel to the top
title(sprintf(' mean Phase Locking Values (PLV) in Phase %d of Condition: %d', ...
                phase, cond));   
colorbar;

end
