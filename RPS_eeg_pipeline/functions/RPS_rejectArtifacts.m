function [ data ] = RPS_rejectArtifacts( cfg, data )
% RPS_REJECTARTIFACTS is a function which removes trials containing 
% artifacts. It returns clean data.P.
%
% Use as
%   [ data ] = RPS_rejectartifacts( cfg, data )
%
% where data can be a result of RPS_SEGMENTATION, RPS_BPFILTERING or
% RPS_HILBERTPHASE
%
% The configuration options are
%   cfg.artifact  = output of RPS_manArtifact or RPS_manArtifact 
%                   (see file RPS_pxx_05_autoArt_yyy.mat, RPS_pxx_06_allArt_yyy.mat)
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_SEGMENTATION, RPS_BPFILTERING, RPS_HILBERTPHASE, 
% RPS_MANARTIFACT and RPS_AUTOARTIFACT 

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
artifact  = ft_getopt(cfg, 'artifact', []);

if isempty(artifact)
  error('cfg.artifact has to be defined');
end

% -------------------------------------------------------------------------
% Clean Data
% -------------------------------------------------------------------------
fprintf('\nCleaning data of part 1...\n');
fprintf('Condition FreePlay...\n');
ft_warning off;
data.FP.part1 = ft_rejectartifact(artifact.FP.part1, data.FP.part1);
ft_warning off;
data.FP.part1 = ft_rejectartifact(artifact.FP.part2, data.FP.part1);
fprintf('Condition PredDiff...\n');
ft_warning off;
data.PD.part1 = ft_rejectartifact(artifact.PD.part1, data.PD.part1);
ft_warning off;
data.PD.part1 = ft_rejectartifact(artifact.PD.part2, data.PD.part1);
fprintf('Condition PredSame...\n');
ft_warning off;
data.PS.part1 = ft_rejectartifact(artifact.PS.part1, data.PS.part1);
ft_warning off;
data.PS.part1 = ft_rejectartifact(artifact.PS.part2, data.PS.part1);
fprintf('Condition Control...\n');
ft_warning off;
data.C.part1 = ft_rejectartifact(artifact.C.part1, data.C.part1);
ft_warning off;
data.C.part1 = ft_rejectartifact(artifact.C.part2, data.C.part1);


fprintf('\nCleaning data of part 2...\n');
fprintf('Condition FreePlay...\n');
ft_warning off;
data.FP.part2 = ft_rejectartifact(artifact.FP.part1, data.FP.part2);
ft_warning off;
data.FP.part2 = ft_rejectartifact(artifact.FP.part2, data.FP.part2);
fprintf('Condition PredDiff...\n');
ft_warning off;
data.PD.part2 = ft_rejectartifact(artifact.PD.part1, data.PD.part2);
ft_warning off;
data.PD.part2 = ft_rejectartifact(artifact.PD.part2, data.PD.part2);
fprintf('Condition PredSame...\n');
ft_warning off;
data.PS.part2 = ft_rejectartifact(artifact.PS.part1, data.PS.part2);
ft_warning off;
data.PS.part2 = ft_rejectartifact(artifact.PS.part2, data.PS.part2);
fprintf('Condition Control...\n');
ft_warning off;
data.C.part2 = ft_rejectartifact(artifact.C.part1, data.C.part2);
ft_warning off;
data.C.part2 = ft_rejectartifact(artifact.C.part2, data.C.part2);

ft_warning on;

end
