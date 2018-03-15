%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '01a_raw';
  cfg.filename  = 'RPS_d01_01a_raw';
  sessionNum    = RPS_getSessionNum( cfg );
  if sessionNum == 0
    sessionNum = 1;
  end
  sessionStr    = sprintf('%03d', sessionNum);                              % estimate current session number
end

if ~exist('srcPath', 'var')
  srcPath     = '/data/pt_01843/eegData/DualEEG_RPS_rawData/';              % source path to raw data
end

if ~exist('desPath', 'var')
  desPath     = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';        % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([srcPath, '/*_C*.vhdr']);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, 'DualEEG_RPS_C_%d.vhdr');
  end
end

%% part 1
% 1. import data from brain vision eeg files and bring it into an order
% 2. select corrupted channels 
% 3. repair corrupted channels

cprintf([0,0.6,0], '<strong>[1] - Data import and repairing of bad channels</strong>\n');
fprintf('\n');

%% import data from brain vision eeg files %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  cfg             = [];
  cfg.path        = srcPath;
  cfg.dyad        = i;
  cfg.continuous  = 'no';

  fprintf('<strong>Import data of dyad %d</strong> from: %s ...\n', i, cfg.path);
  ft_info off;
  data_raw = RPS_importAllConditions( cfg );
  ft_info on;

  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01a_raw/');
  cfg.filename    = sprintf('RPS_d%02d_01a_raw', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
  
  fprintf('The RAW data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_raw', data_raw);
  fprintf('Data stored!\n\n');
  clear data_raw
end

fprintf('<strong>Repairing of corrupted channels</strong>\n\n');

% Create settings file if not existing
settings_file = [desPath '00_settings/' ...
                  sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(settings_file, 'file') == 2)                                     % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  RPS_createTbl(cfg);                                                       % create settings file
end

% Load settings file
T = readtable(settings_file);
warning off;
T.dyad(numOfPart) = numOfPart;
warning on;

%% repairing of corrupted channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n\n', i);
  
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01a_raw/');
  cfg.filename    = sprintf('RPS_d%02d_01a_raw', i);
  cfg.sessionStr  = sessionStr;
    
  fprintf('Load raw data...\n');
  RPS_loadData( cfg );
  
  % Concatenated raw trials to a continuous stream
  data_continuous = RPS_concatData( data_raw );
  
  fprintf('\n');
  
  % select corrupted channels
  data_badchan = RPS_selectBadChan( data_continuous );
  
  % export the bad channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01b_badchan/');
  cfg.filename    = sprintf('RPS_d%02d_01b_badchan', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Bad channels of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_badchan', data_badchan);
  fprintf('Data stored!\n\n');
  clear data_continuous
  
  % add bad labels of bad channels to the settings file
  if isempty(data_badchan.FP.part1.badChan)
    bChanFPp1 = {'---'};
  else
    bChanFPp1 = {strjoin(data_badchan.FP.part1.badChan,',')};
  end
  if isempty(data_badchan.FP.part2.badChan)
    bChanFPp2 = {'---'};
  else
    bChanFPp2 = {strjoin(data_badchan.FP.part2.badChan,',')};
  end
  if isempty(data_badchan.PD.part1.badChan)
    bChanPDp1 = {'---'};
  else
    bChanPDp1 = {strjoin(data_badchan.PD.part1.badChan,',')};
  end
  if isempty(data_badchan.PD.part2.badChan)
    bChanPDp2 = {'---'};
  else
    bChanPDp2 = {strjoin(data_badchan.PD.part2.badChan,',')};
  end
  if isempty(data_badchan.PS.part1.badChan)
    bChanPSp1 = {'---'};
  else
    bChanPSp1 = {strjoin(data_badchan.PS.part1.badChan,',')};
  end
  if isempty(data_badchan.PS.part2.badChan)
    bChanPSp2 = {'---'};
  else
    bChanPSp2 = {strjoin(data_badchan.PS.part2.badChan,',')};
  end
  if isempty(data_badchan.C.part1.badChan)
    bChanCp1 = {'---'};
  else
    bChanCp1 = {strjoin(data_badchan.C.part1.badChan,',')};
  end
  if isempty(data_badchan.C.part2.badChan)
    bChanCp2 = {'---'};
  else
    bChanCp2 = {strjoin(data_badchan.C.part2.badChan,',')};
  end
  warning off;
  T.bChanFPp1(i) = bChanFPp1;
  T.bChanFPp2(i) = bChanFPp2;
  T.bChanPDp1(i) = bChanPDp1;
  T.bChanPDp2(i) = bChanPDp2;
  T.bChanPSp1(i) = bChanPSp1;
  T.bChanPSp2(i) = bChanPSp2;
  T.bChanCp1(i) = bChanCp1;
  T.bChanCp2(i) = bChanCp2;
  warning on;
  
  % repair corrupted channels
  data_repaired = RPS_repairBadChan( data_badchan, data_raw );
  
  % export the bad channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '01c_repaired/');
  cfg.filename    = sprintf('RPS_d%02d_01c_repaired', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Repaired raw data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_repaired', data_repaired);
  fprintf('Data stored!\n\n');
  clear data_repaired data_raw data_badchan 
end

% store settings table
delete(settings_file);
writetable(T, settings_file);

%% clear workspace
clear file_path cfg sourceList numOfSources i T bChanFPp1 bChanFPp2 ...
      bChanPDp1 bChanPDp2 bChanPSp1 bChanPSp2 bChanCp1 bChanCp2 ...
      settings_file
