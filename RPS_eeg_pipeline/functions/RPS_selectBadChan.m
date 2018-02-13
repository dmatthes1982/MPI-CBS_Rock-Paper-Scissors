function [ data_badchan ] = RPS_selectBadChan( data_raw )
% RPS_SELECTBADCHAN 

participants  = [1,1,1,1,2,2,2,2];
conditions    = [1,2,3,4,1,2,3,4];

for i = 1:1:8
  cfg           = [];
  cfg.ylim      = [-200 200];
  cfg.blocksize = 120;
  cfg.part      = participants(i);
  cfg.condition = conditions(i);
  
  fprintf('Select bad channels of participant %d in condition %d...\n', ...
          cfg.part, cfg.condition);
  RPS_databrowser( cfg, data_raw );
  badLabel = RPS_channelCheckbox();
  close(gcf);
  
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

