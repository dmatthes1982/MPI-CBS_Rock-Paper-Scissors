%% check if basic variables are defined
if ~exist('sessionStr', 'var')
  cfg           = [];
  cfg.subFolder = '03b_eogchan/';
  cfg.filename  = 'RPS_d01_03b_eogchan';
  sessionStr    = sprintf('%03d', RPS_getSessionNum( cfg ));                % estimate current session number
end

if ~exist('desPath', 'var')
  desPath = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';            % destination path for processed data  
end

if ~exist('numOfPart', 'var')                                               % estimate number of participants in eogcomp data folder
  sourceList    = dir([strcat(desPath, '03b_eogchan/'), ...
                       strcat('*_', sessionStr, '.mat')]);
  sourceList    = struct2cell(sourceList);
  sourceList    = sourceList(1,:);
  numOfSources  = length(sourceList);
  numOfPart     = zeros(1, numOfSources);

  for i=1:1:numOfSources
    numOfPart(i)  = sscanf(sourceList{i}, ...
                    strcat('RPS_d%d_03b_eogchan_', sessionStr, '.mat'));
  end
end

%% part 4
% 1. Find EOG-like ICA Components (Correlation with EOGV and EOGH, 80 %
%    confirmity)
% 2. Verify the estimated components by using the ft_icabrowser function
%    and add further bad components to the selection
% 3. Correct EEG data
% 4. Recovery of bad channels
% 5. Re-referencing

cprintf([0,0.6,0], '<strong>[4] - Preproc II: ICA-based artifact correction, bad channel recovery, re-referencing</strong>\n');
fprintf('\n');

% favoured reference
selection = false;
while selection == false
  cprintf([0,0.6,0], 'Please select favoured reference:\n');
% fprintf('[1] - Linked mastoid (''TP9'', ''TP10'')\n');
  fprintf('[1] - Common average reference\n');
  x = input('Option: ');

  switch x
%   case 1
%     selection = true;
%     refchannel = 'TP10';
%     reference = {'LM'};
    case 1
      selection = true;
      refchannel = {'all', '-V1', '-V2'};
      reference = {'CAR'};
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end
fprintf('\n');

