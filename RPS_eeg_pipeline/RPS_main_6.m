%% check if basic variables are defined and import segmented data
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '04b_eyecor/';
  cfg.filename  = 'RPS_d01_04b_eyecor';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '04b_eyecor/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RPS_d%d_04b_eyecor_', sessionStr, '.mat'));
  end
end

%% part 6

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bandpass filtering

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '04b_eyecor/');
  cfg.filename    = sprintf('RPS_d%02d_04b_eyecor', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load eye-artifact corrected data...\n\n');
  RPS_loadData( cfg );
  
  filtCoeffDiv = 500 / data_eyecor.FP.part1.fsample;                        % estimate sample frequency dependent divisor of filter length

  % bandpass filter data at 10Hz
  cfg           = [];
  cfg.bpfreq    = [9 11];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  
  data_bpfilt_10Hz = RPS_bpFiltering(cfg, data_eyecor);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('RPS_d%02d_06a_bpfilt10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (10Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_bpfilt_10Hz', data_bpfilt_10Hz);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_10Hz

  % bandpass filter data at 20Hz
  cfg           = [];
  cfg.bpfreq    = [19 21];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  
  data_bpfilt_20Hz = RPS_bpFiltering(cfg, data_eyecor);

  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('RPS_d%02d_06a_bpfilt20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (20Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_bpfilt_20Hz', data_bpfilt_20Hz);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_20Hz data_eyecor 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% hilbert phase calculation

for i = numOfPart
  fprintf('Dyad %d\n', i);
   
  % calculate hilbert phase at 10Hz
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('RPS_d%02d_06a_bpfilt10Hz', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at 10Hz bandpass filtered data...\n');
  RPS_loadData( cfg );
  
  data_hilbert_10Hz = RPS_hilbertPhase(data_bpfilt_10Hz);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('RPS_d%02d_06b_hilbert10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (10Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_hilbert_10Hz', data_hilbert_10Hz);
  fprintf('Data stored!\n\n');
  clear data_hilbert_10Hz data_bpfilt_10Hz
  
  % calculate hilbert phase at 20Hz
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('RPS_d%02d_06a_bpfilt20Hz', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at 20Hz bandpass filtered data...\n');
  RPS_loadData( cfg );
  
  data_hilbert_20Hz = RPS_hilbertPhase(data_bpfilt_20Hz);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('RPS_d%02d_06b_hilbert20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (20Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_hilbert_20Hz', data_hilbert_20Hz);
  fprintf('Data stored!\n\n');
  clear data_hilbert_20Hz data_bpfilt_20Hz
end

%% clear workspace
clear cfg file_path numOfSources sourceList i filtCoeffDiv
