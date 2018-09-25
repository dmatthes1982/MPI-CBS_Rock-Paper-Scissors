function [ data, cfg_manart ] = RPS_importDataset( cfg )
% RPS_IMPORTDATASET imports one specific dataset recorded with a device 
% from brain vision.
%
% Use as
%   [ data, cfg_manart ] = RPS_importDataset( cfg )
%
% The configuration options are
%   cfg.path        = source path' (i.e. '/data/pt_01843/eegData/DualEEG_RPS_rawData/')
%   cfg.condition   = condition string ('C', 'FP', 'PD', 'PS')
%   cfg.dyad        = number of dyad
%   cfg.continuous  = 'yes' or 'no' (default: 'no')
%
% The second output variable holds a artifact definition, which is created
% during data import. All cycles (complete set of all phases of a certain
% condition) in which descision markers are missing, in which they emerge
% to early or to late and in which the decisions were made mutiple times
% are marked as bad.
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

  % definition of all possible stimuli, which seperate trials.
  [~, condNum] = ismember(condition, generalDefinitions.condLetter);

  eventvalues = generalDefinitions.phaseMark{condNum};
  decisionvalues = generalDefinitions.decisionMark{condNum};

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

  for i = 1:1:length(cfg.trl)                                               % set specific trial lengths
    element = generalDefinitions.phaseNum{condNum} == cfg.trl(i,4);
    cfg.trl(i, 2) = dur(element) + cfg.trl(i, 1) - 1;
  end

  % -----------------------------------------------------------------------
  % 1.) Import decision markers
  % 2.) Find cycles where decisions are missing, where decisions are made
  % either to early or to late and where multiple decisions were made.
  % 3.) Mark trials theses cycles as bad.
  % -----------------------------------------------------------------------
  if ~(isempty(decisionvalues) || ismember(dyad, [7,8]))
    cfgD                      = [];
    cfgD.dataset              = headerfile;
    cfgD.trialfun             = 'ft_trialfun_general';
    cfgD.trialdef.eventtype   = 'Stimulus';
    cfgD.trialdef.prestim     = 0;
    cfgD.showcallinfo         = 'no';
    cfgD.feedback             = 'error';
    cfgD.trialdef.eventvalue  = decisionvalues;

    cfgD = ft_definetrial(cfgD);                                            % extract decision markers
    decisionList = [cfgD.trl(:,4), cfgD.trl(:,1)];                          % create a decision list

    begCycle = cfg.trl(ismember(cfg.trl(:,4), ...
                        generalDefinitions.phaseNum{condNum}(2)), 1);
    endCycle = cfg.trl(ismember(cfg.trl(:,4), ...
                        generalDefinitions.phaseNum{condNum}(end)), 2);
    cycle = [begCycle, endCycle];                                           % create a list with start and end sample numbers of all available cycles

    condButtonPress = cfg.trl(ismember(cfg.trl(:,4), ...
                        generalDefinitions.phaseNum{condNum}(3)), 1:2);     % create a list with start and end sample numbers of all available ButtonPress conditions

    tmp = NaN(size(cycle,1), 2);                                            % extend conditons list with NaN lines for cycles without ButtonPress conditions
    for i = 1:1:size(cycle,1)
      match = (cycle(i,1) <= condButtonPress(:,1)) & ...
          (cycle(i,2) >= condButtonPress(:,1));
      if any(match)
        tmp(i,:) = condButtonPress(match, :);
      end
    end
    condButtonPress = tmp;

    actPerCycle                 = zeros(size(cycle, 1), 1);                 % allocate memmory
    actPerCond                  = zeros(size(cycle, 1), 1);
    actions{size(cycle, 1), 1}  = [];

    for i = 1:1:size(cycle,1)
      row             = (cycle(i,1) <= decisionList(:,2) & ...
                          cycle(i,2) >= decisionList(:,2));
      actPerCycle(i)  = sum(row);                                           % estimate the numbers of decisions per cycle
      row             = (condButtonPress(i,1) <= decisionList(:,2) & ...
                          condButtonPress(i,2) >= decisionList(:,2));
      actPerCond(i)   = sum(row);                                           % estimate the numbers of decisions within condition ButtonPress
      actions{i}      = decisionList(row,1)';                               % estimate the specific decision markes within condition ButtonPress
    end

    wrongDecisionTime = actPerCycle ~= actPerCond;                          % estimate cycles where decisions are made either to early or to late
    multipleDecisions = actPerCond > 2;                                     % estimate cycles where multiple decisions were made
    condMissing = ~(cell2mat(cellfun(@(x) any(ismember(x, [1,2,3])), ...    % estimate cycles where decisions are missing
                    actions, 'UniformOutput', false)) & ...
                    cell2mat(cellfun(@(x) any(ismember(x, [4,5,6])), ...
                    actions, 'UniformOutput', false)));

    badCycles = wrongDecisionTime | multipleDecisions | condMissing;        % combine all cases to a vector of bad cycles
    artifact  = cycle(badCycles,:);
  end

  % ---------------------------------------------------------------------
  % Generate artifact config
  % ---------------------------------------------------------------------
  if ~(isempty(decisionvalues) || ismember(dyad, [7,8]))
    cfg_manart = [];
    cfg_manart.part1.artfctdef.xxx.artifact = artifact;
    cfg_manart.part2.artfctdef.xxx.artifact = artifact;
    cfg_manart.badNum = sum(badCycles);
  else
    cfg_manart = [];
    cfg_manart.part1.artfctdef.xxx.artifact = [];
    cfg_manart.part2.artfctdef.xxx.artifact = [];
    cfg_manart.badNum = 0;
  end

  % -----------------------------------------------------------------------
  % Remove duplicates of marker 'S  7',
  % if arduino button is pressed multiple times within one trial
  % -----------------------------------------------------------------------
  elements = find(ismember(cfg.trl(:,4), 7));
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
  
  % -----------------------------------------------------------------------
  % In case of overlapping trials, remove the first of theses trials
  % -----------------------------------------------------------------------
  overlapping = find(cfg.trl(1:end-1,2) > cfg.trl(2:end, 1));
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

  % -----------------------------------------------------------------------
  % Adapt trial size, if recording was aborted
  % -----------------------------------------------------------------------
  hdr = ft_read_header(headerfile);                                         % read header file
  if cfg.trl(end,2) > hdr.nSamples
    missing_samples = cfg.trl(end,2) - hdr.nSamples;
    cfg.trl(end,2) = hdr.nSamples;
    warning('off','backtrace');
    warning(['recording was finished to early, last trial is ' ...
             'shorter than expected, %d samples are missing'], ...
             missing_samples);
    warning('on','backtrace');
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
