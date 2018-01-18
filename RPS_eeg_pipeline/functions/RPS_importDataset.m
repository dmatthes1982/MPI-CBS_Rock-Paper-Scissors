function [ data ] = RPS_importDataset( cfg )
% RPS_IMPORTDATASET imports one specific dataset recorded with a device 
% from brain vision.
%
% Use as
%   [ data ] = RPS_importDataset( cfg )
%
% The configuration options are
%   cfg.path      = source path' (i.e. '/data/pt_01843/eegData/DualEEG_RPS_rawData/')
%   cfg.condition = condition string ('C', 'FP', 'PD', 'PS')
%   cfg.dyad      = number of dyad
%
% You can use relativ path specifications (i.e. '../../MATLAB/data/') or 
% absolute path specifications like in the example. Please be aware that 
% you have to mask space signs of the path names under linux with a 
% backslash char (i.e. '/home/user/test\ folder')
%
% This function requires the fieldtrip toolbox.
%
% See also FT_PREPROCESSING, RPS_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
path      = ft_getopt(cfg, 'path', []);
condition = ft_getopt(cfg, 'condition', []);
dyad      = ft_getopt(cfg, 'dyad', []);

if isempty(path)
  error('No source path is specified!');
end

if isempty(condition)
  error('No condition is specified!');
end

if isempty(dyad)
  error('No specific participant is defined!');
end

headerfile = sprintf('%sDualEEG_RPS_%s_%02d.vhdr', path, condition, dyad);

% -------------------------------------------------------------------------
% General definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/RPS_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% definition of all possible stimuli, which seperate trials. Two values for 
% each phase, the first one is the original one and the second one handles 
% the 'video trigger bug'
[~, condNum] = ismember(condition, generalDefinitions.condLetter);

eventvalues = [ generalDefinitions.phaseMark{condNum}(1,:) ...
                generalDefinitions.phaseMark{condNum}(2,:) ];

samplingRate = 500;
dur = generalDefinitions.duration{condNum} * samplingRate;

% -------------------------------------------------------------------------
% Data import
% -------------------------------------------------------------------------
% basis configuration for data import
cfg                     = [];
cfg.dataset             = headerfile;
cfg.trialfun            = 'ft_trialfun_general';
cfg.trialdef.eventtype  = 'Stimulus';
cfg.trialdef.prestim    = 0;
cfg.showcallinfo        = 'no';
cfg.feedback            = 'error';
cfg.trialdef.eventvalue = eventvalues;

cfg = ft_definetrial(cfg);                                                  % generate config for segmentation
cfg = rmfield(cfg, {'notification'});                                       % workarround for mergeconfig bug                       

for i = 1:1:size(cfg.trl, 1)                                                % correct false stimulus numbers
  if any(generalDefinitions.phaseNum128Bug{condNum} == cfg.trl(i,4))
    element = generalDefinitions.phaseNum128Bug{condNum} == cfg.trl(i,4);
    cfg.trl(i,4) = generalDefinitions.phaseNum{condNum}(element);
  end
end

for i = 1:1:length(cfg.trl)                                                 % set specific trial lengths
  element = generalDefinitions.phaseNum{condNum} == cfg.trl(i,4);
  cfg.trl(i, 2) = dur(element) + cfg.trl(i, 1) - 1;
end

elements = find(ismember(cfg.trl(:,4), 7));                                 % remove duplicates of marker 'S  7', if arduino button is pressed multiple times within one trial
if ~isempty(elements)
  duplicates = [];
  for i=2:1:length(elements)
    if elements(i) == elements(i-1) + 1
      duplicates = [duplicates elements(i)];                                %#ok<AGROW>
    end
  end
  cfg.trl(duplicates, :) = []; 
end

dataTmp = ft_preprocessing(cfg);                                            % import data

data.part1 = dataTmp;                                                       % split dataset into two datasets, one for each participant
data.part1.label = strrep(dataTmp.label(1:32), '_1', '');
for i=1:1:length(dataTmp.trial)
  data.part1.trial{i} = dataTmp.trial{i}(1:32,:);
end

data.part2 = dataTmp;
data.part2.label = strrep(dataTmp.label(33:64), '_2', '');
for i=1:1:length(dataTmp.trial)
  data.part2.trial{i} = dataTmp.trial{i}(33:64,:);
end

end
