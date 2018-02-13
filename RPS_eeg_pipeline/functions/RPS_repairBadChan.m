function [ data_repaired ] = RPS_repairBadChan( data_badchan, data_raw )
%RPS_REPAIRBADCHAN 

load('mpi_002_customized_acticap32_neighb.mat', 'neighbours');
load('mpi_002_customized_acticap32.mat', 'lay');

cfg               = [];
cfg.method        = 'weighted';
cfg.neighbours    = neighbours;
cfg.layout        = lay;
cfg.trials        = 'all';
cfg.showcallinfo  = 'no';

fprintf('Repairing bad channels of participant 1...\n');
fprintf('Condition FreePlay...\n');
if isempty(data_badchan.FP.part1.badChan)
  fprintf('All channels are good, no repairing operation required!\n');
  data_repaired.FP.part1 = data_raw.FP.part1;
else
  cfg.badchannel = data_badchan.FP.part1.badChan;
  data_repaired.FP.part1 = ft_channelrepair(cfg, data_raw.FP.part1);
end
fprintf('Condition PredDiff...\n');
if isempty(data_badchan.PD.part1.badChan)
  fprintf('All channels are good, no repairing operation required!\n');
  data_repaired.PD.part1 = data_raw.PD.part1;
else
  cfg.badchannel = data_badchan.PD.part1.badChan;
  data_repaired.PD.part1 = ft_channelrepair(cfg, data_raw.PD.part1);
end
fprintf('Condition PredSame...\n');
if isempty(data_badchan.PS.part1.badChan)
  fprintf('All channels are good, no repairing operation required!\n');
  data_repaired.PS.part1 = data_raw.PS.part1;
else
  cfg.badchannel = data_badchan.PS.part1.badChan;
  data_repaired.PS.part1 = ft_channelrepair(cfg, data_raw.PS.part1);
end
fprintf('Condition Control...\n');
if isempty(data_badchan.C.part1.badChan)
  fprintf('All channels are good, no repairing operation required!\n');
  data_repaired.C.part1 = data_raw.C.part1;
else
  cfg.badchannel = data_badchan.C.part1.badChan;
  data_repaired.C.part1 = ft_channelrepair(cfg, data_raw.C.part1);
end

fprintf('\nRepairing bad channels of participant 2...\n');
fprintf('Condition FreePlay...\n');
if isempty(data_badchan.FP.part2.badChan)
  fprintf('All channels are good, no repairing operation required!\n');
  data_repaired.FP.part2 = data_raw.FP.part2;
else
  cfg.badchannel = data_badchan.FP.part2.badChan;
  data_repaired.FP.part2 = ft_channelrepair(cfg, data_raw.FP.part2);
end
fprintf('Condition PredDiff...\n');
if isempty(data_badchan.PD.part2.badChan)
  fprintf('All channels are good, no repairing operation required!\n');
  data_repaired.PD.part2 = data_raw.PD.part2;
else
  cfg.badchannel = data_badchan.PD.part2.badChan;
  data_repaired.PD.part2 = ft_channelrepair(cfg, data_raw.PD.part2);
end
fprintf('Condition PredSame...\n');
if isempty(data_badchan.PS.part2.badChan)
  fprintf('All channels are good, no repairing operation required!\n');
  data_repaired.PS.part2 = data_raw.PS.part2;
else
  cfg.badchannel = data_badchan.PS.part2.badChan;
  data_repaired.PS.part2 = ft_channelrepair(cfg, data_raw.PS.part2);
end
fprintf('Condition Control...\n');
if isempty(data_badchan.C.part2.badChan)
  fprintf('All channels are good, no repairing operation required!\n');
  data_repaired.C.part2 = data_raw.C.part2;
else
  cfg.badchannel = data_badchan.C.part2.badChan;
  data_repaired.C.part2 = ft_channelrepair(cfg, data_raw.C.part2);
end

fprintf('\n');

end

