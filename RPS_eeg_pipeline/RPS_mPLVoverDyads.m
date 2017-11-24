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
% This function requires the fieldtrip toolbox
% 
% See also RPS_CALCMEANPLV

% Copyright (C) 2017, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01843/eegData/DualEEG_RPS_processedData/11_mplv/');
            
session   = ft_getopt(cfg, 'session', 1);
passband  = ft_getopt(cfg, 'passband', '10Hz');

if ~strcmp(passband, '10Hz') && ~strcmp(passband, '20Hz')
  error('Define cfg.passband could only be ''10Hz'' por ''20Hz''.');
end

switch passband
  case '10Hz'
    letter = 'a';
  case '20Hz'
    letter = 'b';
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
dyadsList   = dir([path, sprintf('RPS_p*_11%s_mplv%s_%03d.mat', ...
                  letter, passband, session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['RPS_p%d_11'...
                                   sprintf('%s_mplv', letter) ...
                                   sprintf('%s_', passband) ...
                                   sprintf('%03d.mat', session)]);          %#ok<AGROW>
end

y = sprintf('%d ', listOfDyads);
selection = false;

while selection == false
  fprintf('The following dyads are available: %s\n', y);
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
  filename = sprintf('RPS_p%02d_11%s_mplv%s_%03d.mat', listOfDyads(i), ...
                    letter, passband, session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, sprintf('data_mplv_%s', passband));
  eval(['data_mplv_in=' sprintf('data_mplv_%s', passband) ';']);
  eval(['clear ' sprintf('data_mplv_%s', passband)]);
  data{1, i} = data_mplv_in.FP.dyad.mPLV;
  trialinfo{1, i} = data_mplv_in.FP.dyad.trialinfo;
  data{2, i} = data_mplv_in.PD.dyad.mPLV;
  trialinfo{2, i} = data_mplv_in.PD.dyad.trialinfo;
  data{3, i} = data_mplv_in.PS.dyad.mPLV;
  trialinfo{3, i} = data_mplv_in.PS.dyad.trialinfo;
  data{4, i} = data_mplv_in.C.dyad.mPLV;
  trialinfo{4, i} = data_mplv_in.C.dyad.trialinfo;
  if i == 1
    data_mplv.centerFreq = data_mplv_in.centerFreq;
    data_mplv.FP.label = data_mplv_in.FP.dyad.label;
    data_mplv.PD.label = data_mplv_in.PD.dyad.label;
    data_mplv.PS.label = data_mplv_in.PS.dyad.label;
    data_mplv.C.label = data_mplv_in.C.dyad.label;
  end
  clear data_mplv_in
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

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes trial Order an creates empty matrices for missing
% phases.
%--------------------------------------------------------------------------
function dataTmp = fixTrialOrder( dataTmp, trInf, trInfOrg, dyadNum )

condition = {'FP', 'PD', 'PS', 'C'};                                        % condition acronyms
emptyMatrix = NaN * ones(28,28);                                            % empty matrix with NaNs

for k = 1:1:4
  for l = 1:1:size(dataTmp, 2)
    if ~isequal(trInf{k,l}, trInfOrg{k})
      missingPhases = ~ismember(trInfOrg{k}, trInf{k,l});
      missingPhases = trInfOrg{k}(missingPhases);
      missingPhases = join_str(', ', num2cell(missingPhases)');
      cprintf([0,0.6,0], ...
              sprintf('Dyad %d - Condition %s: Phase(s) %s missing. Empty matrix(matrices) with NaNs created.\n', ...
              dyadNum(l), condition{k}, missingPhases));
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

%--------------------------------------------------------------------------
% SUBFUNCTION which transform a cell array of labels into a string
%--------------------------------------------------------------------------
function t = join_str(separator,cells)

if isempty(cells)
  t = '';
  return;
end

if ischar(cells)
  t = cells;
  return;
end

t = char(num2str(cells{1}));

for i=2:length(cells)
  t = [t separator char(num2str(cells{i}))];                                %#ok<AGROW>
end

end


end
