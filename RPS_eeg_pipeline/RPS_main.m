fprintf('------------------------------------------------\n');
fprintf('<strong>Rock, paper, scissor project - data processing</strong>\n');
fprintf('Version: 0.1\n');
fprintf('Copyright (C) 2017, Daniel Matthes, MPI CBS\n');
fprintf('------------------------------------------------\n');

% -------------------------------------------------------------------------
% General definitions
% -------------------------------------------------------------------------
srcPath = '/data/pt_01843/eegData/DualEEG_RPS_rawData/';
desPath = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';

clear sessionStr numOfPart part

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
selection = false;

tmpPath = strcat(desPath, '02_preproc/');

sessionList    = dir([tmpPath, 'RPS_p01_02_preproc_*.mat']);
sessionList    = struct2cell(sessionList);
sessionList    = sessionList(1,:);
numOfSessions  = length(sessionList);

sessionNum     = zeros(1, numOfSessions);

for i=1:1:numOfSessions
  sessionNum(i) = sscanf(sessionList{i}, 'RPS_p01_02_preproc_%d.mat');
end

y = sprintf('%d ', sessionNum);

while selection == false
  fprintf('\nThe following sessions are available: %s\n', y);
  fprintf('Please select one session or create a new one:\n');
  fprintf('[0] - Create new session\n');
  fprintf('[num] - Select session\n\n');
  x = input('Session: ');

  if length(x) > 1
    cprintf([1,0.5,0], 'Wrong input, select only one session!\n');
  else
    if ismember(x, sessionNum)
      selection = true;
      session = x;
      sessionStr = sprintf('%03d', session);
    elseif x == 0  
      selection = true;
      session = x;
      sessionStr = sprintf('%03d', max(sessionNum) + 1);
    else
      cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
    end
  end
end
  

% -------------------------------------------------------------------------
% General selection of dyads
% -------------------------------------------------------------------------
selection = false;

while selection == false
  fprintf('\nPlease select one option:\n');
  fprintf('[1] - Process all available dyads\n');
  fprintf('[2] - Process all new dyads\n');
  fprintf('[3] - Process specific dyad\n');
  fprintf('[4] - Quit data processing\n\n');
  x = input('Option: ');
  
  switch x
    case 1
      selection = true;
      dyadsSpec = 'all';
    case 2
      selection = true;
      dyadsSpec = 'new';
    case 3
      selection = true;
      dyadsSpec = 'specific';
    case 4
      fprintf('\nData processing aborted.\n');
      clear selection i x y srcPath desPath session sessionList ...
            sessionNum numOfSessions sessionStr
      return;
    otherwise
      cprintf([1,0.5,0], 'Wrong input!\n');
  end
end

% -------------------------------------------------------------------------
% General selection of preprocessing option
% -------------------------------------------------------------------------
selection = false;

if session == 0
  fprintf('\nA new session always will start with part:\n');
  fprintf('[1] - Import and basic preprocessing\n');
  part = 1;
else
  while selection == false
    fprintf('\nPlease select what you want to do with the selected dyads:\n');
    fprintf('[1] - Import and basic preprocessing\n');
    cprintf([0.5,0.5,0.5], '[2] - Rejection of eye artifacts (not available yet)\n');
    fprintf('[3] - Automatic and manual detection of artifacts\n');
    fprintf('[4] - Application of narrow band filtering and Hilbert transform\n'); 
    fprintf('[5] - Calculation of PLV\n');
    fprintf('[6] - Quit data processing\n\n');
    x = input('Option: ');
  
    switch x
      case 1
        part = 1;
        selection = true;
      case 2
        part = 2;
        selection = false;
        cprintf([1,0.5,0], 'This option is currently unsupported!\n');
      case 3
        part = 3;
        selection = true;
      case 4
        part = 4;
        selection = true;
      case 5
        part = 5;
        selection = true;
      case 6
        fprintf('\nData processing aborted.\n');
        clear selection i x y srcPath desPath session sessionList ...
            sessionNum numOfSessions dyadsSpec sessionStr
        return;
      otherwise
        selection = false;
        cprintf([1,0.5,0], 'Wrong input!\n');
    end
  end
end

% -------------------------------------------------------------------------
% Specific selection of dyads
% -------------------------------------------------------------------------
sourceList    = dir([srcPath, '/*_C*.vhdr']);
sourceList    = struct2cell(sourceList);
sourceList    = sourceList(1,:);
numOfSources  = length(sourceList);
fileNum       = zeros(1, numOfSources);

for i=1:1:numOfSources
  fileNum(i)     = sscanf(sourceList{i}, 'DualEEG_RPS_C_%d.vhdr');
end

