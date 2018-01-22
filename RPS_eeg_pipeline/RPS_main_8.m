%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subfolder = '04b_eyecor';
  cfg.filename  = 'RPS_d01_04b_eyecor';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';            % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in eyecor data folder
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

%% part 9
% Calculate TFRs of the EOG-artifact corrected data

for i = numOfPart
  fprintf('Dyad %d\n', i);
  
  cfg             = [];                                                     % load EOG-artifact corrected data
  cfg.srcFolder   = strcat(desPath, '04b_eyecor/');
  cfg.filename    = sprintf('RPS_d%02d_04b_eyecor', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load eye-artifact corrected data...\n\n');
  RPS_loadData( cfg );

  cfg         = [];
  cfg.foi     = 2:1:50;                                                     % frequency of interest
  cfg.toi     = 0:0.5:3;                                                    % time of interest
  
  data_tfr = RPS_timeFreqanalysis( cfg, data_eyecor );
  
  % export TFR data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '08a_tfr/');
  cfg.filename    = sprintf('RPS_d%02d_08a_tfr', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Time-frequency response data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_tfr', data_tfr);
  fprintf('Data stored!\n\n');
  clear data_tfr data_eyecor
end

%% clear workspace
clear file_path cfg sourceList numOfSources i
