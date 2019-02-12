%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '01a_raw';
  cfg.filename  = 'RPS_d01_01a_raw';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath     = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';        % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '01a_raw/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RPS_d%d_01a_raw_', sessionStr, '.mat'));
  end
end

%% part 2
% 1. select bad/noisy channels
% 2. filter the good channels (basic bandpass filtering)

cprintf([0,0.6,0], '<strong>[2] - Preproc I: bad channel detection, filtering</strong>\n');
fprintf('\n');

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Please select your favoured bandpass for preprocessing:\n');
  fprintf('[1] - Regular bandpass 1...48 Hz \n');
  fprintf('[2] - Extended bandpass 1...98 Hz with dft filter for line noise removal\n');
  x = input('Option: ');

  switch x
    case 1
      selection = true;
      bpRange = [1 48];
      bandpass = {'[1 48]'};
      lnRemoval = 'no';
      lineNoiseFilt = {'n'};
    case 2
      selection = true;
      bpRange = [1 98];
      bandpass = {'[1 98]'};
      lnRemoval = 'yes';
      lineNoiseFilt = {'y'};
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end
fprintf('\n');

% Create settings file if not existing
settings_file = [desPath '00_settings/' sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(settings_file, 'file') == 2)                                     % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  RPS_createTbl(cfg);                                                       % create settings file
end

% Load settings file
T = readtable(settings_file);                                               % update settings table
warning off;
T.bandpass(numOfPart) = bandpass;
T.lineNoiseFilt(numOfPart) = lineNoiseFilt;
warning on;

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n\n', i);

  %% selection of corrupted channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Selection of corrupted channels</strong>\n\n');

  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01a_raw/');
  cfg.filename    = sprintf('RPS_d%02d_01a_raw', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load raw data...\n');
  RPS_loadData( cfg );

  % concatenated raw trials to a continuous stream
  data_continuous = RPS_concatData( data_raw );

  fprintf('\n');

  % detect noisy channels automatically
  data_noisy = RPS_estNoisyChan( data_continuous );

  fprintf('\n');

  % select corrupted channels
  data_badchan = RPS_selectBadChan( data_continuous, data_noisy );
  clear data_noisy

  % export the bad channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02a_badchan/');
  cfg.filename    = sprintf('RPS_d%02d_02a_badchan', i);
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

  % store settings table
  delete(settings_file);
  writetable(T, settings_file);
  
  %% basic bandpass filtering of good channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Basic preprocessing of good channels</strong>\n');

  cfg                   = [];
  cfg.bpfreq            = bpRange;                                          % passband from 1 to either 48 or 98 Hz
  cfg.bpfilttype        = 'but';
  cfg.bpinstabilityfix  = 'split';
  cfg.dftfilter         = lnRemoval;                                        % dft filter for additional line noise removal
  cfg.dftfreq           = [50 100 150];
  cfg.part1BadChan.FP   = data_badchan.FP.part1.badChan;
  cfg.part1BadChan.PD   = data_badchan.PD.part1.badChan;
  cfg.part1BadChan.PS   = data_badchan.PS.part1.badChan;
  cfg.part1BadChan.C    = data_badchan.C.part1.badChan;
  cfg.part2BadChan.FP   = data_badchan.FP.part2.badChan;
  cfg.part2BadChan.PD   = data_badchan.PD.part2.badChan;
  cfg.part2BadChan.PS   = data_badchan.PS.part2.badChan;
  cfg.part2BadChan.C    = data_badchan.C.part2.badChan;
  
  ft_info off;
  data_preproc1 = RPS_preprocessing( cfg, data_raw);
  ft_info on;
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02b_preproc1/');
  cfg.filename    = sprintf('RPS_d%02d_02b_preproc1', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The bandbass filtered data of dyad %d will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_preproc1', data_preproc1);
  fprintf('Data stored!\n\n');
  clear data_preproc1 data_raw data_badchan
end

%% clear workspace
clear file_path cfg sourceList numOfSources i selection x T ...
      bandpass bpRange lineNoiseFilt lnRemoval bChanFPp1 bChanFPp2 ...
      bChanPDp1 bChanPDp2 bChanPSp1 bChanPSp2 bChanCp1 bChanCp2 ...
      settings_file
