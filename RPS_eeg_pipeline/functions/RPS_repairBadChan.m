function [ data_repaired ] = RPS_repairBadChan( data_badchan, data_raw )
% RPS_REPAIRBADCHAN can be used for repairing previously selected bad
% channels. For repairing this function uses the weighted neighbour
% approach. After the repairing operation, the result will be displayed in
% the fieldtrip databrowser for verification purpose.
%
% Use as
%   [ data_repaired ] = RPS_repairBadChan( data_badchan, data_raw )
%
% where data_raw has to be raw data and data_badchan the result of
% RPS_SELECTBADCHAN.
%
% Used layout and neighbour definitions:
%   mpi_customized_acticap32.mat
%   mpi_customized_acticap32_neighb.mat
%
% The function requires the fieldtrip toolbox
%
% SEE also RPS_DATABROWSER and FT_CHANNELREPAIR

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
      fprintf('Repairing bad channels of participant 1...\n');
      fprintf('Condition FreePlay...\n');
      data = data_raw.FP.part1;
      cfg.badchannel = data_badchan.FP.part1.badChan;
    case 2
      fprintf('Condition PredDiff...\n');
      data = data_raw.PD.part1;
      cfg.badchannel = data_badchan.PD.part1.badChan;
    case 3
      fprintf('Condition PredSame...\n');
      data = data_raw.PS.part1;
      cfg.badchannel = data_badchan.PS.part1.badChan;
    case 4
      fprintf('Condition Control...\n');
      data = data_raw.C.part1;
      cfg.badchannel = data_badchan.C.part1.badChan;
    case 5
      fprintf('\nRepairing bad channels of participant 2...\n');
      fprintf('Condition FreePlay...\n');
      data = data_raw.FP.part2;
      cfg.badchannel = data_badchan.FP.part2.badChan;
    case 6
      fprintf('Condition PredDiff...\n');
      data = data_raw.PD.part2;
      cfg.badchannel = data_badchan.PD.part2.badChan;
    case 7
      fprintf('Condition PredSame...\n');
      data = data_raw.PS.part2;
      cfg.badchannel = data_badchan.PS.part2.badChan;
    case 8
      fprintf('Condition Control...\n');
      data = data_raw.C.part2;
      cfg.badchannel = data_badchan.C.part2.badChan;      
  end
  
  if isempty(cfg.badchannel)
    fprintf('All channels are good, no repairing operation required!\n');
  else
    data = ft_channelrepair(cfg, data);
    data = removefields(data, {'elec'});
    
    cfgView               = [];
    cfgView.ylim          = [-200 200];
    cfgView.blocksize     = 120;
    cfgView.viewmode      = 'vertical';
    cfgView.continuous    = 'yes';
    cfgView.channel       = 'all';
    cfgView.showcallinfo  = 'no';
    if i < 5
      part = 1;
    else
      part = 2;
    end
    
    fprintf('\nVerification view for participant %d...\n', part);
    ft_warning off;
    ft_databrowser( cfgView, data );
    commandwindow;                                                            % set focus to commandwindow
    input('Press enter to continue!:');
    close(gcf);
    ft_warning on;
  end
  
  switch i
    case 1
      data_repaired.FP.part1 = data;
    case 2
      data_repaired.PD.part1 = data;
    case 3
      data_repaired.PS.part1 = data;
    case 4
      data_repaired.C.part1 = data;
    case 5
      data_repaired.FP.part2 = data;
    case 6
      data_repaired.PD.part2 = data;
    case 7
      data_repaired.PS.part2 = data;
    case 8
      data_repaired.C.part2 = data;
  end  
end

fprintf('\n');

end
