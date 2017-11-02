function [ data_mplv ] = RPS_mPLVoverDyads( cfg )
% RPS_MPLVOVERDYADS estimates the mean of the phase locking values within 
% the different phases and conditions for all connections and over all 
% dyads.
%
% Use as
%   [ data_mplv ] = RPS_mPLVoverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01843/eegData/DualEEG_RPS_processedData/10_mplv/')
%   cfg.session   = session number (default: 1)
%   cfg.passband  = select passband of interest (default: 10Hz)
%                   (accepted values: 10Hz, 20 Hz)
%
% where the input data have to be the result from RPS_CALCMEANPLV
%
% This function requires the fieldtrip toolbox
% 
% See also RPS_DATASTRUCTURE, RPS_CALCMEANPLV

% Copyright (C) 2017, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01843/eegData/DualEEG_RPS_processedData/10_mplv/');
            
session   = ft_getopt(cfg, 'session', 1);
passband  = ft_getopt(cfg, 'passband', '10Hz');

if ~strcmp(passband, '10Hz') && ~strcmp(passband, '20Hz')
  error('Define cfg.passband could only be ''10Hz'' por ''20Hz''.');
end

% -------------------------------------------------------------------------
% Specify default trial order
% -------------------------------------------------------------------------
trialinfoOrg{1} = [20; 10];                                                 % trial order in condition FP                                                 
trialinfoOrg{2} = [20; 11; 12; 13; 7; 15];                                  % trial order in condition PD
trialinfoOrg{3} = [20; 11; 12; 13; 7; 15];                                  % trial order in condition PS
trialinfoOrg{4} = [20; 11; 12; 13];                                         % trial order in condition C

% -------------------------------------------------------------------------
% Select dyads
% -------------------------------------------------------------------------    
dyadsList   = dir([path, sprintf('RPS_p*_10a_mplv%s_%03d.mat', ...
                  passband, session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['RPS_p%d_10a_mplv' ...
                                   sprintf('%s_', passband) ...
                                   sprintf('%03d.mat', session)]);          %#ok<AGROW>
end

y = sprintf('%d ', listOfDyads);
selection = false;

while selection == false
  fprintf('\nThe following dyads are available: %s\n', y);
  x = input('Which dyads should be included into the averaging? (i.e. [1,2,3]):\n');
  if ~all(ismember(x, listOfDyads))
    cprintf([1,0.5,0], 'Wrong input!\n');
  else
    selection = true;
    listOfDyads = x;
  end
end
fprintf('\n');

% -------------------------------------------------------------------------
% Load and organize data
% -------------------------------------------------------------------------
data_mplv.FP.trialinfo = trialinfoOrg{1};
data_mplv.PD.trialinfo = trialinfoOrg{2};
data_mplv.PS.trialinfo = trialinfoOrg{3};
data_mplv.C.trialinfo = trialinfoOrg{4};

data{4, length(listOfDyads)} = [];
trialinfo{4, length(listOfDyads)} = []; 

for i=1:1:length(listOfDyads)
  filename = sprintf('RPS_p%02d_10a_mplv%s_%03d.mat', listOfDyads(i), ...
                    passband, session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, 'data_mplv_10Hz');
  data{1, i} = data_mplv_10Hz.FP.dyad.mPLV;
  trialinfo{1, i} = data_mplv_10Hz.FP.dyad.trialinfo;
  data{2, i} = data_mplv_10Hz.PD.dyad.mPLV;
  trialinfo{2, i} = data_mplv_10Hz.PD.dyad.trialinfo;
  data{3, i} = data_mplv_10Hz.PS.dyad.mPLV;
  trialinfo{3, i} = data_mplv_10Hz.PS.dyad.trialinfo;
  data{4, i} = data_mplv_10Hz.C.dyad.mPLV;
  trialinfo{4, i} = data_mplv_10Hz.C.dyad.trialinfo;
  if i == 1
    data_mplv.centerFreq = data_mplv_10Hz.centerFreq;
    data_mplv.FP.label = data_mplv_10Hz.FP.dyad.label;
    data_mplv.PD.label = data_mplv_10Hz.PD.dyad.label;
    data_mplv.PS.label = data_mplv_10Hz.PS.dyad.label;
    data_mplv.C.label = data_mplv_10Hz.C.dyad.label;
  end
  clear data_mplv_10Hz
end
fprintf('\n');

data = fixTrialOrder(data, trialinfo, trialinfoOrg, listOfDyads);

for i=1:1:4
  for j=1:1:length(listOfDyads)
    data{i,j} = cat(3, data{i,j}{:});
  end
  data{i} = cat(4, data{i,:});
end

data(:,2:end) = [];

% -------------------------------------------------------------------------
% Estimate averaged Phase Locking Value (over dyads)
% ------------------------------------------------------------------------- 
fprintf('Averaging of Phase Locking Values over dyads at %s...\n\n', passband);
for i=1:1:4
  data{i} = nanmean(data{i}, 4);
  data{i} = squeeze(num2cell(data{i}, [1 2]))';
end

data_mplv.FP.mPLV = data{1};
data_mplv.PD.mPLV = data{2};
data_mplv.PS.mPLV = data{3};
data_mplv.C.mPLV = data{4};
data_mplv.dyads = listOfDyads;

end

function dataTmp = fixTrialOrder( dataTmp, trInf, trInfOrg, dyadNum )

condition = {'FP', 'PD', 'PS', 'C'};                                        % condition acronyms
emptyMatrix = NaN * ones(28,28);                                            % empty matrix with NaNs

for k = 1:1:4
  for l = 1:1:size(dataTmp, 2)
    if ~isequal(trInf{k,l}, trInfOrg{k})
      cprintf([1,0.5,0], ...
              sprintf('Dyad %d - Condition %s: False trial order detected and fixed.\n', ...
              dyadNum(l), condition{k}));
      [~, loc] = ismember(trInfOrg{k}, trInf{k,l});
      tmpBuffer = [];
      tmpBuffer{length(trInfOrg{k})} = [];                                  %#ok<AGROW>
      for m = 1:1:length(trInfOrg{k})
        if loc(m) == 0
          tmpBuffer{m} = emptyMatrix;
        else
          tmpBuffer(m) = dataTmp{k,l}(loc(m));
        end
      end
      dataTmp{k,l} = tmpBuffer;
    end
  end
end
  
end
