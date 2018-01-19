function [ data ] = RPS_concatData( data )
% RPS_CONCATDATA concatenate all trials of a dataset to a continuous data
% stream.
%
% Use as
%   [ data ] = RPS_concatData( data )
%
% where the input can be i.e. the result from RPS_IMPORTALLCONDITIONS or 
% RPS_PREPROCESSING
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_IMPORTALLCONDITIONS, RPS_PREPROCESSING

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Concatenate the data
% -------------------------------------------------------------------------
if isfield(data, 'part1')
  fprintf('Concatenate trials of participant 1...\n');
  data.part1   = concatenate(data.part1);
  
  fprintf('Concatenate trials of participant 2...\n');
  data.part2   = concatenate(data.part2);
else
  fprintf('Concatenate trials of participant 1...\n');
  fprintf('Condition FreePlay...\n');
  data.FP.part1   = concatenate(data.FP.part1); 
  fprintf('Condition PredDiff...\n');
  data.PD.part1   = concatenate(data.PD.part1); 
  fprintf('Condition PredSame...\n');
  data.PS.part1   = concatenate(data.PS.part1); 
  fprintf('Condition Control...\n');        
  data.C.part1   = concatenate(data.C.part1); 

  fprintf('Concatenate trials of participant 2...\n');
  fprintf('Condition FreePlay...\n');
  data.FP.part2   = concatenate(data.FP.part2); 
  fprintf('Condition PredDiff...\n');
  data.PD.part2   = concatenate(data.PD.part2); 
  fprintf('Condition PredSame...\n');
  data.PS.part2   = concatenate(data.PS.part2); 
  fprintf('Condition Control...\n');        
  data.C.part2   = concatenate(data.C.part2);
end

end

% -------------------------------------------------------------------------
% SUBFUNCTION for concatenation
% -------------------------------------------------------------------------
function [ dataset ] = concatenate( dataset )

numOfTrials = length(dataset.trial);                                        % estimate number of trials
trialLength = zeros(numOfTrials, 1);                                        
numOfChan   = size(dataset.trial{1}, 1);                                    % estimate number of channels

for i = 1:numOfTrials
  trialLength(i) = size(dataset.trial{i}, 2);                               % estimate length of single trials
end

dataLength  = sum( trialLength );                                           % estimate number of all samples in the dataset
data_concat = zeros(numOfChan, dataLength);
time_concat = zeros(1, dataLength);
endsample   = 0;

for i = 1:numOfTrials
  begsample = endsample + 1;
  endsample = endsample + trialLength(i);
  data_concat(:, begsample:endsample) = dataset.trial{i}(:,:);              % concatenate data trials
  if begsample == 1
    time_concat(1, begsample:endsample) = dataset.time{i}(:);               % concatenate time vectors
  else
    if (dataset.time{i}(1) == 0 )
      time_concat(1, begsample:endsample) = dataset.time{i}(:) + ...
                                time_concat(1, begsample - 1) + ...         % create continuous time scale
                                1/dataset.fsample;
    elseif(dataset.time{i}(1) > time_concat(1, begsample - 1))
      time_concat(1, begsample:endsample) = dataset.time{i}(:);             % keep existing time scale
    else
      time_concat(1, begsample:endsample) = dataset.time{i}(:) + ...
                                time_concat(1, begsample - 1) + ...         % create continuous time scale
                                1/dataset.fsample - ...
                                dataset.time{i}(1);
    end
  end
end

dataset.trial       = [];
dataset.time        = [];
dataset.trial{1}    = data_concat;                                          % add concatenated data to the data struct
dataset.time{1}     = time_concat;                                          % add concatenated time vector to the data struct
dataset.trialinfo   = 0;                                                    % add a fake event number to the trialinfo for subsequend artifact rejection
dataset.sampleinfo  = [1 dataLength];                                       % add also a fake sampleinfo for subsequend artifact rejection

end
