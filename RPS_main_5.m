%% check if basic variables are defined and import segmented data
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '08_hilbert/';
  cfg.filename  = 'RPS_p01_08b_hilbert20Hz';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, '08_hilbert/'), ...
                       strcat('*20Hz_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RPS_p%d_08b_hilbert20Hz_', sessionStr, '.mat'));
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% general adjustment
selection = false;
while selection == false
  cprintf([0,0.6,0], 'Should rejection of detected artifacts be applied before PLV estimation?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    artifactRejection = true;
  elseif strcmp('n', x)
    selection = true;
    artifactRejection = false;
  else
    selection = false;
  end
end
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% PLV and mPLV calculation

for i = numOfPart
  fprintf('Dyad %d\n', i);
  
  if artifactRejection == true                                              % load artifact definitions
    cfg             = [];
    cfg.srcFolder   = strcat(desPath, '06_allArt/');
    cfg.filename    = sprintf('RPS_p%02d_06_allArt', i);
    cfg.sessionStr  = sessionStr;
  
    file_path = strcat(cfg.srcFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
    if ~isempty(dir(file_path))
      fprintf('\nLoading %s ...\n', file_path);
      RPS_loadData( cfg );                                                  
      artifactAvailable = true;     
    else
      fprintf('File %s is not existent,\n', file_path);
      fprintf('Artifact rejection is not possible!\n');
      artifactAvailable = false;
    end
  end             
  
  cfg             = [];                                                     % load hilbert phase data
  cfg.srcFolder   = strcat(desPath, '08_hilbert/');
  cfg.sessionStr  = sessionStr;
  
  cfg.filename    = sprintf('RPS_p%02d_08a_hilbert10Hz', i);
  fprintf('Load hilbert phase data at 10 Hz...\n');
  RPS_loadData( cfg );
  
  cfg.filename    = sprintf('RPS_p%02d_08b_hilbert20Hz', i);
  fprintf('Load hilbert phase data at 20 Hz...\n');
  RPS_loadData( cfg );
  
  if artifactRejection == true                                              % artifact rejection
    if artifactAvailable == true
      cfg           = [];
      cfg.artifact  = cfg_allArt;
  
      fprintf('Artifact Rejection of Hilbert phase data at 10 Hz.\n');
      data_hilbert_10Hz = RPS_rejectArtifacts(cfg, data_hilbert_10Hz);
      fprintf('\n');
      
      fprintf('Artifact Rejection of Hilbert phase data at 20 Hz.\n');
      data_hilbert_20Hz = RPS_rejectArtifacts(cfg, data_hilbert_20Hz);
      fprintf('\n');
      
      clear cfg_allArt
    end
  end
  
  % calculate PLV and meanPLV at 10Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 1;                                                        % window length for one PLV value in seconds
  
  data_plv_10Hz  = RPS_phaseLockVal(cfg, data_hilbert_10Hz);
  data_mplv_10Hz = RPS_calcMeanPLV(data_plv_10Hz);
  clear data_hilbert_10Hz
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '09_plv/');
  cfg.filename    = sprintf('RPS_p%02d_09a_plv10Hz', i);
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
  cfg.desFolder   = strcat(desPath, '10_mplv/');
  cfg.filename    = sprintf('RPS_p%02d_10a_mplv10Hz', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs (10Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_mplv_10Hz', data_mplv_10Hz);
  fprintf('Data stored!\n\n');
  clear data_mplv_10Hz
  
  % calculate PLV and meanPLV at 20Hz %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cfg           = [];
  cfg.winlen    = 1;                                                        % window length for one PLV value in seconds
  
  data_plv_20Hz  = RPS_phaseLockVal(cfg, data_hilbert_20Hz);
  data_mplv_20Hz = RPS_calcMeanPLV(data_plv_20Hz);
  clear data_hilbert_20Hz
  
  % export the PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '09_plv/');
  cfg.filename    = sprintf('RPS_p%02d_09b_plv20Hz', i);
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
  cfg.desFolder   = strcat(desPath, '10_mplv/');
  cfg.filename    = sprintf('RPS_p%02d_10b_mplv20Hz', i);
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
      artifactAvailable x selection
