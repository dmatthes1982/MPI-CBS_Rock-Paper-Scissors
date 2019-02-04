function  [ data_pwelchod ] = RPS_powOverDyads( cfg )
% RPS_POWOVERDYADS estimates the mean of the power avtivity for all 
% conditions and over all participants.
%
% Use as
%   [ data_pwelchod ] = RPS_powOverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01843/eegData/DualEEG_RPS_processedData/08b_pwelch/')
%   cfg.session   = session number (default: 1)
%
% This function requires the fieldtrip toolbox
% 
% See also RPS_PWELCH

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01843/eegData/DualEEG_RPS_processedData/08b_pwelch/');
session   = ft_getopt(cfg, 'session', 1);

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/RPS_generalDefinitions.mat', filepath), ...
     'generalDefinitions');   

% -------------------------------------------------------------------------
% Select dyads
% -------------------------------------------------------------------------    
fprintf('<strong>Averaging power values over dyads...</strong>\n');

dyadsList   = dir([path, sprintf('RPS_d*_08b_pwelch_%03d.mat', session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['RPS_d%d_08b'...
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
data_out.FP.trialinfo = generalDefinitions.phaseNum{1}';
data_out.PD.trialinfo = generalDefinitions.phaseNum{2}';
data_out.PS.trialinfo = generalDefinitions.phaseNum{3}';
data_out.C.trialinfo  = generalDefinitions.phaseNum{4}';

data{4, 2 * numOfDyads} = [];
trialinfo{4, 2 * numOfDyads} = [];

for i=1:1:numOfDyads
  filename = sprintf('RPS_d%02d_08b_pwelch_%03d.mat', listOfDyads(i), ...
                     session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, 'data_pwelch');
  
  data{1, i}                    = data_pwelch.FP.part1.powspctrm;
  data{1, i + numOfDyads}       = data_pwelch.FP.part2.powspctrm;
  trialinfo{1, i}               = data_pwelch.FP.part1.trialinfo;
  trialinfo{1, i + numOfDyads}  = data_pwelch.FP.part2.trialinfo;
  data{2, i}                    = data_pwelch.PD.part1.powspctrm;
  data{2, i + numOfDyads}       = data_pwelch.PD.part2.powspctrm;
  trialinfo{2, i}               = data_pwelch.PD.part1.trialinfo;
  trialinfo{2, i + numOfDyads}  = data_pwelch.PD.part2.trialinfo;
  data{3, i}                    = data_pwelch.PS.part1.powspctrm;
  data{3, i + numOfDyads}       = data_pwelch.PS.part2.powspctrm;
  trialinfo{3, i}               = data_pwelch.PS.part1.trialinfo;
  trialinfo{3, i + numOfDyads}  = data_pwelch.PS.part2.trialinfo;
  data{4, i}                    = data_pwelch.C.part1.powspctrm;
  data{4, i + numOfDyads}       = data_pwelch.C.part2.powspctrm;
  trialinfo{4, i}               = data_pwelch.C.part1.trialinfo;
  trialinfo{4, i + numOfDyads}  = data_pwelch.C.part2.trialinfo;
  
  if i == 1
    data_out.FP.label   = data_pwelch.FP.part1.label;
    data_out.PD.label   = data_pwelch.PD.part1.label;
    data_out.PS.label   = data_pwelch.PS.part1.label;
    data_out.C.label    = data_pwelch.C.part1.label;
    data_out.FP.dimord  = data_pwelch.FP.part1.dimord;
    data_out.PD.dimord  = data_pwelch.PD.part1.dimord;
    data_out.PS.dimord  = data_pwelch.PS.part1.dimord;
    data_out.C.dimord   = data_pwelch.C.part1.dimord;
    data_out.FP.freq    = data_pwelch.FP.part1.freq;
    data_out.PD.freq    = data_pwelch.PD.part1.freq;
    data_out.PS.freq    = data_pwelch.PS.part1.freq;
    data_out.C.freq     = data_pwelch.C.part1.freq;
  end
  clear data_pwelch
end
fprintf('\n');

for i=1:1:4
  data(i,:) = cellfun(@(x) num2cell(x, [2,3])', data(i,:), ...
                      'UniformOutput', false);
  for j=1:1:2*numOfDyads
    data{i,j} = cellfun(@(x) squeeze(x), data{i,j}, 'UniformOutput', false);
  end
end

data = fixTrialOrder( data, trialinfo, generalDefinitions.phaseNum, ...
                      repmat(listOfDyads,1,2) );

for i=1:1:4
  data(i,:) = cellfun(@(x) cat(3, x{:}), data(i,:), 'UniformOutput', false);
  data(i,:) = cellfun(@(x) shiftdim(x, 2), data(i,:), 'UniformOutput', false);
  data{i} = cat(4, data{i,:});
end

data(:,2:end) = [];

% -------------------------------------------------------------------------
% Estimate averaged power spectrum (over dyads)
% -------------------------------------------------------------------------
for i=1:1:4
  data{i} = nanmean(data{i}, 4);
end

data_out.FP.powspctrm = data{1};
data_out.PD.powspctrm = data{2};
data_out.PS.powspctrm = data{3};
data_out.C.powspctrm = data{4};
data_out.dyads = listOfDyads;

data_pwelchod = data_out;

end

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes trial order and creates empty matrices for 
% missing phases.
%--------------------------------------------------------------------------
function dataTmp = fixTrialOrder( dataTmp, trInf, trInfOrg, dyadNum )

condition = {'FP', 'PD', 'PS', 'C'};                                        % condition acronyms
emptyMatrix = NaN * ones(size(dataTmp{1}{1}, 1), size(dataTmp{1}{1}, 2));   % empty matrix with NaNs
fixed = false;
part = [ones(1,length(dyadNum)/2) 2*ones(1,length(dyadNum)/2)];

for k = 1:1:4
  for l = 1:1:size(dataTmp, 2)
    if ~isequal(trInf{k, l}, trInfOrg{k}')
      missingPhases = ~ismember(trInfOrg{k}, trInf{k,l});
      missingPhases = trInfOrg{k}(missingPhases);
      missingPhases = vec2str(missingPhases, [], [], 0);
      cprintf([0,0.6,0], ...
              sprintf('Dyad %d/%d - Condition %s: Phase(s) %s missing. Empty matrix(matrices) with NaNs created.\n', ...
              dyadNum(l), part(l), condition{k}, missingPhases));
      [~, loc] = ismember(trInfOrg{k}, trInf{k, l});
      tmpBuffer = [];
      tmpBuffer{length(trInfOrg{k})} = [];                                  %#ok<AGROW>
      for m = 1:1:length(trInfOrg{k})
        if loc(m) == 0
          tmpBuffer{m} = emptyMatrix;
        else
          tmpBuffer(m) = dataTmp{k, l}(loc(m));
        end
      end
      dataTmp{k, l} = tmpBuffer;
      fixed = true;
    end
  end
end

if fixed == true
  fprintf('\n');
end

end
