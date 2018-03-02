function RPS_writeTbl(cfg, data)
% RPS_WRITETBL writes the numbers of good trials for each phase in each 
% condition of a specific dyad in plv estimations to the associated file.
%
% Use as
%   RPS_writeTbl( cfg )
%
% The input data hast to be from RPS_PHASELOCKVAL
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01843/eegData/DualEEG_RPS_processedData/00_settings/')
%   cfg.dyad        = number of dyad
%   cfg.type        = type of documentation file (options: settings, plv)
%   cfg.param       = additional params for type 'plv' (options: '10Hz', '20Hz');
%   cfg.sessionStr  = number of session, format: %03d, i.e.: '003' (default: '001')
%
% This function requires the fieldtrip toolbox.
%
% SEE also RPS_PHASELOCKVAL

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = ft_getopt(cfg, 'desFolder', ...
          '/data/pt_01843/eegData/DualEEG_RPS_processedData/00_settings/');
dyad        = ft_getopt(cfg, 'dyad', []);
type        = ft_getopt(cfg, 'type', []);
param       = ft_getopt(cfg, 'param', []);
sessionStr  = ft_getopt(cfg, 'sessionStr', []);

if isempty(dyad)
  error('cfg.dyad has to be specified');
end

if isempty(type)
  error('cfg.type has to be specified. Currently it can be only ''plv''.');
end

if strcmp(type, 'plv')
  if isempty(param)
    error([ 'cfg.param has to be specified. Selectable options: '...
            '''10Hz'', ''20Hz''']);
  end
end

if isempty(sessionStr)
  error('cfg.sessionNum has to be specified');
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/RPS_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Extract trialinfo and number of good trials from data
% -------------------------------------------------------------------------
if strcmp(type, 'plv')
  trialinfo{1,1} = data.FP.dyad.trialinfo';
  gt{1,1} = data.FP.dyad.goodtrials';
  trialinfo{2,1} = data.PD.dyad.trialinfo';
  gt{2,1} = data.PD.dyad.goodtrials';
  trialinfo{3,1} = data.PS.dyad.trialinfo';
  gt{3,1} = data.PS.dyad.goodtrials';
  trialinfo{4,1} = data.C.dyad.trialinfo';
  gt{4,1} = data.C.dyad.goodtrials';
  
  goodtrials{4} = [];
    
  for i = 1:1:4
    [~,loc] = ismember(generalDefinitions.phaseNum{i}, trialinfo{i});
    if any(loc == 0)
      emptyCond = (loc == 0);
      emptyCond = generalDefinitions.phaseNum{i}(emptyCond);
      str = vec2str(emptyCond, [], [], 0);
      warning(['The following trials are completely rejected: ' str]);
    end
    goodtrials{i} = zeros(1, length(generalDefinitions.phaseNum{i}));
    for j = 1:1:length(generalDefinitions.phaseNum{i})
      if loc(j) ~= 0
        goodtrials{i}(j) = gt{i}(loc(j));
      end
    end
    goodtrials{i} = num2cell(goodtrials{i});
  end
end

% -------------------------------------------------------------------------
% Generate output file, if necessary
% -------------------------------------------------------------------------
if strcmp(type, 'plv')
  file_path = [desFolder sprintf('%s_%s_%s', type, param, sessionStr) '.xls'];
end

if ~(exist(file_path, 'file') == 2)                                         % check if file already exist
  cfg = [];
  cfg.desFolder   = desFolder;
  cfg.type        = type;
  cfg.param       = param;
  cfg.sessionStr  = sessionStr;
  
  RPS_createTbl(cfg);                                                       % create file
end

% -------------------------------------------------------------------------
% Update table
% -------------------------------------------------------------------------
T = readtable(file_path);
delete(file_path);
warning off;
T.dyad(dyad) = dyad;
if strcmp(type, 'plv')
  T(dyad, 2:end) = [goodtrials{1} goodtrials{2} goodtrials{3} goodtrials{4}];
end
warning on;
writetable(T, file_path);

end
