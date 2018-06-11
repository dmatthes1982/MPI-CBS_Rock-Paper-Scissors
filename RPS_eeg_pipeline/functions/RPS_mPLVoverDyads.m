function [ data_mplv ] = RPS_mPLVoverDyads( cfg )
% RPS_MPLVOVERDYADS estimates the mean of the phase locking values within 
% the different phases and conditions over all dyads.
%
% Use as
%   [ data_mplv ] = RPS_mPLVoverDyads( cfg )
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

% Copyright (C) 2017, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01843/eegData/DualEEG_RPS_processedData/07b_mplv/');
session   = ft_getopt(cfg, 'session', 1);
passband  = ft_getopt(cfg, 'passband', 'alpha');

bands     = {'alpha', 'beta', 'gamma', 'gammahigh'};
suffix    = {'Alpha', 'Beta', 'Gamma', 'Gammahigh'};

if ~any(strcmp(passband, bands))
  error('Define cfg.passband could only be ''alpha'', ''beta'', ''gamma'' or ''gammahigh''.');
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
    listOfDyads = x;
  end
end
fprintf('\n');

% -------------------------------------------------------------------------
% Load and organize data
% -------------------------------------------------------------------------
data_mplv.FP.trialinfo = generalDefinitions.phaseNum{1};
data_mplv.PD.trialinfo = generalDefinitions.phaseNum{2};
data_mplv.PS.trialinfo = generalDefinitions.phaseNum{3};
data_mplv.C.trialinfo  = generalDefinitions.phaseNum{4};

data{4, length(listOfDyads)} = [];
trialinfo{4, length(listOfDyads)} = []; 

for i=1:1:length(listOfDyads)
  filename = sprintf('RPS_d%02d_07b_mplv%s_%03d.mat', listOfDyads(i), ...
                    fileSuffix, session);
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
    data_mplv.centerFreq  = data_mplv_in.centerFreq;
    data_mplv.bpFreq      = data_mplv_in.bpFreq;
    data_mplv.FP.label    = data_mplv_in.FP.dyad.label;
    data_mplv.PD.label    = data_mplv_in.PD.dyad.label;
    data_mplv.PS.label    = data_mplv_in.PS.dyad.label;
    data_mplv.C.label     = data_mplv_in.C.dyad.label;
  end
  clear data_mplv_in
end
fprintf('\n');

data = fixTrialOrder(data, trialinfo, generalDefinitions.phaseNum, ...
                     listOfDyads);

for i=1:1:4
  for j=1:1:length(listOfDyads)
    data{i,j} = cat(3, data{i,j}{:});
  end
  if length(listOfDyads) > 1
    data{i} = cat(4, data{i,:});
  end
end

data(:,2:end) = [];

% -------------------------------------------------------------------------
% Estimate averaged phase locking value (over dyads)
% ------------------------------------------------------------------------- 
for i=1:1:4
  if length(listOfDyads) > 1
    data{i} = nanmean(data{i}, 4);
  else
    data{i} = data{i,1};
  end
  data{i} = squeeze(num2cell(data{i}, [1 2]))';
end

data_mplv.FP.mPLV = data{1};
data_mplv.PD.mPLV = data{2};
data_mplv.PS.mPLV = data{3};
data_mplv.C.mPLV = data{4};
data_mplv.dyads = listOfDyads;

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
