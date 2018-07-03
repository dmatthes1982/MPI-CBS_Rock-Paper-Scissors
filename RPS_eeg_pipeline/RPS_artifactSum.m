% -------------------------------------------------------------------------
% Add directory and subfolders to path
% -------------------------------------------------------------------------
clc;
RPS_init;

cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');
cprintf([0,0.6,0], '<strong>Rock, paper, scissor project</strong>\n');
cprintf([0,0.6,0], '<strong>Export number of segments with artifacts</strong>\n');
cprintf([0,0.6,0], 'Copyright (C) 2017-2018, Daniel Matthes, MPI CBS\n');
cprintf([0,0.6,0], '<strong>------------------------------------------------</strong>\n');

% -------------------------------------------------------------------------
% Path settings
% -------------------------------------------------------------------------
path = '/data/pt_01843/eegData/DualEEG_RPS_processedData/';

fprintf('\nThe default path is: %s\n', path);

selection = false;
while selection == false
  fprintf('\nDo you want to use the default path?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    newPaths = false;
  elseif strcmp('n', x)
    selection = true;
    newPaths = true;
  else
    selection = false;
  end
end

if newPaths == true
  path = uigetdir(pwd, 'Select folder...');
  path = strcat(path, '/');
end

% -------------------------------------------------------------------------
% Session selection
% -------------------------------------------------------------------------
tmpPath = strcat(path, '05a_autoart/');

fileList     = dir([tmpPath, 'RPS_d*_05a_autoart_*.mat']);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles   = length(fileList);

sessionNum   = zeros(1, numOfFiles);
fileListCopy = fileList;

for i=1:1:numOfFiles
  fileListCopy{i} = strsplit(fileList{i}, '05a_autoart_');
  fileListCopy{i} = fileListCopy{i}{end};
  sessionNum(i) = sscanf(fileListCopy{i}, '%d.mat');
end

sessionNum = unique(sessionNum);
y = sprintf('%d ', sessionNum);

userList = cell(1, length(sessionNum));

for i = sessionNum
  match = find(strcmp(fileListCopy, sprintf('%03d.mat', i)), 1, 'first');
  filePath = [tmpPath, fileList{match}];
  [~, cmdout] = system(['ls -l ' filePath '']);
  attrib = strsplit(cmdout);
  userList{i} = attrib{3};
end

selection = false;
while selection == false
  fprintf('\nThe following sessions are available: %s\n', y);
  fprintf('The session owners are:\n');
  for i=1:1:length(userList)
    fprintf('%d - %s\n', i, userList{i});
  end
  fprintf('\n');
  fprintf('Please select one session:\n');
  fprintf('[num] - Select session\n\n');
  x = input('Session: ');

  if length(x) > 1
    cprintf([1,0.5,0], 'Wrong input, select only one session!\n');
  else
    if ismember(x, sessionNum)
      selection = true;
      sessionStr = sprintf('%03d', x);
    else
      cprintf([1,0.5,0], 'Wrong input, session does not exist!\n');
    end
  end
end

fprintf('\n');

clear sessionNum fileListCopy y userList match filePath cmdout attrib 

% -------------------------------------------------------------------------
% Extract and export number of artifacts
% -------------------------------------------------------------------------
tmpPath = strcat(path, '05a_autoart/');
label = {'F7','Fz','F8','FC5','FC1','FC2','FC6','T7','C3','Cz','C4', ...
          'T8','FCz','CP1','CP2','TP10','P7','P3','Pz','P4','P8','O1', ...
          'Oz','O2'};

label_1 = cellfun(@(x) strcat(x, '_1'), label, 'UniformOutput', false);
label_2 = cellfun(@(x) strcat(x, '_2'), label, 'UniformOutput', false);

T_all = table(0,0,0,0,0,0,0,0,0);
T_all.Properties.VariableNames = {'dyad', 'FP_ArtifactsPart1', 'FP_ArtifactsPart2', ...
                              'PD_ArtifactsPart1', 'PD_ArtifactsPart2', ...
                              'PS_ArtifactsPart1', 'PS_ArtifactsPart2', ...
                              'C_ArtifactsPart1', 'C_ArtifactsPart2'};

T_FP = cell2table(num2cell(zeros(1,49)));
T_FP.Properties.VariableNames = [{'dyad'}, label_1 label_2];                % create empty table with variable names

T_PD = T_FP;
T_PS = T_FP;
T_C = T_FP;

fileList     = dir([tmpPath, ['RPS_d*_05a_autoart_' sessionStr '.mat']]);
fileList     = struct2cell(fileList);
fileList     = fileList(1,:);
numOfFiles  = length(fileList);
numOfPart   = zeros(1, numOfFiles);
for i = 1:1:numOfFiles
  numOfPart(i) = sscanf(fileList{i}, strcat('RPS_d%d*', sessionStr, '.mat'));
end

for i = 1:1:length(fileList)
  file_path = strcat(tmpPath, fileList{i});
  load(file_path, 'cfg_autoart');
  
  % FP
  chan = ismember(label, cfg_autoart.FP.label);                             % determine all channels which were used for artifact detection
  pos = find(ismember(cfg_autoart.FP.label, label));                        % determine the order of the channels

  tmpArt1 = zeros(1,24);
  tmpArt1(chan) = cfg_autoart.FP.bad1NumChan(pos);                          % extract number of artifacts per channel for participant 1
  tmpArt1 = num2cell(tmpArt1);

  tmpArt2 = zeros(1,24);
  tmpArt2(chan) = cfg_autoart.FP.bad2NumChan(pos);                          % extract number of artifacts per channel for participant 2
  tmpArt2 = num2cell(tmpArt2);

  warning off;
  T_FP.dyad(i) = numOfPart(i);
  T_FP(i,2:25)   = tmpArt1;
  T_FP(i,26:49)  = tmpArt2;
  warning on;

  % PD
  chan = ismember(label, cfg_autoart.PD.label);                             % determine all channels which were used for artifact detection
  pos = find(ismember(cfg_autoart.PD.label, label));                        % determine the order of the channels

  tmpArt1 = zeros(1,24);
  tmpArt1(chan) = cfg_autoart.PD.bad1NumChan(pos);                          % extract number of artifacts per channel for participant 1
  tmpArt1 = num2cell(tmpArt1);

  tmpArt2 = zeros(1,24);
  tmpArt2(chan) = cfg_autoart.PD.bad2NumChan(pos);                          % extract number of artifacts per channel for participant 2
  tmpArt2 = num2cell(tmpArt2);

  warning off;
  T_PD.dyad(i) = numOfPart(i);
  T_PD(i,2:25)   = tmpArt1;
  T_PD(i,26:49)  = tmpArt2;
  warning on;

  % PS
  chan = ismember(label, cfg_autoart.PS.label);                             % determine all channels which were used for artifact detection
  pos = find(ismember(cfg_autoart.PS.label, label));                        % determine the order of the channels

  tmpArt1 = zeros(1,24);
  tmpArt1(chan) = cfg_autoart.PS.bad1NumChan(pos);                          % extract number of artifacts per channel for participant 1
  tmpArt1 = num2cell(tmpArt1);

  tmpArt2 = zeros(1,24);
  tmpArt2(chan) = cfg_autoart.PS.bad2NumChan(pos);                          % extract number of artifacts per channel for participant 2
  tmpArt2 = num2cell(tmpArt2);

  warning off;
  T_PS.dyad(i) = numOfPart(i);
  T_PS(i,2:25)   = tmpArt1;
  T_PS(i,26:49)  = tmpArt2;
  warning on;

  % C
  chan = ismember(label, cfg_autoart.C.label);                              % determine all channels which were used for artifact detection
  pos = find(ismember(cfg_autoart.C.label, label));                         % determine the order of the channels

  tmpArt1 = zeros(1,24);
  tmpArt1(chan) = cfg_autoart.C.bad1NumChan(pos);                           % extract number of artifacts per channel for participant 1
  tmpArt1 = num2cell(tmpArt1);

  tmpArt2 = zeros(1,24);
  tmpArt2(chan) = cfg_autoart.C.bad2NumChan(pos);                           % extract number of artifacts per channel for participant 2
  tmpArt2 = num2cell(tmpArt2);

  warning off;
  T_C.dyad(i) = numOfPart(i);
  T_C(i,2:25)   = tmpArt1;
  T_C(i,26:49)  = tmpArt2;
  warning on;

  % all conditions
  warning off;
  T_all.dyad(i) = numOfPart(i);
  T_all.FP_ArtifactsPart1(i) = cfg_autoart.FP.bad1Num;
  T_all.FP_ArtifactsPart2(i) = cfg_autoart.FP.bad2Num;
  T_all.PD_ArtifactsPart1(i) = cfg_autoart.PD.bad1Num;
  T_all.PD_ArtifactsPart2(i) = cfg_autoart.PD.bad2Num;
  T_all.PS_ArtifactsPart1(i) = cfg_autoart.PS.bad1Num;
  T_all.PS_ArtifactsPart2(i) = cfg_autoart.PS.bad2Num;
  T_all.C_ArtifactsPart1(i) = cfg_autoart.C.bad1Num;
  T_all.C_ArtifactsPart2(i) = cfg_autoart.C.bad2Num;
  warning on;
end

folder = strcat(path, '00_settings/');
file_path = strcat(folder, 'numOfArtifacts_', sessionStr, '.xls');
fprintf('The default file path is: %s\n', file_path);

selection = false;
while selection == false
  fprintf('\nDo you want to use the default file path and possibly overwrite an existing file?\n');
  x = input('Select [y/n]: ','s');
  if strcmp('y', x)
    selection = true;
    newPaths = false;
  elseif strcmp('n', x)
    selection = true;
    newPaths = true;
  else
    selection = false;
  end
end

if newPaths == true
  [filename, folder] = uiputfile(file_path, 'Specify a destination file...');
  file_path = [folder, filename];
end

template_path = [folder 'general_docs/numOfArtifacts_template.xls'];

if exist(template_path, 'file')
  [~] = copyfile(template_path, file_path);
else
  cprintf([1,0.5,0], 'WARNING: You''re probably not working at the default paths. File numOfArtifacts_template.xls does''nt exist. \n');
  cprintf([1,0.5,0], 'A new file will be created, but this one includes 3 empty sheets at the beginning.\n');
  if exist(file_path, 'file')
    delete(file_path);
  end
end

warning('off','MATLAB:xlswrite:AddSheet')
writetable(T_all, file_path, 'Sheet', 'overview');
writetable(T_FP, file_path, 'Sheet', 'FP');
writetable(T_PD, file_path, 'Sheet', 'PD');
writetable(T_PS, file_path, 'Sheet', 'PS');
writetable(T_C, file_path, 'Sheet', 'C');
warning('on','MATLAB:xlswrite:AddSheet')

fprintf('\nNumber of segments with artifacts per dyad exported to:\n');
fprintf('%s\n', file_path);

clear tmpPath path sessionStr fileList numOfFiles numOfPart i ...
      file_path cfg_autoart T_all newPaths filename selection x ...
      chan label label_1 label_2 pos tmpArt1 tmpArt2 T_FP T_PD T_PS T_C ...
      folder template_path
