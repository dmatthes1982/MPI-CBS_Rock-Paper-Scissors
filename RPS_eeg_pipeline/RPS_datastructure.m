% RPS_DATASTRUCTURE
%
% The data in the --- Rock, Paper, Scissor Projekt --- ist structured as 
% follows:
%
% Every step of the data processing pipeline (i.e. 01_raw, 02_preproc, 
% ...) produces output of N single *.mat files, where N describes the 
% current number of dyads within the study. Each *.mat file holds a 'data' 
% struct consisting of four fields, which are labeled with FP, PD, PS and 
% C. Theses are the leading letters of the four existing conditions 
% 'FreePlay', 'PredictDifferent', 'PredictSame' and 'Control'. Each 
% condition field again comprises two subfields named part1 and part2, 
% which are 1x1 structures with the complete data of the condition-
% associated data of one participant. The data is stored for each dyad 
% separately, to avoid the need of swap memory during data processing.
% The data itself is structured in trials. Every trial is defined as a
% specific phase of a specific condition. A corresponding number is stored 
% in the field trialinfo of the participants data struct. The order of the 
% trials in one data struct is available through the relating time field.
%
% dataset example:
%
% data_raw
%    |               
%    |---- FP
%    |     |---part1 (1x1 fieldtrip data structure for participant 1)    
%    |     |---- part2 (1x1 fieldtrip data structure for participant 2)
%    |
%    |---- PD
%    |---- PS
%    |---- C
%
% Many functions, especially the plot functions, need a specification of 
% the phase and condition, which should be selected. Currently the 
% following specifications are existent:
%
% Conditions:
% - FreePlay     - 1
% - PredDiff     - 2
% - PredSame     - 3
% - Control      - 4
%
% Phases:
% - Prompt       - 10
% - Prediction   - 11
% - ButtonPress  - 12
% - Action       - 13
% - PanelDown    - 14
% - PanelUp      - 15
%
% The defintion of the condition/ the phase is done by setting the
% cfg.condition / cfg.phase option with the string or the number of the 
% specific selection.

% Copyright (C) 2017, Daniel Matthes, MPI CBS