% correlation threshold
selection = false;
while selection == false
  cprintf([0,0.6,0], 'Do you want to use the default threshold (0.8) for EOG-artifact estimation for both participants?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    threshold = {[0.8 0.8 0.8 0.8], [0.8 0.8 0.8 0.8]};
    thresholdString = {'[0.8,0.8,0.8,0.8]', '[0.8,0.8,0.8,0.8]'};
  elseif strcmp('n', x)
    selection = true;
    threshold = [];
    thresholdString = [];
  else
    selection = false;
  end
end
fprintf('\n');

if isempty(threshold)
  for i = 1:1:2                                                             % specify a independent threshold for each participant and each condition
    selection = false;
    while selection == false
      cprintf([0,0.6,0], 'Specify a specific threshold value for each condition of participant %d in a range between 0 and 1!\n', i);
      cprintf([0,0.6,0], 'i.e.: [0.8 0.7 0.75 0.8]\n');
      x = input('Value: ');
      if isnumeric(x) && numel(x) == 4
        if (any(x) < 0 || any(x) > 1)
          cprintf([1,0.5,0], 'Wrong input!\n');
          selection = false;
        else
          threshold{i} = x;
          thresholdString{i} = [ '[' strjoin(cellfun(@(y) ...
                                          sprintf('%g',y), num2cell(x), ...
                                          'UniformOutput', false),',') ...
                                 ']' ];
          selection = true;
        end
      else
        cprintf([1,0.5,0], 'Wrong input!\n');
        selection = false;
      end
    end
  end
fprintf('\n');  
end

% Create settings file if not existing
settings_file = [desPath '00_settings/' ...
                  sprintf('settings_%s', sessionStr) '.xls'];
if ~(exist(settings_file, 'file') == 2)                                     % check if settings file already exist
  cfg = [];
  cfg.desFolder   = [desPath '00_settings/'];
  cfg.type        = 'settings';
  cfg.sessionStr  = sessionStr;
  
  RPS_createTbl(cfg);                                                       % create settings file
end

T = readtable(settings_file);                                               % update settings table
warning off;
T.reference(numOfPart)    = reference;
T.ICAcorrVal1(numOfPart)  = thresholdString(1);
T.ICAcorrVal2(numOfPart)  = thresholdString(2);
warning on;

for i = numOfPart
  fprintf('<strong>Dyad %d</strong>\n\n', i);

  %% ICA-based artifact correction %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>ICA-based artifact correction</strong>\n\n');

  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '03a_icacomp/');
  cfg.filename    = sprintf('RPS_d%02d_03a_icacomp', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load ICA result...\n');
  RPS_loadData( cfg );
  
  cfg.srcFolder   = strcat(desPath, '03b_eogchan/');
  cfg.filename    = sprintf('RPS_d%02d_03b_eogchan', i);
  
  fprintf('Load original EOG channels...\n\n');
  RPS_loadData( cfg );
  
  % Find EOG-like ICA Components (Correlation with EOGV and EOGH, 80 %
  % confirmity)
  cfg         = [];
  cfg.threshold = threshold;
  
  data_eogcomp      = RPS_detEOGComp(cfg, data_icacomp, data_eogchan);
  
  clear data_eogchan
  fprintf('\n');
  
  % Verify EOG-like ICA Components and add further bad components to the
  % selection
  data_eogcomp      = RPS_selectBadComp(data_eogcomp, data_icacomp);
  
  clear data_icacomp
  fprintf('\n');

  % export the selected ICA components and the unmixing matrix into
  % a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04a_eogcomp/');
  cfg.filename    = sprintf('RPS_d%02d_04a_eogcomp', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The eye-artifact related components and the unmixing matrix of dyad %d will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_eogcomp', data_eogcomp);
  fprintf('Data stored!\n\n');

  % add selected ICA components to the settings file
  if isempty(data_eogcomp.FP.part1.elements)
    ICAcompFPp1 = {'---'};
  else
    ICAcompFPp1 = {strjoin(data_eogcomp.FP.part1.elements,',')};
  end
  if isempty(data_eogcomp.FP.part2.elements)
    ICAcompFPp2 = {'---'};
  else
    ICAcompFPp2 = {strjoin(data_eogcomp.FP.part2.elements,',')};
  end
  if isempty(data_eogcomp.PD.part1.elements)
    ICAcompPDp1 = {'---'};
  else
    ICAcompPDp1 = {strjoin(data_eogcomp.PD.part1.elements,',')};
  end
  if isempty(data_eogcomp.PD.part2.elements)
    ICAcompPDp2 = {'---'};
  else
    ICAcompPDp2 = {strjoin(data_eogcomp.PD.part2.elements,',')};
  end
  if isempty(data_eogcomp.PS.part1.elements)
    ICAcompPSp1 = {'---'};
  else
    ICAcompPSp1 = {strjoin(data_eogcomp.PS.part1.elements,',')};
  end
  if isempty(data_eogcomp.PS.part2.elements)
    ICAcompPSp2 = {'---'};
  else
    ICAcompPSp2 = {strjoin(data_eogcomp.PS.part2.elements,',')};
  end
  if isempty(data_eogcomp.C.part1.elements)
    ICAcompCp1 = {'---'};
  else
    ICAcompCp1 = {strjoin(data_eogcomp.C.part1.elements,',')};
  end
  if isempty(data_eogcomp.C.part2.elements)
    ICAcompCp2 = {'---'};
  else
    ICAcompCp2 = {strjoin(data_eogcomp.C.part2.elements,',')};
  end
  warning off;
  T.ICAcompFPp1(i) = ICAcompFPp1;
  T.ICAcompFPp2(i) = ICAcompFPp2;
  T.ICAcompPDp1(i) = ICAcompPDp1;
  T.ICAcompPDp2(i) = ICAcompPDp2;
  T.ICAcompPSp1(i) = ICAcompPSp1;
  T.ICAcompPSp2(i) = ICAcompPSp2;
  T.ICAcompCp1(i)  = ICAcompCp1;
  T.ICAcompCp2(i)  = ICAcompCp2;
  warning on;

  % store settings table
  delete(settings_file);
  writetable(T, settings_file);

  % load basic bandpass filtered data
  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02b_preproc1/');
  cfg.filename    = sprintf('RPS_d%02d_02b_preproc1', i);
  cfg.sessionStr  = sessionStr;
  
  fprintf('Load bandpass filtered data...\n');
  RPS_loadData( cfg );
  
  % correct EEG signals
  data_eyecor = RPS_correctSignals(data_eogcomp, data_preproc1);
  
  clear data_eogcomp data_preproc1
  fprintf('\n');
  
  % export the reviced data in a *.mat file
  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04b_eyecor/');
  cfg.filename    = sprintf('RPS_d%02d_04b_eyecor', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The reviced data (from eye artifacts) of dyad %d will be saved in:\n', i); 
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_eyecor', data_eyecor);
  fprintf('Data stored!\n\n');

  %% Recovery of bad channels %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Bad channel recovery</strong>\n\n');

  cfg             = [];
  cfg.srcFolder   = strcat(desPath, '02a_badchan/');
  cfg.filename    = sprintf('RPS_d%02d_02a_badchan', i);
  cfg.sessionStr  = sessionStr;

  fprintf('Load bad channels specification...\n');
  RPS_loadData( cfg );

  data_eyecor = RPS_repairBadChan( data_badchan, data_eyecor );
  clear data_badchan

  %% re-referencing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fprintf('<strong>Rereferencing</strong>\n');

  cfg                   = [];
  cfg.refchannel        = refchannel;

  ft_info off;
  data_preproc2 = RPS_reref( cfg, data_eyecor);
  ft_info on;

  cfg             = [];
  cfg.desFolder   = strcat(desPath, '04c_preproc2/');
  cfg.filename    = sprintf('RPS_d%02d_04c_preproc2', i);
  cfg.sessionStr  = sessionStr;

  file_path = strcat(cfg.desFolder, cfg.filename, '_', cfg.sessionStr, ...
                     '.mat');

  fprintf('The clean and re-referenced data of dyad %d will be saved in:\n', i);
  fprintf('%s ...\n', file_path);
  RPS_saveData(cfg, 'data_preproc2', data_preproc2);
  fprintf('Data stored!\n\n');
  clear data_preproc2 data_eyecor data_badchan

  if(i < max(numOfPart))
    selection = false;
    while selection == false
      fprintf('Proceed with the next dyad?\n');
      x = input('\nSelect [y/n]: ','s');
      if strcmp('y', x)
        selection = true;
      elseif strcmp('n', x)
        clear file_path cfg sourceList numOfSources i threshold selection x T ...
              settings_file reference refchannel ICAcompFPp1 ICAcompFPp2 ...
              ICAcompPDp1 ICAcompPDp2 ICAcompPSp1 ICAcompPSp2 ICAcompCp1 ...
              ICAcompCp2 thresholdString
        return;
      else
        selection = false;
      end
    end
    fprintf('\n');
  end
end

%% clear workspace
clear file_path cfg sourceList numOfSources i threshold selection x T ...
      settings_file reference refchannel ICAcompFPp1 ICAcompFPp2 ...
      ICAcompPDp1 ICAcompPDp2 ICAcompPSp1 ICAcompPSp2 ICAcompCp1 ...
      ICAcompCp2 thresholdString
