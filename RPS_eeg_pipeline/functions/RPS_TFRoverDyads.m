function  [ data_tfrod ] = RPS_TFRoverDyads( cfg )
% RPS_TFROVERDYADS estimates the mean of the time frequency responses for 
% all conditions and over all phases and participants.
%
% Use as
%   [ data_tfrod ] = RPS_TFRoverDyads( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01843/eegData/DualEEG_RPS_processedDataOld/08a_tfr/')
%   cfg.session   = session number (default: 1)
%
% This function requires the fieldtrip toolbox
% 
% See also RPS_TIMEFREQANALYSIS

% Copyright (C) 2018, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', ...
              '/data/pt_01843/eegData/DualEEG_RPS_processedDataOld/08_tfr/');
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
fprintf('<strong>Averaging TFR values over dyads...</strong>\n');

dyadsList   = dir([path, sprintf('RPS_d*_08a_tfr_%03d.mat', session)]);
dyadsList   = struct2cell(dyadsList);
dyadsList   = dyadsList(1,:);
numOfDyads  = length(dyadsList);

for i=1:1:numOfDyads
  listOfDyads(i) = sscanf(dyadsList{i}, ['RPS_d%d_08a'...
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
% Load, organize and summarize data
% -------------------------------------------------------------------------
data_out.FP.trialinfo = generalDefinitions.phaseNum{1}';
data_out.PD.trialinfo = generalDefinitions.phaseNum{2}';
data_out.PS.trialinfo = generalDefinitions.phaseNum{3}';
data_out.C.trialinfo  = generalDefinitions.phaseNum{4}';

numOfTrials{1,1} = zeros(1, length(data_out.FP.trialinfo));
numOfTrials{2,1} = zeros(1, length(data_out.PD.trialinfo));
numOfTrials{3,1} = zeros(1, length(data_out.PS.trialinfo));
numOfTrials{4,1} = zeros(1, length(data_out.C.trialinfo));

tfr{1,1}{length(data_out.FP.trialinfo)} = [];
tfr{2,1}{length(data_out.PD.trialinfo)} = [];
tfr{3,1}{length(data_out.PS.trialinfo)} = [];
tfr{4,1}{length(data_out.C.trialinfo)} = [];

for i=1:1:numOfDyads
  filename = sprintf('RPS_d%02d_08a_tfr_%03d.mat', listOfDyads(i), ...
                     session);
  file = strcat(path, filename);
  fprintf('Load %s ...\n', filename);
  load(file, 'data_tfr');
  tfr_tmp{1,1}      = data_tfr.FP.part1.powspctrm;
  tfr_tmp{1,2}      = data_tfr.FP.part2.powspctrm;
  tfr_tmp{2,1}      = data_tfr.PD.part1.powspctrm;
  tfr_tmp{2,2}      = data_tfr.PD.part2.powspctrm;
  tfr_tmp{3,1}      = data_tfr.PS.part1.powspctrm;
  tfr_tmp{3,2}      = data_tfr.PS.part2.powspctrm;
  tfr_tmp{4,1}      = data_tfr.C.part1.powspctrm;
  tfr_tmp{4,2}      = data_tfr.C.part2.powspctrm;
  trialinfo_tmp(1,1:2)  = {data_tfr.FP.part1.trialinfo};
  trialinfo_tmp(2,1:2)  = {data_tfr.PD.part1.trialinfo};
  trialinfo_tmp(3,1:2)  = {data_tfr.PS.part1.trialinfo};
  trialinfo_tmp(4,1:2)  = {data_tfr.C.part1.trialinfo};
  if i == 1
    data_out.FP.label   = data_tfr.FP.part1.label;
    data_out.PD.label   = data_tfr.PD.part1.label;
    data_out.PS.label   = data_tfr.PS.part1.label;
    data_out.C.label    = data_tfr.C.part1.label;
    data_out.FP.dimord  = data_tfr.FP.part1.dimord;
    data_out.PD.dimord  = data_tfr.PD.part1.dimord;
    data_out.PS.dimord  = data_tfr.PS.part1.dimord;
    data_out.C.dimord   = data_tfr.C.part1.dimord;
    data_out.FP.freq    = data_tfr.FP.part1.freq;
    data_out.PD.freq    = data_tfr.PD.part1.freq;
    data_out.PS.freq    = data_tfr.PS.part1.freq;
    data_out.C.freq     = data_tfr.C.part1.freq;
    data_out.FP.time    = data_tfr.FP.part1.time;
    data_out.PD.time    = data_tfr.PD.part1.time;
    data_out.PS.time    = data_tfr.PS.part1.time;
    data_out.C.time     = data_tfr.C.part1.time;
    tfr{1}(:) = {zeros(length(data_out.FP.label), ... 
                      length(data_out.FP.freq), length(data_out.FP.time))};
    tfr{2}(:) = {zeros(length(data_out.PD.label), ... 
                      length(data_out.PD.freq), length(data_out.PD.time))};
    tfr{3}(:) = {zeros(length(data_out.PS.label), ... 
                      length(data_out.PS.freq), length(data_out.PS.time))};
    tfr{4}(:) = {zeros(length(data_out.C.label), ... 
                      length(data_out.C.freq), length(data_out.C.time))};
  end
  clear data_tfr
  
  trialSpec{4,2} = [];
  
  for j=1:1:4
    for k=1:1:2
    tfr_tmp{j,k} = num2cell(tfr_tmp{j,k}, [2,3,4])';
    tfr_tmp{j,k} = cellfun(@(x) squeeze(x), tfr_tmp{j,k}, ...
                            'UniformOutput', false);
    [tfr_tmp{j,k}, trialinfo_tmp{j,k}] = avgOverPhases(tfr_tmp{j,k}, ...
                                            trialinfo_tmp{j,k});                      
    [tfr_tmp{j,k}, trialSpec{j,k}] = fixTrialOrder( tfr_tmp{j,k}, ...
                   trialinfo_tmp{j,k}, generalDefinitions.phaseNum{j}, ...
                   listOfDyads(i), k, j);
    end
  tfr{j} = cellfun(@(x,y,z) x+y+z, tfr{j}, tfr_tmp{j,1}, tfr_tmp{j,2}, ...
                   'UniformOutput', false);
  numOfTrials{j} = numOfTrials{j} + trialSpec{j,1} + trialSpec{j,2};
  end
end
fprintf('\n');

for i=1:1:4
  numOfTrials{i} = num2cell(numOfTrials{i});

  tfr{i}  = cellfun(@(x,y) x/y, tfr{i}, numOfTrials{i}, ...
              'UniformOutput', false);
  tfr{i}    = cat(4, tfr{i}{:}); 
  tfr{i}    = shiftdim(tfr{i}, 3);
end

data_out.FP.powspctrm = tfr{1};
data_out.PD.powspctrm = tfr{2};
data_out.PS.powspctrm = tfr{3};
data_out.C.powspctrm  = tfr{4};
data_out.dyads        = listOfDyads;

data_tfrod = data_out;

end

%--------------------------------------------------------------------------
% SUBFUNCTION which averages the data of one participant over phases
%--------------------------------------------------------------------------
function [data_out, trialinfo_out] = avgOverPhases( data_in, trialinfo_in )

trialinfo_out = unique(trialinfo_in, 'stable');
data_out{length(trialinfo_out)} = [];

for i = 1:1:length(trialinfo_out)
  rows = ismember(trialinfo_in, trialinfo_out(i));
  data_tmp = data_in(rows);
  data_tmp = cat(4,data_tmp{:});
  data_out{i} = mean(data_tmp, 4);
end

end

%--------------------------------------------------------------------------
% SUBFUNCTION which fixes phase order and creates empty matrices for 
% missing phases.
%--------------------------------------------------------------------------
function [dataTmp, NoT] = fixTrialOrder( dataTmp, trlInf, trlInfOrg, ...
                                        dyadNum, part, cond )

condition = {'FP', 'PD', 'PS', 'C'};                                        % condition acronyms                                      
emptyMatrix = zeros(size(dataTmp{1}, 1), size(dataTmp{1}, 2), ...           % empty matrix
                    size(dataTmp{1}, 3));
NoT = ones(1, length(trlInfOrg));

if ~isequal(trlInf, trlInfOrg')
  missingPhases = ~ismember(trlInfOrg, trlInf);
  missingPhases = trlInfOrg(missingPhases);
  if ~isempty(missingPhases)
    missingPhases = vec2str(missingPhases, [], [], 0);
    cprintf([0,0.6,0], ...
          sprintf('Dyad %d/%d - Condition %s: Phase(s) %s missing. Empty matrix(matrices) with zeros created.\n', ...
          dyadNum, part, condition{cond}, missingPhases));
  end
  [~, loc] = ismember(trlInfOrg, trlInf);
  tmpBuffer = [];
  tmpBuffer{length(trlInfOrg)} = [];
  for j = 1:1:length(trlInfOrg)
    if loc(j) == 0
      NoT(j) = 0;
      tmpBuffer{j} = emptyMatrix;
    else
      tmpBuffer(j) = dataTmp(loc(j));
    end
  end
  dataTmp = tmpBuffer;
end


end
