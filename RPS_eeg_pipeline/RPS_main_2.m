%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '01c_repaired';
  cfg.filename  = 'RPS_d01_01c_repaired';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath     = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';        % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '01c_repaired/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RPS_d%d_01c_repaired_', sessionStr, '.mat'));
  end
end

%% part 2
% preprocess the raw data
% export the preprocessed data into a *.mat file

cprintf([0,0.6,0], '<strong>[2] - Preprocessing, filtering, re-referencing</strong>\n');
fprintf('\n');

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Please select sampling rate for preprocessing:\n');
  fprintf('[1] - 500 Hz (original sampling rate)\n');
  fprintf('[2] - 250 Hz (downsampling factor 2)\n');
  fprintf('[3] - 125 Hz (downsampling factor 4)\n');
  x = input('Option: ');

  switch x
    case 1
      selection = true;
      samplingRate = 500;
    case 2
      selection = true;
      samplingRate = 250;
    case 3
      selection = true;
      samplingRate = 125;
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end
fprintf('\n');

selection = false;
while selection == false
  cprintf([0,0.6,0], 'Please select favoured reference:\n');
  fprintf('[1] - Linked mastoid (''TP9'', ''TP10'')\n');
  fprintf('[2] - Common average reference\n');
  x = input('Option: ');

  switch x
    case 1
      selection = true;
      refchannel = 'TP10';
      reference = {'LM'};
    case 2
      selection = true;
      refchannel = {'all', '-V1', '-V2'};
      reference = {'CAR'};
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end
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

% Write selected settings to settings file
file_path = [desPath '00_settings/' sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(file_path, 'file') == 2)                                         % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  RPS_createTbl(cfg);                                                       % create settings file
end

T = readtable(file_path);                                                   % update settings table
warning off;
T.fsample(numOfPart) = samplingRate;
T.reference(numOfPart) = reference;
T.bandpass(numOfPart) = bandpass;
T.lineNoiseFilt(numOfPart) = lineNoiseFilt;
warning on;
delete(file_path);
writetable(T, file_path);

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '01c_repaired/');
  cfg.filename    = sprintf('RPS_d%02d_01c_repaired', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('<strong>Dyad %d</strong>\n', i);
  fprintf('Load repaired raw data...\n');
  RPS_loadData( cfg );
  
  cfg                   = [];
  cfg.bpfreq            = bpRange;                                          % passband from 1 to either 48 or 200 Hz
  cfg.bpfilttype        = 'but';
  cfg.bpinstabilityfix  = 'split';
  cfg.dftfilter         = lnRemoval;                                        % dft filter for additional line noise removal
  cfg.dftfreq           = [50 100 150];
  cfg.samplingRate      = samplingRate;
  cfg.refchannel        = refchannel;
  
  ft_info off;
  data_preproc = RPS_preprocessing( cfg, data_repaired);
  ft_info on;
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('RPS_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The preprocessed data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_preproc', data_preproc);
  fprintf('Data stored!\n\n');
  clear data_preproc data_repaired 
end

%% clear workspace
clear file_path cfg sourceList numOfSources i selection samplingRate x ...
      refchannel reference T bandpass bpRange lineNoiseFilt lnRemoval
