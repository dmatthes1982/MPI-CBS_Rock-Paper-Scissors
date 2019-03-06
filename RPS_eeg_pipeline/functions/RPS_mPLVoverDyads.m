function [ data_mplvod ] = RPS_mPLVoverDyads( cfg )
% RPS_MPLVOVERDYADS estimates the mean of the phase locking values within 
% the different phases and conditions over all dyads.
%
% Use as
%   [ data_mplvod ] = RPS_mPLVoverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01843/eegData/DualEEG_RPS_processedData/07b_mplv/')
%   cfg.session   = session number (default: 1)
%   cfg.passband  = select passband of interest (default: alpha)
%                   (accepted values: alpha, beta, gamma, gammahigh)
%
% This function requires the fieldtrip toolbox
% 
% See also RPS_CALCMEANPLV

% Copyright (C) 2017-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01843/eegData/DualEEG_RPS_processedData/07b_mplv/');
session   = ft_getopt(cfg, 'session', 1);
passband  = ft_getopt(cfg, 'passband', 'alpha');

bands     = {'alpha', 'beta', 'gamma'};
suffix    = {'Alpha', 'Beta', 'Gamma'};

if ~any(strcmp(passband, bands))
  error('Define cfg.passband could only be ''alpha'', ''beta'' or ''gamma''.');
else
  fileSuffix = suffix{strcmp(passband, bands)};
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/RPS_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Select dyads
% -------------------------------------------------------------------------    
fprintf('<strong>Averaging of Phase Locking Values over dyads at %s...</strong>\n', passband);

dyadsList   = dir([path, sprintf('RPS_d*_07b_mplv%s_%03d.mat', ...
                   fileSuffix, session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['RPS_d%d_07b'...
                                   sprintf('%s_', fileSuffix) ...
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
    listOfDyads = unique(x);
    numOfDyads  = length(listOfDyads);
  end
end
fprintf('\n');

% -------------------------------------------------------------------------
% Load and organize data
% -------------------------------------------------------------------------
data_mplvod.FP.trialinfo = generalDefinitions.phaseNum{1};
data_mplvod.PD.trialinfo = generalDefinitions.phaseNum{2};
data_mplvod.PS.trialinfo = generalDefinitions.phaseNum{3};
data_mplvod.C.trialinfo  = generalDefinitions.phaseNum{4};

data{4, numOfDyads} = [];
trialinfo{4, numOfDyads} = [];

for i=1:1:numOfDyads
  filename = sprintf('RPS_d%02d_07b_mplv%s_%03d.mat', listOfDyads(i), ...
                    fileSuffix, session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, 'data_mplv');
  data{1, i} = data_mplv.FP.dyad.mPLV;
  trialinfo{1, i} = data_mplv.FP.dyad.trialinfo;
  data{2, i} = data_mplv.PD.dyad.mPLV;
  trialinfo{2, i} = data_mplv.PD.dyad.trialinfo;
  data{3, i} = data_mplv.PS.dyad.mPLV;
  trialinfo{3, i} = data_mplv.PS.dyad.trialinfo;
  data{4, i} = data_mplv.C.dyad.mPLV;
  trialinfo{4, i} = data_mplv.C.dyad.trialinfo;
  if i == 1
    data_mplvod.centerFreq  = data_mplv.centerFreq;
    data_mplvod.bpFreq      = data_mplv.bpFreq;
    data_mplvod.FP.label    = data_mplv.FP.dyad.label;
    data_mplvod.PD.label    = data_mplv.PD.dyad.label;
    data_mplvod.PS.label    = data_mplv.PS.dyad.label;
    data_mplvod.C.label     = data_mplv.C.dyad.label;
  end
  clear data_mplv
end
fprintf('\n');

data = fixTrialOrder(data, trialinfo, generalDefinitions.phaseNum, ...
                     listOfDyads);

for i=1:1:4
  for j=1:1:numOfDyads
    data{i,j} = cat(3, data{i,j}{:});
  end
  if numOfDyads > 1
    data{i} = cat(4, data{i,:});
  end
end

data(:,2:end) = [];

% -------------------------------------------------------------------------
% Estimate averaged phase locking value (over dyads)
% ------------------------------------------------------------------------- 
for i=1:1:4
  if numOfDyads > 1
    data{i} = nanmean(data{i}, 4);
  else
    data{i} = data{i,1};
  end
  data{i} = squeeze(num2cell(data{i}, [1 2]))';
end

data_mplvod.FP.mPLV = data{1};
data_mplvod.PD.mPLV = data{2};
data_mplvod.PS.mPLV = data{3};
data_mplvod.C.mPLV = data{4};
data_mplvod.dyads = listOfDyads;

end

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes trial order and creates empty matrices for 
% missing phases.
%--------------------------------------------------------------------------
function dataTmp = fixTrialOrder( dataTmp, trLInf, trlInfOrg, dyadNum )

condition = {'FP', 'PD', 'PS', 'C'};                                        % condition acronyms
emptyMatrix = NaN * ones(size(dataTmp{1}{1}, 1), size(dataTmp{1}{1}, 2));   % empty matrix with NaNs
fixed = false;

for k = 1:1:4
  for l = 1:1:size(dataTmp, 2)
    if ~isequal(trLInf{k,l}, trlInfOrg{k}')
      missingPhases = ~ismember(trlInfOrg{k}, trLInf{k,l});
      missingPhases = trlInfOrg{k}(missingPhases);
      missingPhases = vec2str(missingPhases, [], [], 0);
      cprintf([0,0.6,0], ...
              sprintf('Dyad %d - Condition %s: Phase(s) %s missing. Empty matrix(matrices) with NaNs created.\n', ...
              dyadNum(l), condition{k}, missingPhases));
      [~, loc] = ismember(trlInfOrg{k}, trLInf{k,l});
      tmpBuffer = [];
      tmpBuffer{length(trlInfOrg{k})} = [];                                  %#ok<AGROW>
      for m = 1:1:length(trlInfOrg{k})
        if loc(m) == 0
          tmpBuffer{m} = emptyMatrix;
        else
          tmpBuffer(m) = dataTmp{k,l}(loc(m));
        end
      end
      dataTmp{k,l} = tmpBuffer;
      fixed = true;
    end
  end
end

if fixed == true
  fprintf('\n');
end

end
