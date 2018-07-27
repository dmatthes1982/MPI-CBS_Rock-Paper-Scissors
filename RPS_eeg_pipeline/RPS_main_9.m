%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '07b_mplv/';
  cfg.filename  = 'RPS_d01_07b_mplv20Hz';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath       = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';      % destination path for processed data  
end

%% part 9
% Averaging over dyads

cprintf([0,0.6,0], '<strong>[9] - Averaging over dyads</strong>\n');
fprintf('\n');

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
  cfg.path = strcat(desPath, '07b_mplv/');
  cfg.session = str2double(sessionStr);
  cfg.passband = 'alpha';

  data_mplvod_alpha = RPS_mPLVoverDyads( cfg );

  cfg.passband = 'beta';

  data_mplvod_beta = RPS_mPLVoverDyads( cfg );

  cfg.passband = 'gamma';

  data_mplvod_gamma = RPS_mPLVoverDyads( cfg );
  
  % export the averaged PLVs into a *.mat file
  % alpha
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '09a_mplvod/');
  cfg.filename    = 'RPS_09a_mplvodAlpha';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs over dyads at alpha (8-12Hz) in:\n'); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_mplvod_alpha', data_mplvod_alpha);
  fprintf('Data stored!\n');
  clear data_mplvod_alpha
  
  % beta
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '09a_mplvod/');
  cfg.filename    = 'RPS_09a_mplvodBeta';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                   '.mat');
                   
  fprintf('Saving mean PLVs over dyads at beta (13-30Hz) in:\n'); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_mplvod_beta', data_mplvod_beta);
  fprintf('Data stored!\n');
  clear data_mplvod_beta
  
  % gamma
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '09a_mplvod/');
  cfg.filename    = 'RPS_10a_mplvodGamma';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving mean PLVs over dyads at gamma (31-90Hz) in:\n'); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_mplvod_gamma', data_mplvod_gamma);
  fprintf('Data stored!\n\n');
  clear data_mplvod_gamma
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Averaging TFR over dyads
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Averaging TFR over dyads?\n');
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
  cfg             = [];
  cfg.path        = strcat(desPath, '08a_tfr/');
  cfg.session     = str2double(sessionStr);

  data_tfrod   = RPS_TFRoverDyads( cfg );

  % export the averaged TFR values into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '09b_tfrod/');
  cfg.filename    = 'RPS_09b_tfrod';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('Saving TFR values over dyads in:\n');
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_tfrod', data_tfrod);
  fprintf('Data stored!\n\n');
  clear data_tfrod
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Averaging PSD over dyads
choise = false;
while choise == false
  cprintf([0,0.6,0], 'Averaging PSD over dyads?\n');
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
  cfg             = [];
  cfg.path        = strcat(desPath, '08b_pwelch/');
  cfg.session     = str2double(sessionStr);
  
  data_pwelchod   = RPS_PSDoverDyads( cfg );
  
  % export the averaged PSD values into a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '09c_pwelchod/');
  cfg.filename    = 'RPS_09c_pwelchod';
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');
                   
  fprintf('Saving PSD values over dyads in:\n'); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_pwelchod', data_pwelchod);
  fprintf('Data stored!\n');
  clear data_pwelchod
end

%% clear workspace
clear cfg file_path avgOverDyads x choise
