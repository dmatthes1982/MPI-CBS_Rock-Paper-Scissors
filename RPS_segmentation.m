function [ data ] = RPS_segmentation( data )
% RPS_SEGMENTATION segments the data of each condition into segments with a
% duration of 5 seconds
%
% Use as
%   [ data ] = RPS_segmentation( data )
%
% where the input data can be the result from RPS_IMPORTDATASET or
% RPS_PREPROCESSING
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_IMPORTDATASET, RPS_PREPROCESSING, FT_REDEFINETRIAL,
% RPS_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Segmentation settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.feedback        = 'no';
cfg.showcallinfo    = 'no';
cfg.trials          = 'all';                                                  
cfg.length          = 1;                                                    % segmentation into 1 seconds long segments
cfg.overlap         = 0;                                                    % no overlap

% -------------------------------------------------------------------------
% Segmentation
% -------------------------------------------------------------------------
fprintf('Segment data of participant 1...\n');
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
    
fprintf('Segment data of participant 2...\n');
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
