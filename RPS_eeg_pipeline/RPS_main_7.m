%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '06b_hilbert/';
  cfg.filename  = 'RPS_d01_06b_hilbert20Hz';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '06b_hilbert/'), ...
                       strcat('*20Hz_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RPS_d%d_06b_hilbert20Hz_', sessionStr, '.mat'));
  end
end

%% part 7

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% general adjustment
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Should rejection of detected artifacts be applied before PLV estimation?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    artifactRejection = true;
  elseif strcmp('n', x)
    choise = true;
    artifactRejection = false;
  else
    choise = false;
  end
end
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Segmentation and Artifact rejection

for i = numOfPart
  fprintf('Dyad %d\n\n', i);
  
  % 10 Hz branch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg             = [];                                                     % load hilbert phase data
  cfg.srcFolder   = strcat(desPath, '06b_hilbert/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('RPS_d%02d_06b_hilbert10Hz', i);
  fprintf('Load hilbert phase data at 10 Hz...\n');
  RPS_loadData( cfg );
  
  cfg           = [];
  cfg.length    = 1;
  cfg.overlap   = 0;
 
  fprintf('Segmentation of Hilbert phase data at 10 Hz.\n');
  data_hseg_10Hz  = RPS_segmentation( cfg, data_hilbert_10Hz );
  
  % export the segmented hilbert (10 Hz) data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07a_hseg/');
  cfg.filename    = sprintf('RPS_d%02d_07a_hseg10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The segmented hilbert data (10Hz) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_hseg_10Hz', data_hseg_10Hz);
  fprintf('Data stored!\n\n');
  clear data_hseg_10Hz data_hilbert_10Hz
  
  % 20 Hz branch %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg             = [];                                                     % load hilbert phase data
  cfg.srcFolder   = strcat(desPath, '06b_hilbert/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('RPS_d%02d_06b_hilbert20Hz', i);
  fprintf('Load hilbert phase data at 20 Hz...\n');
  RPS_loadData( cfg );
  
  cfg           = [];
  cfg.length    = 1;
  cfg.overlap   = 0;
  
  fprintf('Segmentation of Hilbert phase data at 20 Hz.\n');
  data_hseg_20Hz  = RPS_segmentation( cfg, data_hilbert_20Hz );
  
  % export the segmented hilbert (10 Hz, 20 Hz) data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07a_hseg/');  
  cfg.filename    = sprintf('RPS_d%02d_07a_hseg20Hz', i);
  cfg.sessionStr  = sessionStr;
  
  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('The segmented hilbert data (20Hz) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_hseg_20Hz', data_hseg_20Hz);
  fprintf('Data stored!\n\n');
  clear data_hseg_20Hz data_hilbert_20Hz
    
  % Load Artifact definitions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if artifactRejection == true                                              % load artifact definitions
    cfg             = [];
    cfg.srcFolder   = strcat(desPath, '05b_allart/');
    cfg.filename    = sprintf('RPS_d%02d_05b_allart', i);
    cfg.sessionStr  = sessionStr;
  
    file_path = strcat(cfg.srcFolder, cfg.filename, '_', cfg.sessionStr,...
                     '.mat');
    if ~isempty(dir(file_path))
      fprintf('Loading %s ...\n', file_path);
      RPS_loadData( cfg );                                                  
      artifactAvailable = true;     
    else
      fprintf('File %s is not existent,\n', file_path);
      fprintf('Artifact rejection is not possible!\n');
      artifactAvailable = false;
    end
  fprintf('\n');
  end
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %% artifact rejection, PLV and mPLV calculation
  % load segmented hilbert phase data at 10 Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '07a_hseg/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('RPS_d%02d_07a_hseg10Hz', i);
  fprintf('Load segmented hilbert data at 10 Hz...\n');
  RPS_loadData( cfg );
  
  % artifact rejection at 10 Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if artifactRejection == true
    if artifactAvailable == true
      cfg           = [];
      cfg.artifact  = cfg_allart;
      cfg.reject    = 'complete';
      cfg.target    = 'dual';
  
      fprintf('Artifact Rejection of Hilbert phase data at 10 Hz.\n');
      data_hseg_10Hz = RPS_rejectArtifacts(cfg, data_hseg_10Hz);
      fprintf('\n');
    end
  end
  
  % calculate PLV and meanPLV at 10Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 1;                                                        % window length for one PLV value in seconds
  
  data_plv_10Hz  = RPS_phaseLockVal(cfg, data_hseg_10Hz);
  data_mplv_10Hz = RPS_calcMeanPLV(data_plv_10Hz);
  clear data_hseg_10Hz
  
  % export number of good trials into a spreadsheet
  cfg           = [];
  cfg.desFolder = [desPath '00_settings/'];
  cfg.dyad = i;
  cfg.type = 'plv';
  cfg.param = '10Hz';
  cfg.sessionStr = sessionStr;
  RPS_writeTbl(cfg, data_plv_10Hz);
    
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07b_plv/');
  cfg.filename    = sprintf('RPS_d%02d_07b_plv10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving PLVs (10Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_plv_10Hz', data_plv_10Hz);
  fprintf('Data stored!\n');
  clear data_plv_10Hz
  
  % export the mean PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07c_mplv/');
  cfg.filename    = sprintf('RPS_d%02d_07c_mplv10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs (10Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_mplv_10Hz', data_mplv_10Hz);
  fprintf('Data stored!\n\n');
  clear data_mplv_10Hz
  
  % load segmented hilbert phase data at 20 Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '07a_hseg/');
  cfg.sessionStr  = sessionStr;
  cfg.filename    = sprintf('RPS_d%02d_07a_hseg20Hz', i);
  fprintf('Load segmented hilbert data at 20 Hz...\n');
  RPS_loadData( cfg );
  
  % artifact rejection at 20 Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if artifactRejection == true
    if artifactAvailable == true
      cfg           = [];
      cfg.artifact  = cfg_allart;
      cfg.reject    = 'complete';
      cfg.target    = 'dual';
      
      fprintf('Artifact Rejection of Hilbert phase data at 20 Hz.\n');
      data_hseg_20Hz = RPS_rejectArtifacts(cfg, data_hseg_20Hz);
      fprintf('\n');
      
      clear cfg_allart
    end
  end
  % calculate PLV and meanPLV at 20Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 1;                                                        % window length for one PLV value in seconds
  
  data_plv_20Hz  = RPS_phaseLockVal(cfg, data_hseg_20Hz);
  data_mplv_20Hz = RPS_calcMeanPLV(data_plv_20Hz);
  clear data_hseg_20Hz
  
  % export number of good trials into a spreadsheet
  cfg           = [];
  cfg.desFolder = [desPath '00_settings/'];
  cfg.dyad = i;
  cfg.type = 'plv';
  cfg.param = '20Hz';
  cfg.sessionStr = sessionStr;
  RPS_writeTbl(cfg, data_plv_20Hz);
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07b_plv/');
  cfg.filename    = sprintf('RPS_d%02d_07b_plv20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving PLVs (20Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_plv_20Hz', data_plv_20Hz);
  fprintf('Data stored!\n');
  clear data_plv_20Hz
  
  % export the mean PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '07c_mplv/');
  cfg.filename    = sprintf('RPS_d%02d_07c_mplv20Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs (20Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_mplv_20Hz', data_mplv_20Hz);
  fprintf('Data stored!\n\n');
  clear data_mplv_20Hz
end

%% clear workspace
clear cfg file_path sourceList numOfSources i artifactRejection ...
      artifactAvailable x choise
