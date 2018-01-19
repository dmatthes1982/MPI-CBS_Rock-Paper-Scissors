function [ data ] = RPS_ica( cfg, data )
% RPS_ICA conducts an independent component analysis on both participants
%
% Use as
%   [ data ] = RPS_ica( cfg, data )
%
% where the input data have to be the result from RPS_CONCATDATA
%
% The configuration options are
%   cfg.channel       = cell-array with channel selection (default = {'all', '-EOGV', '-EOGH', '-REF'})
%   cfg.numcomponent  = 'all' or number (default = 'all')
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_CONCATDATA

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
channel         = ft_getopt(cfg, 'channel', {'all', '-EOGV', '-EOGH', '-REF'});
numOfComponent  = ft_getopt(cfg, 'numcomponent', 'all');

% -------------------------------------------------------------------------
% ICA decomposition
% -------------------------------------------------------------------------
cfg               = [];
cfg.method        = 'runica';
cfg.channel       = channel;
cfg.trials        = 'all';
cfg.numcomponent  = numOfComponent;
cfg.demean        = 'no';
cfg.updatesens    = 'no';
cfg.showcallinfo  = 'no';

if isfield(data, 'part1')
  fprintf('\nICA decomposition for participant 1...\n\n');
  data.part1 = ft_componentanalysis(cfg, data.part1);
  
  fprintf('\nICA decomposition for participant 2...\n\n');
  data.part2 = ft_componentanalysis(cfg, data.part2);
else
  fprintf('\nICA decomposition for participant 1...\n');
  fprintf('Condition FreePlay...\n');
  data.FP.part1   = ft_componentanalysis(data.FP.part1); 
  fprintf('Condition PredDiff...\n');
  data.PD.part1   = ft_componentanalysis(data.PD.part1); 
  fprintf('Condition PredSame...\n');
  data.PS.part1   = ft_componentanalysis(data.PS.part1); 
  fprintf('Condition Control...\n');        
  data.C.part1   = ft_componentanalysis(data.C.part1); 

  fprintf('\nICA decomposition for participant 2...\n');
  fprintf('Condition FreePlay...\n');
  data.FP.part2   = ft_componentanalysis(data.FP.part2); 
  fprintf('Condition PredDiff...\n');
  data.PD.part2   = ft_componentanalysis(data.PD.part2); 
  fprintf('Condition PredSame...\n');
  data.PS.part2   = ft_componentanalysis(data.PS.part2); 
  fprintf('Condition Control...\n');        
  data.C.part2   = ft_componentanalysis(data.C.part2);
end

end
