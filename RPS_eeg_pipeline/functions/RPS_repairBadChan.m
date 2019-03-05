function [ data_repaired ] = RPS_repairBadChan( data_badchan, data_eyecor )
% RPS_REPAIRBADCHAN can be used for repairing previously selected bad
% channels. For repairing this function uses the weighted neighbour
% approach.
%
% Use as
%   [ data_repaired ] = RPS_repairBadChan( data_badchan, data_eyecor )
%
% where data_badchan has to be the result of RPS_SELECTBADCHAN.
%
% Used layout and neighbour definitions:
%   mpi_customized_acticap32.mat
%   mpi_customized_acticap32_neighb.mat
%
% The function requires the fieldtrip toolbox
%
% SEE also FT_CHANNELREPAIR

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Load layout and neighbour definitions
% -------------------------------------------------------------------------
load('mpi_002_customized_acticap32_neighb.mat', 'neighbours');
load('mpi_002_customized_acticap32.mat', 'lay');

% -------------------------------------------------------------------------
% Configure Repairing
% -------------------------------------------------------------------------
cfg               = [];
cfg.method        = 'weighted';
cfg.neighbours    = neighbours;
cfg.layout        = lay;
cfg.trials        = 'all';
cfg.showcallinfo  = 'no';

% -------------------------------------------------------------------------
% Repairing bad channels
% -------------------------------------------------------------------------
for i = 1:1:8
  switch i
    case 1
      fprintf('<strong>Repairing bad channels of participant 1...</strong>\n');
      fprintf('<strong>Condition FreePlay...</strong>\n');
      data = data_eyecor.FP.part1;
      cfg.missingchannel = data_badchan.FP.part1.badChan;
    case 2
      fprintf('<strong>Condition PredDiff...</strong>\n');
      data = data_eyecor.PD.part1;
      cfg.missingchannel = data_badchan.PD.part1.badChan;
    case 3
      fprintf('<strong>Condition PredSame...</strong>\n');
      data = data_eyecor.PS.part1;
      cfg.missingchannel = data_badchan.PS.part1.badChan;
    case 4
      fprintf('<strong>Condition Control...</strong>\n');
      data = data_eyecor.C.part1;
      cfg.missingchannel = data_badchan.C.part1.badChan;
    case 5
      fprintf('<strong>Repairing bad channels of participant 2...</strong>\n');
      fprintf('<strong>Condition FreePlay...</strong>\n');
      data = data_eyecor.FP.part2;
      cfg.missingchannel = data_badchan.FP.part2.badChan;
    case 6
      fprintf('<strong>Condition PredDiff...</strong>\n');
      data = data_eyecor.PD.part2;
      cfg.missingchannel = data_badchan.PD.part2.badChan;
    case 7
      fprintf('<strong>Condition PredSame...</strong>\n');
      data = data_eyecor.PS.part2;
      cfg.missingchannel = data_badchan.PS.part2.badChan;
    case 8
      fprintf('<strong>Condition Control...</strong>\n');
      data = data_eyecor.C.part2;
      cfg.missingchannel = data_badchan.C.part2.badChan;      
  end
  
  if isempty(cfg.missingchannel)
    fprintf('All channels are good, no repairing operation required!\n');
  else
    ft_warning off;
    data = ft_channelrepair(cfg, data);
    ft_warning on;
    data = removefields(data, {'elec'});
  end
  fprintf('\n');

  label = [lay.label; {'EOGV'; 'EOGH'}];
  data = correctChanOrder( data, label);

% -------------------------------------------------------------------------
% Copy result into output structure
% -------------------------------------------------------------------------
  switch i
    case 1
      data_repaired.FP.part1  = data;
    case 2
      data_repaired.PD.part1  = data;
    case 3
      data_repaired.PS.part1  = data;
    case 4
      data_repaired.C.part1   = data;
    case 5
      data_repaired.FP.part2  = data;
    case 6
      data_repaired.PD.part2  = data;
    case 7
      data_repaired.PS.part2  = data;
    case 8
      data_repaired.C.part2   = data;
  end  
end

fprintf('\n');

end

% -------------------------------------------------------------------------
% Local function - move corrected channel to original position
% -------------------------------------------------------------------------
function [ dataTmp ] = correctChanOrder( dataTmp, label )

[~, pos]  = ismember(label, dataTmp.label);
pos       = pos(~ismember(pos, 0));
 
dataTmp.label = dataTmp.label(pos);
dataTmp.trial = cellfun(@(x) x(pos, :), dataTmp.trial, 'UniformOutput', false);

end
