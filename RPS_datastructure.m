% RPS_DATASTRUCTURE
%
% The data in the --- Rock, Paper, Scissor Projekt --- ist structured as 
% follows:
%
% Every step of the data processing pipeline (i.e. 01_raw, 02_preproc, 
% 03_tfr1 ...) produces N single *.mat files, where N describes the 
% current number of dyads within the study. Each *.mat file holds a 'data'
% struct consisting of two fields, which are named part1 and part2. Each 
% field again comprises a 1x1 struct with the complete data (data of all 
% four conditions) of a specific participant. The data ist stored for each 
% dyad separately, to avoid the need of swap memory during data processing.
% The data itself is structured in trials. Every trial is defined as a
% specific phase in a specific condition. A corresponding number is stored 
% in the field trialinfo of the participants data struct. The order of the 
% trials in one data struct is available through the relating time field.
%
% dataset example:
%
% data_raw
%    |               
%    |---- part1 (1x1 fieldtrip data structure for participant 1)    
%    |---- part2 (1x1 fieldtrip data structure for participant 2)
%   
% Many functions, especially the plot functions, need a specification of 
% the phase and condition, which should be selected. Currently the 
% following specifications are existent:
%
% - FreePlay_Prediction   - 111
% - FreePlay_ButtonPress  - 112
% - FreePlay_Action       - 113
% - FreePlay_PanelDown    - 114
% - PredDiff_Prediction   - 211
% - PredDiff_ButtonPress  - 212
% - PredDiff_Action       - 213
% - PredDiff_PanelDown    - 214
% - PredSame_Prediction   - 311
% - PredSame_ButtonPress  - 312
% - PredSame_Action       - 313
% - PredSame_PanelDown    - 314
% - Control_Prediction    - 411
% - Control_ButtonPress   - 412
% - Control_Action        - 413
%
% The defintion of the condition is done by setting the cfg.state
% option with the string or the number of the specific state.

% Copyright (C) 2017, Daniel Matthes, MPI CBS