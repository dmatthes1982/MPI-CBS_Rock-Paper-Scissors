%% check if basic variables are defined and import segmented data
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = 'data_preproc2/';
  cfg.filename  = 'RPS_d01_data_preproc2';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';      % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in segmented data folder
  sourceList    = dir([strcat(desPath, 'data_preproc2/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RPS_d%d_data_preproc2_', sessionStr, '.mat'));
  end
end

%% part 6

cprintf([0,0.6,0], '<strong>[6] - Narrow band filtering and Hilbert transform</strong>\n');
fprintf('\n');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bandpass filtering

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
  
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, 'data_preproc2/');
  cfg.filename    = sprintf('RPS_d%02d_data_preproc2', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load preprocessed data...\n\n');
  RPS_loadData( cfg );
  
  filtCoeffDiv = 500 / data_preproc2.FP.part1.fsample;                        % estimate sample frequency dependent divisor of filter length

  % bandpass filter data at alpha (8-12 Hz)
  cfg           = [];
  cfg.bpfreq    = [8 12];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  cfg.channel   = {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2', ...
                   '-H1', '-H2'}; 
  
  data_bpfilt_alpha = RPS_bpFiltering(cfg, data_preproc2);
  
  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('RPS_d%02d_06a_bpfiltAlpha', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (alpha: 8-12Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_bpfilt_alpha', data_bpfilt_alpha);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_alpha

  % bandpass filter data at beta (13-30Hz)
  cfg           = [];
  cfg.bpfreq    = [13 30];
  cfg.filtorder = fix(250 / filtCoeffDiv);
  cfg.channel   = {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2', ...
                   '-H1', '-H2'};
  
  data_bpfilt_beta = RPS_bpFiltering(cfg, data_preproc2);

  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('RPS_d%02d_06a_bpfiltBeta', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (beta: 13-30Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_bpfilt_beta', data_bpfilt_beta);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_beta
  
  % bandpass filter data at gamma (31-90Hz)
  cfg           = [];
  cfg.bpfreq    = [31 90];
  cfg.filtorder = fix(250 / filtCoeffDiv);
   cfg.channel   = {'all', '-REF', '-EOGV', '-EOGH', '-V1', '-V2', ...
                   '-H1', '-H2'};
  
  data_bpfilt_gamma = RPS_bpFiltering(cfg, data_preproc2);

  % export the filtered data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('RPS_d%02d_06a_bpfiltGamma', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving bandpass filtered data (gamma: 31-90Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_bpfilt_gamma', data_bpfilt_gamma);
  fprintf('Data stored!\n\n');
  clear data_bpfilt_gamma data_preproc2
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% hilbert phase calculation

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n', i);
   
  % calculate hilbert phase at alpha (8-12Hz)
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('RPS_d%02d_06a_bpfiltAlpha', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at alpha (8-12Hz) bandpass filtered data ...\n');
  RPS_loadData( cfg );
  
  data_hilbert_alpha = RPS_hilbertPhase(data_bpfilt_alpha);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('RPS_d%02d_06b_hilbertAlpha', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (alpha: 8-12Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_hilbert_alpha', data_hilbert_alpha);
  fprintf('Data stored!\n\n');
  clear data_hilbert_alpha data_bpfilt_alpha
  
  % calculate hilbert phase at beta (13-30Hz)
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('RPS_d%02d_06a_bpfiltBeta', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at beta (13-30Hz) bandpass filtered data ...\n');
  RPS_loadData( cfg );
  
  data_hilbert_beta = RPS_hilbertPhase(data_bpfilt_beta);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('RPS_d%02d_06b_hilbertBeta', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (beta: 13-30Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_hilbert_beta', data_hilbert_beta);
  fprintf('Data stored!\n\n');
  clear data_hilbert_beta data_bpfilt_beta
  
  % calculate hilbert phase at gamma (31-90Hz)
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '06a_bpfilt/');
  cfg.filename    = sprintf('RPS_d%02d_06a_bpfiltGamma', i);
  cfg.sessionStr  = sessionStr;
  fprintf('Load the at gamma (31-90Hz) bandpass filtered data ...\n');
  RPS_loadData( cfg );
  
  data_hilbert_gamma = RPS_hilbertPhase(data_bpfilt_gamma);
  
  % export the hilbert phase data into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '06b_hilbert/');
  cfg.filename    = sprintf('RPS_d%02d_06b_hilbertGamma', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving Hilbert phase data (gamma: 31-90Hz) of dyad %d in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_hilbert_gamma', data_hilbert_gamma);
  fprintf('Data stored!\n\n');
  clear data_hilbert_gamma data_bpfilt_gamma
end

%% clear workspace
clear cfg file_path numOfSources sourceList i filtCoeffDiv
