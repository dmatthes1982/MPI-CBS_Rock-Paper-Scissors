function [ data_badchan ] = RPS_selectBadChan( data_raw, data_noisy )
% RPS_SELECTBADCHAN can be used for selecting bad channels visually. The
% data will be presented in two different ways. The first fieldtrip
% databrowser view shows the time course of each channel. The second view
% shows the total power of each channel and is highlighting outliers. The
% bad channels can be marked within the JAI_CHANNELCHECKBOX gui.
%
% Use as
%   [ data_badchan ] = RPS_selectBadChan( data_raw, data_noisy )
%
% where the first input has to be concatenated raw data and second one has
% to be the rsult of JAI_ESTNOISYCHAN.
%
% The function requires the fieldtrip toolbox
%
% SEE also JAI_DATABROWSER, JAI_ESTNOISYCHAN and JAI_CHANNELCHECKBOX

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Check data
% -------------------------------------------------------------------------
if numel(data_raw.FP.part1.trialinfo) ~= 1 || numel(data_raw.FP.part2.trialinfo) ~= 1
  error('First dataset has more than one trial. Data has to be concatenated!');
end

if ~isfield(data_noisy.FP.part1, 'totalpow')
  error('Second dataset has to be the result of JAI_ESTNOISYCHAN!');
end

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
  cfg.blocksize   = 60;
  cfg.part        = participants(i);
  cfg.condition   = conditions(i);
  cfg.plotevents  = 'no';

% -------------------------------------------------------------------------
% Selection of bad channels
% -------------------------------------------------------------------------
  fprintf('<strong>Select bad channels of participant %d in condition %s...</strong>\n', ...
          participants(i), condString{i});
  RPS_easyTotalPowerBarPlot( cfg, data_noisy );
  fig = gcf;                                                                % default position is [560 528 560 420]
  fig.Position = [0 528 560 420];                                           % --> first figure will be placed on the left side of figure 2
  RPS_databrowser( cfg, data_raw );
  badLabel = RPS_channelCheckbox();
  close(gcf);                                                               % close also databrowser view when the channelCheckbox will be closed
  close(gcf);                                                               % close also total power diagram when the channelCheckbox will be closed
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
      data_badchan.FP.part1         = data_noisy.FP.part1;
      data_badchan.FP.part1.badChan = label;   
    case 2
      data_badchan.PD.part1         = data_noisy.PD.part1;
      data_badchan.PD.part1.badChan = label;  
    case 3
      data_badchan.PS.part1         = data_noisy.PS.part1;
      data_badchan.PS.part1.badChan = label;  
    case 4
      data_badchan.C.part1          = data_noisy.C.part1;
      data_badchan.C.part1.badChan  = label;
    case 5
      data_badchan.FP.part2         = data_noisy.FP.part2;
      data_badchan.FP.part2.badChan = label;  
    case 6
      data_badchan.PD.part2         = data_noisy.PD.part2;
      data_badchan.PD.part2.badChan = label;  
    case 7
      data_badchan.PS.part2         = data_noisy.PS.part2;
      data_badchan.PS.part2.badChan = label;  
    case 8
      data_badchan.C.part2          = data_noisy.C.part2;
      data_badchan.C.part2.badChan  = label;
  end
end

end

