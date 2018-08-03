function [ data ] = RPS_importDataset( cfg )
% RPS_IMPORTDATASET imports one specific dataset recorded with a device 
% from brain vision.
%
% Use as
%   [ data ] = RPS_importDataset( cfg )
%
% The configuration options are
%   cfg.path        = source path' (i.e. '/data/pt_01843/eegData/DualEEG_RPS_rawData/')
%   cfg.condition   = condition string ('C', 'FP', 'PD', 'PS')
%   cfg.dyad        = number of dyad
%   cfg.continuous  = 'yes' or 'no' (default: 'no')
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
path        = ft_getopt(cfg, 'path', []);
condition   = ft_getopt(cfg, 'condition', []);
dyad        = ft_getopt(cfg, 'dyad', []);
continuous  = ft_getopt(cfg, 'continuous', 'no');

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

if strcmp(continuous, 'no')
  % -----------------------------------------------------------------------
  % General definitions
  % -----------------------------------------------------------------------
  filepath = fileparts(mfilename('fullpath'));
  load(sprintf('%s/../general/RPS_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

  % definition of all possible stimuli, which seperate trials. Two values 
  % for each phase, the first one is the original one and the second one 
  % handles the 'video trigger bug'
  [~, condNum] = ismember(condition, generalDefinitions.condLetter);

  eventvalues = [ generalDefinitions.phaseMark{condNum}(1,:) ...
                generalDefinitions.phaseMark{condNum}(2,:) ];

  samplingRate = 500;
  dur = generalDefinitions.duration{condNum} * samplingRate;

  % -----------------------------------------------------------------------
  % Generate trial definition
  % -----------------------------------------------------------------------
  % basis configuration for data import
  cfg                     = [];
  cfg.dataset             = headerfile;
  cfg.trialfun            = 'ft_trialfun_general';
  cfg.trialdef.eventtype  = 'Stimulus';
  cfg.trialdef.prestim    = 0;
  cfg.showcallinfo        = 'no';
  cfg.feedback            = 'error';
  cfg.trialdef.eventvalue = eventvalues;

  cfg = ft_definetrial(cfg);                                                % generate config for segmentation
  cfg = rmfield(cfg, {'notification'});                                     % workarround for mergeconfig bug                       

  for i = 1:1:size(cfg.trl, 1)                                              % correct false stimulus numbers
    if any(generalDefinitions.phaseNum128Bug{condNum} == cfg.trl(i,4))
      element = generalDefinitions.phaseNum128Bug{condNum} == cfg.trl(i,4);
      cfg.trl(i,4) = generalDefinitions.phaseNum{condNum}(element);
    end
  end

  for i = 1:1:length(cfg.trl)                                               % set specific trial lengths
    element = generalDefinitions.phaseNum{condNum} == cfg.trl(i,4);
    cfg.trl(i, 2) = dur(element) + cfg.trl(i, 1) - 1;
  end

  elements = find(ismember(cfg.trl(:,4), 7));                               % remove duplicates of marker 'S  7', if arduino button is pressed multiple times within one trial
  if ~isempty(elements)
    duplicates = find((elements(1:end-1) + 1) == elements(2:end));
    if ~isempty(duplicates)
      for i=1:1:length(duplicates)
        warning('off','backtrace');
        warning(['duplicate of marker ''S  7'' found, trial %d will '...
                 'be removed.'], elements(duplicates(i) + 1));
        warning('on','backtrace');
      end
    end
    cfg.trl(elements(duplicates + 1), :) = []; 
  end
  
  overlapping = find(cfg.trl(1:end-1,2) > cfg.trl(2:end, 1));               % in case of overlapping trials, remove the first of theses trials
  if ~isempty(overlapping)
    for i = 1:1:length(overlapping)
      warning('off','backtrace');
      warning(['trial %d with marker ''S%3d''  will be removed due to '...
               'overlapping data with its successor.'], ...
               overlapping(i), cfg.trl(overlapping(i), 4));
      warning('on','backtrace');
    end
    cfg.trl(overlapping, :) = []; 
  end

  hdr = ft_read_header(headerfile);                                         % read header file
  if cfg.trl(end,2) > hdr.nSamples                                          % adapt trial size, if recording was aborted
    cfg.trl(end,2) = hdr.nSamples;
  end

else
  cfg                     = [];
  cfg.dataset             = headerfile;
  cfg.showcallinfo        = 'no';
  cfg.feedback            = 'no';
end

% -------------------------------------------------------------------------
% Data import
% -------------------------------------------------------------------------
cfg.channel = {'all', '-F3',   '-F4',   '-CP5',   '-CP6'    ...             % exclude channels which are not connected
                      '-F3_1', '-F4_1', '-CP5_1', '-CP6_1'  ...
                      '-F3_2', '-F4_2', '-CP5_2', '-CP6_2'  ...
                      '-T7', '-T8', '-P7', '-P8', '-TP10'   ...             % exclude all general bad channels
                      '-T7_1', '-T7_2', '-T8_1', '-T8_2',   ...
                      '-P7_1', '-P7_2', '-P8_1', '-P8_2',   ...
                      '-TP10_1', '-TP10_2'};                       
dataTmp = ft_preprocessing(cfg);                                            % import data

data.part1 = dataTmp;                                                       % split dataset into two datasets, one for each participant
data.part1.label = strrep(dataTmp.label(1:23), '_1', '');
for i=1:1:length(dataTmp.trial)
  data.part1.trial{i} = dataTmp.trial{i}(1:23,:);
end

data.part2 = dataTmp;
data.part2.label = strrep(dataTmp.label(24:46), '_2', '');
for i=1:1:length(dataTmp.trial)
  data.part2.trial{i} = dataTmp.trial{i}(24:46,:);
end

% -------------------------------------------------------------------------
% Rename EOG related channels
% -------------------------------------------------------------------------
loc = ismember(data.part1.label, 'Fp1');
data.part1.label(loc) = {'V1'};
loc = ismember(data.part1.label, 'Fp2');
data.part1.label(loc) = {'V2'};
loc = ismember(data.part1.label, 'PO9');
data.part1.label(loc) = {'H1'};
loc = ismember(data.part1.label, 'PO10');
data.part1.label(loc) = {'H2'};

loc = ismember(data.part2.label, 'Fp1');
data.part2.label(loc) = {'V1'};
loc = ismember(data.part2.label, 'Fp2');
data.part2.label(loc) = {'V2'};
loc = ismember(data.part2.label, 'PO9');
data.part2.label(loc) = {'H1'};
loc = ismember(data.part2.label, 'PO10');
data.part2.label(loc) = {'H2'};

end
