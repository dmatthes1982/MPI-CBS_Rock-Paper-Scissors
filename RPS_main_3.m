%% check if basic variables are defined and import preprocessed data
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '02_preproc/';
  cfg.filename  = 'RPS_p01_02_preproc';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in raw data folder
  sourceList    = dir([strcat(desPath, '02_preproc/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RPS_p%d_02_preproc_', sessionStr, '.mat'));
  end
end

%% segmentation of the preprocessed trials
% split the data of every condition into subtrials with a length of 5 secs
% export the segmented data into a *.mat file

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('RPS_p%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load preproc data...\n');
  RPS_loadData( cfg );
  
  data_seg1  = RPS_segmentation( data_preproc );
  
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04_seg1/');
  cfg.filename    = sprintf('RPS_p%02d_04_seg1', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The segmented data of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_seg1', data_seg1);
  fprintf('Data stored!\n\n');
  clear data_seg1 data_preproc

end

%% clear workspace
clear file_path numOfSources sourceList cfg i
