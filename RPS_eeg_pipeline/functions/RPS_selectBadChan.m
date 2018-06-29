function [ data_badchan ] = RPS_selectBadChan( data_raw )
% RPS_SELECTBADCHAN can be used for selecting bad channels visually. The
% data will be presented in the fieldtrip databrowser view and the bad
% channels will be marked in the RPS_CHANNELCHECKBOX gui. The function
% returns a fieldtrip-like datastructure which includes only a cell array 
% for each participant with the selected bad channels.
%
% Use as
%   [ data_badchan ] = RPS_selectBadChan( data_raw )
%
% where the input has to be raw data
%
% The function requires the fieldtrip toolbox
%
% SEE also RPS_DATABROWSER and RPS_CHANNELCHECKBOX

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% General settings
% -------------------------------------------------------------------------
participants  = [1,1,1,1,2,2,2,2];
conditions    = [1,2,3,4,1,2,3,4];
condString    = {'FP','PD','PS','C','FP','PD','PS','C'};

for i = 1:1:8
% -------------------------------------------------------------------------
% Databrowser settings
% ------------------------------------------------------------------------- 
  cfg             = [];
  cfg.ylim        = [-200 200];
  cfg.blocksize   = 120;
  cfg.part        = participants(i);
  cfg.condition   = conditions(i);
  cfg.plotevents  = 'no';

% -------------------------------------------------------------------------
% Selection of bad channels
% -------------------------------------------------------------------------
  fprintf('<strong>Select bad channels of participant %d in condition %s...</strong>\n', ...
          cfg.part, condString{i});
  RPS_databrowser( cfg, data_raw );
  badLabel = RPS_channelCheckbox();
  close(gcf);                                                               % close also databrowser view when the channelCheckbox will be closed
  if any(strcmp(badLabel, 'TP10'))
    warning backtrace off;
    warning(['You have repaired ''TP10'', accordingly selecting linked ' ...
             'mastoid as reference in step [2] - preprocessing is not '...
             'longer recommended.']);
    warning backtrace on;
  end
  if length(badLabel) >= 2
    warning backtrace off;
    warning(['You have selected more than one channel. Please compare your ' ... 
             'selection with the neighbour definitions in 00_settings/general. ' ...
             'Bad channels will exluded from a repairing operation of a ' ...
             'likewise bad neighbour, but each channel should have at least '...
             'two good neighbours.']);
    warning backtrace on;
  end
  fprintf('\n');
  
  if ~isempty(badLabel)
    label = data_raw.FP.part1.label(ismember(data_raw.FP.part1.label, badLabel));
  else
    label = [];
  end
  
  switch i
    case 1
      data_badchan.FP.part1.badChan = label;   
    case 2
      data_badchan.PD.part1.badChan = label;  
    case 3
      data_badchan.PS.part1.badChan = label;  
    case 4
      data_badchan.C.part1.badChan = label;  
    case 5
      data_badchan.FP.part2.badChan = label;  
    case 6
      data_badchan.PD.part2.badChan = label;  
    case 7
      data_badchan.PS.part2.badChan = label;  
    case 8
      data_badchan.C.part2.badChan = label;  
  end
end

end