switch part
  case 1
    fileNamePre = [];
    tmpPath = strcat(desPath, '02_preproc/');
    fileNamePost = strcat(tmpPath, 'RPS_p*_02_preproc_', sessionStr, '.mat');
  case 2
    error('This option is currently unsupported!');
  case 3
    tmpPath = strcat(desPath, '02_preproc/');
    fileNamePre = strcat(tmpPath, 'RPS_p*_02_preproc_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '06_allArt/');
    fileNamePost = strcat(tmpPath, 'RPS_p*_06_allArt_', sessionStr, '.mat');
  case 4
    tmpPath = strcat(desPath, '02_preproc/');
    fileNamePre = strcat(tmpPath, 'RPS_p*_02_preproc_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '08_hilbert/');
    fileNamePost = strcat(tmpPath, 'RPS_p*_08b_hilbert20Hz_', sessionStr, '.mat');
  case 5
    tmpPath = strcat(desPath, '08_hilbert/');
    fileNamePre = strcat(tmpPath, 'RPS_p*_08a_hilbert10Hz_', sessionStr, '.mat');
    tmpPath = strcat(desPath, '11_mplv/');
    fileNamePost = strcat(tmpPath, 'RPS_p*_11b_mplv20Hz_', sessionStr, '.mat');
  otherwise
    error('Something unexpected happend. part = %d is not defined' ...
          , part);
end

if isempty(fileNamePre)
  numOfPrePart = fileNum;
else
  fileListPre = dir(fileNamePre);
  if isempty(fileListPre)
    error(['Selected part [%d] can not be executed, no input data '...
           'available\n Please choose a previous part.']);
  else
    fileListPre = struct2cell(fileListPre);
    fileListPre = fileListPre(1,:);
    numOfFiles  = length(fileListPre);
    numOfPrePart = zeros(1, numOfFiles);
    for i=1:1:numOfFiles
      numOfPrePart(i) = sscanf(fileListPre{i}, strcat('RPS_p%d*', sessionStr, '.mat'));
    end
  end
end

if strcmp(dyadsSpec, 'all')                                                 % process all participants
  numOfPart = numOfPrePart;
elseif strcmp(dyadsSpec, 'specific')                                        % process specific participants
  y = sprintf('%d ', numOfPrePart);
    
  selection = false;
    
  while selection == false
    fprintf('\nThe following participants are available: %s\n', y);
    fprintf(['Comma-seperate your selection and put it in squared ' ...
               'brackets!\n']);
    x = input('\nPlease make your choice! (i.e. [1,2,3]): ');
      
    if ~all(ismember(x, numOfPrePart))
      cprintf([1,0.5,0], 'Wrong input!\n');
    else
      selection = true;
      numOfPart = x;
    end
  end
elseif strcmp(dyadsSpec, 'new')                                             % process only new participants
  if session == 0
    numOfPart = numOfPrePart;
  else
    fileListPost = dir(fileNamePost);
    if isempty(fileListPost)
      numOfPostPart = [];
    else
      fileListPost = struct2cell(fileListPost);
      fileListPost = fileListPost(1,:);
      numOfFiles  = length(fileListPost);
      numOfPostPart = zeros(1, numOfFiles);
      for i=1:1:numOfFiles
        numOfPostPart(i) = sscanf(fileListPost{i}, strcat('RPS_p%d*', sessionStr, '.mat'));
      end
    end
  
    numOfPart = numOfPrePart(~ismember(numOfPrePart, numOfPostPart));
    if isempty(numOfPart)
      cprintf([1,0.5,0], 'No new dyads available!\n');
      fprintf('Data processing aborted.\n');
      clear desPath fileNamePost fileNamePre fileNum i numOfPrePart ...
          numOfSources selection sourceList srcPath x y dyadsSpec ...
          fileListPost fileListPre numOfPostPart sessionList numOfFiles ...
          sessionNum numOfSessions session numOfPart part sessionStr ...
          dyads tmpPath
      return;
    end
  end
end

y = sprintf('%d ', numOfPart);
fprintf(['\nThe following participants will be processed ' ... 
         'in the selected part [%d]:\n'],  part);
fprintf('%s\n\n', y);

clear fileNamePost fileNamePre fileNum i numOfPrePart ...
      numOfSources selection sourceList x y dyads fileListPost ...
      fileListPre numOfPostPart sessionList sessionNum numOfSessions ...
      session dyadsSpec numOfFiles tmpPath

% -------------------------------------------------------------------------
% Data processing main loop
% -------------------------------------------------------------------------
sessionStatus = true;
sessionPart = part;

clear part;

while sessionStatus == true
  switch sessionPart
    case 1
      RPS_main_1;
      selection = false;
      while selection == false
        fprintf('\nContinue data processing with:\n');
        fprintf('[3] - Automatic and manual detection of artifacts?\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 3;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 3
      RPS_main_3;
      selection = false;
      while selection == false
        fprintf('\nContinue data processing with:\n');
        fprintf('[4] - Application of narrow band filtering and Hilbert transform?\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 4;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end
    case 4
      RPS_main_4;
      selection = false;
      while selection == false
        fprintf('Continue data processing with:\n');
        fprintf('[5] - Calculation of PLV?\n');
        x = input('\nSelect [y/n]: ','s');
        if strcmp('y', x)
          selection = true;
          sessionStatus = true;
          sessionPart = 5;
        elseif strcmp('n', x)
          selection = true;
          sessionStatus = false;
        else
          selection = false;
        end
      end  
    case 5
      RPS_main_5;
      sessionStatus = false;
    otherwise
      sessionStatus = false;
  end
  fprintf('\n');
end

fprintf('Data processing finished.\n');
fprintf('Session will be closed.\n');

clear sessionStr numOfPart srcPath desPath sessionPart sessionStatus ...
      selection x
