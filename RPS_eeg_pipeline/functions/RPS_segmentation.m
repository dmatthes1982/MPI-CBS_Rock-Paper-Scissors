function [ data ] = RPS_segmentation( cfg, data )
% RPS_SEGMENTATION segments the data of each condition into segments with a
% certain length
%
% Use as
%   [ data ] = RPS_segmentation( data )
%
% where the input data can be the result from RPS_IMPORTDATASET, 
% RPS_PREPROCESSING, RPS_BPFILTERING or RPS_HILBERTPHASE
%
% The configuration options are
%   cfg.length    = length of segments (excepted values: 0.2, 1, 5, 10 seconds, default: 1)
%   cfg.overlap   = percentage of overlapping (range: 0 ... 1, default: 0)
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_IMPORTDATASET, RPS_PREPROCESSING, FT_REDEFINETRIAL,
% RPS_DATASTRUCTURE, RPS_BPFILTERING, RPS_HILBERTPHASE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
segLength = ft_getopt(cfg, 'length', 1);
overlap   = ft_getopt(cfg, 'overlap', 0);

possibleLengths = [0.2, 1, 5, 10];

if ~any(ismember(possibleLengths, segLength))
  error('Excepted cfg.length values are only 0.2, 1, 5 and 10 seconds');
end

% -------------------------------------------------------------------------
% Segmentation settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.feedback        = 'no';
cfg.showcallinfo    = 'no';
cfg.trials          = 'all';                                                  
cfg.length          = segLength;
cfg.overlap         = overlap;

% -------------------------------------------------------------------------
% Segmentation
% -------------------------------------------------------------------------
fprintf('<strong>Segment data of participant 1 in segments of %d sec...</strong>\n', ...
        segLength);
ft_info off;
ft_warning off;
fprintf('Condition FreePlay...\n');
data.FP.part1 = ft_redefinetrial(cfg, data.FP.part1);
ft_info off;
ft_warning off;
fprintf('Condition PredDiff...\n');
data.PD.part1 = ft_redefinetrial(cfg, data.PD.part1);
ft_info off;
ft_warning off;
fprintf('Condition PredSame...\n');
data.PS.part1 = ft_redefinetrial(cfg, data.PS.part1);
ft_info off;
ft_warning off;
fprintf('Condition Control...\n');
data.C.part1 = ft_redefinetrial(cfg, data.C.part1);
    
fprintf('<strong>Segment data of participant 2 in segments of %d sec...</strong>\n', ...
        segLength);
ft_info off;
ft_warning off;
fprintf('Condition FreePlay...\n');
data.FP.part2 = ft_redefinetrial(cfg, data.FP.part2);
ft_info off;
ft_warning off;
fprintf('Condition PredDiff...\n');
data.PD.part2 = ft_redefinetrial(cfg, data.PD.part2);
ft_info off;
ft_warning off;
fprintf('Condition PredSame...\n');
data.PS.part2 = ft_redefinetrial(cfg, data.PS.part2);
ft_info off;
ft_warning off;
fprintf('Condition Control...\n');
data.C.part2 = ft_redefinetrial(cfg, data.C.part2);

ft_info on;
ft_warning on;
