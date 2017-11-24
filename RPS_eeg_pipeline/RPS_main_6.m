%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '11_mplv/';
  cfg.filename  = 'RPS_p01_11b_mplv20Hz';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';      % destination path for processed data  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Averaging mPLVs over dyads
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Averaging mPLVs over dyads?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    choise = true;
    avgOverDyads = true;
  elseif strcmp('n', x)
    choise = true;
    avgOverDyads = false;
  else
    choise = false;
  end
end
fprintf('\n');

if avgOverDyads == true
  cfg = [];
  cfg.path = strcat(desPath, '11_mplv/');
  cfg.session = str2num(sessionStr);                                        %#ok<ST2NM>
  cfg.passband = '10Hz';

  data_mplvod_10Hz = RPS_mPLVoverDyads( cfg );

  cfg.passband = '20Hz';

  data_mplvod_20Hz = RPS_mPLVoverDyads( cfg );

  % export the averaged PLVs into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '12_mplvod/');
  cfg.filename    = 'RPS_12a_mplvod10Hz';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs over dyads at 10Hz in:\n'); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_mplvod_10Hz', data_mplvod_10Hz);
  fprintf('Data stored!\n');
  clear data_mplvod_10Hz

  cfg             = [];
  cfg.desFolder   = strcat(desPath, '12_mplvod/');
  cfg.filename    = 'RPS_12b_mplvod20Hz';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                   '.mat');
                   
  fprintf('Saving mean PLVs over dyads at 20Hz in:\n'); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_mplvod_20Hz', data_mplvod_20Hz);
  fprintf('Data stored!\n');
  clear data_mplvod_20Hz
end
  
%% clear workspace
clear cfg file_path avgOverDyads x choise