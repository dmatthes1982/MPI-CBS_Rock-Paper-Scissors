function [ data ] = RPS_rejectArtifacts( cfg, data )
% RPS_REJECTARTIFACTS is a function which removes trials containing 
% artifacts. It returns clean data.
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
ft_warning off;
data.part1 = ft_rejectartifact(artifact.part1, data.part1);
ft_warning off;
data.part1 = ft_rejectartifact(artifact.part2, data.part1);
  
fprintf('\nCleaning data of part 2...\n');
ft_warning off;
data.part2 = ft_rejectartifact(artifact.part1, data.part2);
ft_warning off;
data.part2 = ft_rejectartifact(artifact.part2, data.part2);

ft_warning on;

end
