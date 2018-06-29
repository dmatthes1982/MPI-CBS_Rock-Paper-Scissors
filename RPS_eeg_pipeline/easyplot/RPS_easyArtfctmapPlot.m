function RPS_easyArtfctmapPlot(cfg, cfg_autoart)
% RPS_EASYARTFCTMAPPLOT generates a multiplot of artifact maps for all 
% phases of a specific condition. A single map contains a artifact map for
% all trials off a specific phase from which one could determine  which
% electrode exceeds the artifact detection threshold in which time 
% segment. Artifact free segments are filled with green and the segments 
% which violates the threshold are colored in red.
%
% Use as
%   RPS_easyArtfctmapPlot(cfg, cfg_autoart)
%
% where cfg_autoart has to be a result from RPS_AUTOARTIFACT.
%
% The configuration options are 
%   cfg.part        = number of participant (default: 1)
%                     1 - plot map for participant 1
%                     2 - plot map for participant 2
%   cfg.condition   = condition (default: 2 or 'PredDiff', see RPS_DATASTRUCTURE)
%
% This function requires the fieldtrip toolbox
%
% See also RPS_AUTOARTIFACT, RPS_DATASTRUCTURE

% Copyright (C) 2018, Daniel Matthes, MPI CBS


% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
part  = ft_getopt(cfg, 'part', 1);                                          % get number of participant
cond  = ft_getopt(cfg, 'condition', 2);                                     % get condition number/string

filepath = fileparts(mfilename('fullpath'));                                % add utilities folder to path
addpath(sprintf('%s/../utilities', filepath));

cond = RPS_checkCondition( cond );                                          % check cfg.condition definition   
switch cond
  case 1
    cfg_autoart = cfg_autoart.FP;
  case 2
    cfg_autoart = cfg_autoart.PD;
  case 3
    cfg_autoart = cfg_autoart.PS;
  case 4
    cfg_autoart = cfg_autoart.C;
  otherwise
    error('Condition %d is not valid', cond);
end

if part == 1
  cfg_autoart = cfg_autoart.part1;
elseif part == 2
  cfg_autoart = cfg_autoart.part2;
else                                                                        % check validity of cfg.part
  error('Input structure seems to be no cfg_autoart element including participants fields');
end

% -------------------------------------------------------------------------
% Define colormap
% -------------------------------------------------------------------------
cmap = [0.6 0.8 0.4; 1 0.2 0.2];                                            % colormap with two colors, green tone for good segments, red tone for bad once

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/RPS_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Plot artifact map
% -------------------------------------------------------------------------
artfctmap   = cfg_autoart.artfctdef.threshold.artfctmap;                    % extract artifact maps from cfg_autoart structure
trialinfo   = cfg_autoart.artfctdef.threshold.trialinfo;                    % extract trilainfo from cfg_autoart structure
loc         = ismember(generalDefinitions.phaseNum{cond}, trialinfo);
phaseNum    = generalDefinitions.phaseNum{cond}(loc);
phases      = length(phaseNum);                                               % estimate number of unique phases, which are actually in the data
tmpMap      = cell(1,phases);                                               % generate temporary map cell array

for i=1:1:phases                                                            % concatenate trials of the same phase
  loc = ismember(trialinfo, phaseNum(i));
  tmpMap(i) = {cat(2, artfctmap{loc})};
end

artfctmap = tmpMap;

elements = sqrt(phases);                                                    % estimate structure of multiplot
rows = fix(elements);                                                       % try to create a nearly square design
rest = mod(elements, rows);

if rest > 0
  if rest > 0.5
    rows    = ceil(elements);
    columns = ceil(elements);
  else
    columns = ceil(elements);
  end
else
  columns = rows;
end

h = figure();                                                               % create main figure
colormap(h, cmap);                                                          % change colormap for this new figure

for i=1:1:phases
  subplot(rows,columns,i);
  imagesc(artfctmap{i},[0 1]);                                              % plot subelements
  xlabel('time in sec');
  ylabel('channels');
end

axes('Units','Normal');                                                     % set main title for the whole figure
h = title('Artifact Map');
set(gca,'visible','off')
set(h,'visible','on')

end
