%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '02_preproc/';
  cfg.filename  = 'RPS_d01_02_preproc';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';            % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in preprocessed data folder
  sourceList    = dir([strcat(desPath, '02_preproc/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RPS_d%d_02_preproc_', sessionStr, '.mat'));
  end
end

%% part 3
% ICA decomposition
% Processing steps:
% 1. Concatenated preprocessed trials to a continuous stream
% 2. Detect and reject transient artifacts (200uV delta within 200 ms. 
%    The window is shifted with 100 ms, what means 50 % overlapping.)
% 3. Concatenated cleaned data to a continuous stream
% 4. ICA decomposition
% 5. Extract EOG channels from the cleaned continuous data

for i = numOfPart
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02_preproc/');
  cfg.filename    = sprintf('RPS_d%02d_02_preproc', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Dyad %d\n', i);
  fprintf('Load preprocessed data...\n');
  RPS_loadData( cfg );
  
  % Concatenated preprocessed trials to a continuous stream
  data_continuous = RPS_concatData( data_preproc );
  
  clear data_preproc
  fprintf('\n');
  
  % Detect and reject transient artifacts (200uV delta within 200 ms. 
  % The window is shifted with 100 ms, what means 50 % overlapping.)
  cfg         = [];
  cfg.length  = 200;                                                        % window length: 200 msec        
  cfg.overlap = 50;                                                         % 50 % overlapping
  trl         = RPS_genTrl(cfg, data_continuous);                           % define artifact detection intervals
  
  cfg             = [];
  cfg.channel     = {'all', '-EOGV', '-EOGH', '-REF'};                      % use all channels for transient artifact detection expect EOGV, EOGH and REF
  cfg.continuous  = 'yes';
  cfg.trl         = trl; 
  cfg.method      = 1;                                                      % method: range
  cfg.range       = 200;                                                    % 200 uV
   
  cfg_autoart     = RPS_autoArtifact(cfg, data_continuous);
  
  clear trl
   
  cfg           = [];
  cfg.artifact  = cfg_autoart;
  cfg.reject    = 'partial';                                                % partial rejection
  cfg.target    = 'single';                                                 % target of rejection
  
  data_cleaned  = RPS_rejectArtifacts(cfg, data_continuous);
  
  clear data_continuous cfg_autoart
  fprintf('\n');
  
  % Concatenated cleaned data of all conditions to a continuous stream
  cfg                 = [];
  cfg.showcallinfo    = 'no';
  data_cleaned.part1  = ft_appenddata(cfg, data_cleaned.FP.part1, ...
                                      data_cleaned.PD.part1, ...
                                      data_cleaned.PS.part1, ...
                                      data_cleaned.C.part1);
  data_cleaned.part2  = ft_appenddata(cfg, data_cleaned.FP.part2, ...
                                      data_cleaned.PD.part2, ...
                                      data_cleaned.PS.part2, ...
                                      data_cleaned.C.part2);
  data_cleaned.part1.fsample  = data_cleaned.FP.part1.fsample;
  data_cleaned.part2.fsample  = data_cleaned.FP.part2.fsample;
  data_cleaned        = removefields(data_cleaned, {'FP', 'PD', 'PS', 'C'});
  data_cleaned        = RPS_concatData( data_cleaned );
  
  % ICA decomposition
  cfg               = [];
  cfg.channel       = {'all', '-EOGV', '-EOGH', '-REF'};                    % use all channels for EOG decomposition expect EOGV, EOGH and REF
  cfg.numcomponent  = 'all';
  
  data_icacomp      = RPS_ica(cfg, data_cleaned);
  fprintf('\n');
  
  % export the determined ica components in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03a_icacomp/');
  cfg.filename    = sprintf('RPS_d%02d_03a_icacomp', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The ica components of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_icacomp', data_icacomp);
  fprintf('Data stored!\n');
  clear data_icacomp
  
  % Extract EOG channels from the cleaned continuous data 
  cfg               = [];
  cfg.channel       = {'EOGV', 'EOGH'};
  data_eogchan      = RPS_selectdata(cfg, data_cleaned);
  
  clear data_cleaned
  fprintf('\n');
  
  % export the EOG channels in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '03b_eogchan/');
  cfg.filename    = sprintf('RPS_d%02d_03b_eogchan', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The EOG channels of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_eogchan', data_eogchan);
  fprintf('Data stored!\n\n');
  clear data_eogchan
end

%% clear workspace
clear file_path cfg sourceList numOfSources i j
