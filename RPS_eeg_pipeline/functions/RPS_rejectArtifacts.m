function [ data ] = RPS_rejectArtifacts( cfg, data )
% RPS_REJECTARTIFACTS is a function which removes trials containing 
% artifacts. It returns clean data.P.
%
% Use as
%   [ data ] = RPS_rejectartifacts( cfg, data )
%
% where data can be a result of RPS_SEGMENTATION, RPS_BPFILTERING,
% RPS_CONCATDATA or RPS_HILBERTPHASE
%
% The configuration options are
%   cfg.artifact  = output of RPS_manArtifact or RPS_manArtifact 
%                   (see file RPS_pxx_05_autoArt_yyy.mat, RPS_pxx_06_allArt_yyy.mat)
%   cfg.reject    = 'none', 'partial','nan', or 'complete' (default = 'complete')
%   cfg.target    = type of rejection, options: 'single' or 'dual' (default: 'single');
%                   'single' = trials of a certain participant will be 
%                              rejected, if they are marked as bad 
%                              for that particpant (useable before ICA calc)
%                   'dual' = trials of a certain participant will be
%                            rejected, if they are marked as bad for
%                            that particpant or for the other participant
%                            of the dyad (useable for PLV calculation)
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
reject    = ft_getopt(cfg, 'reject', 'complete');
target    = ft_getopt(cfg, 'target', 'single');

if isempty(artifact)
  error('cfg.artifact has to be defined');
end

if ~strcmp(reject, 'complete')
  artifact.FP.part1.artfctdef.reject = reject;
  artifact.FP.part2.artfctdef.reject = reject;
  artifact.FP.part1.artfctdef.minaccepttim = 0.2;
  artifact.FP.part2.artfctdef.minaccepttim = 0.2;
  artifact.PD.part1.artfctdef.reject = reject;
  artifact.PD.part2.artfctdef.reject = reject;
  artifact.PD.part1.artfctdef.minaccepttim = 0.2;
  artifact.PD.part2.artfctdef.minaccepttim = 0.2;
  artifact.PS.part1.artfctdef.reject = reject;
  artifact.PS.part2.artfctdef.reject = reject;
  artifact.PS.part1.artfctdef.minaccepttim = 0.2;
  artifact.PS.part2.artfctdef.minaccepttim = 0.2;
  artifact.C.part1.artfctdef.reject = reject;
  artifact.C.part2.artfctdef.reject = reject;
  artifact.C.part1.artfctdef.minaccepttim = 0.2;
  artifact.C.part2.artfctdef.minaccepttim = 0.2;
end

% -------------------------------------------------------------------------
% Clean Data
% -------------------------------------------------------------------------
fprintf('\n<strong>Cleaning data of participant 1...</strong>\n');
fprintf('<strong>Condition FreePlay...</strong>\n');
ft_warning off;
data.FP.part1 = ft_rejectartifact(artifact.FP.part1, data.FP.part1);
if strcmp(target, 'dual')
  ft_warning off;
  data.FP.part1 = ft_rejectartifact(artifact.FP.part2, data.FP.part1);
end
fprintf('<strong>Condition PredDiff...</strong>\n');
ft_warning off;
data.PD.part1 = ft_rejectartifact(artifact.PD.part1, data.PD.part1);
if strcmp(target, 'dual')
  ft_warning off;
  data.PD.part1 = ft_rejectartifact(artifact.PD.part2, data.PD.part1);
end
fprintf('<strong>Condition PredSame...</strong>\n');
ft_warning off;
data.PS.part1 = ft_rejectartifact(artifact.PS.part1, data.PS.part1);
if strcmp(target, 'dual')
  ft_warning off;
  data.PS.part1 = ft_rejectartifact(artifact.PS.part2, data.PS.part1);
end
fprintf('<strong>Condition Control...</strong>\n');
ft_warning off;
data.C.part1 = ft_rejectartifact(artifact.C.part1, data.C.part1);
if strcmp(target, 'dual')
  ft_warning off;
  data.C.part1 = ft_rejectartifact(artifact.C.part2, data.C.part1);
end

fprintf('\n<strong>Cleaning data of participant 2...</strong>\n');
fprintf('<strong>Condition FreePlay...</strong>\n');
ft_warning off;
data.FP.part2 = ft_rejectartifact(artifact.FP.part2, data.FP.part2);
if strcmp(target, 'dual')
  ft_warning off;
  data.FP.part2 = ft_rejectartifact(artifact.FP.part1, data.FP.part2);
end
fprintf('<strong>Condition PredDiff...</strong>\n');
ft_warning off;
data.PD.part2 = ft_rejectartifact(artifact.PD.part2, data.PD.part2);
if strcmp(target, 'dual')
  ft_warning off;
  data.PD.part2 = ft_rejectartifact(artifact.PD.part1, data.PD.part2);
end
fprintf('<strong>Condition PredSame...</strong>\n');
ft_warning off;
data.PS.part2 = ft_rejectartifact(artifact.PS.part2, data.PS.part2);
if strcmp(target, 'dual')
  ft_warning off;
  data.PS.part2 = ft_rejectartifact(artifact.PS.part1, data.PS.part2);
end
fprintf('<strong>Condition Control...</strong>\n');
ft_warning off;
data.C.part2 = ft_rejectartifact(artifact.C.part2, data.C.part2);
if strcmp(target, 'dual')
  ft_warning off;
  data.C.part2 = ft_rejectartifact(artifact.C.part1, data.C.part2);
end

ft_warning on;

end
