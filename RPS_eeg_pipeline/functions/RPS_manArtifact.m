function [ cfgAllArt ] = RPS_manArtifact( cfg, data )
% RPS_MANARTIFACT - this function could be use to is verify the automatic 
% detected artifacts remove some of them or add additional ones if
% required.
%
% Use as
%   [ cfgAllArt ] = RPS_manArtifact(cfg, data)
%
% where data has to be a result of RPS_PREPROCESSING
%
% The configuration options are
%   cfg.artifact  = output of RPS_autoArtifact (see file RPS_dxx_05a_autoart_yyy.mat)
%   cfg.dyad      = number of dyad (only necessary for adding markers to databrowser view) (default: []) 
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_PREPROCESSING, RPS_DATABROWSER

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
artifact  = ft_getopt(cfg, 'artifact', []);
dyad      = ft_getopt(cfg, 'dyad', []);

% -------------------------------------------------------------------------
% Initialize settings, build output structure
% -------------------------------------------------------------------------
cfg             = [];
cfg.dyad        = dyad;
cfg.channel     = {'all', '-V1', '-V2', '-H1', '-H2'};
cfg.ylim        = [-100 100];
cfgTmp.part1    = [];                                       
cfgTmp.part2    = [];
cfgAllArt.FP    = cfgTmp;
cfgAllArt.PD    = cfgTmp;
cfgAllArt.PS    = cfgTmp;
cfgAllArt.C     = cfgTmp;

% -------------------------------------------------------------------------
% Check Data
% -------------------------------------------------------------------------

fprintf('\nSearch for artifacts with part 1...\n');
cfg.part = 1;

fprintf('Condition FreePlay...\n');
cfg.artifact = artifact.FP.part1.artfctdef.threshold.artifact;
cfg.condition = 1;
ft_warning off;
cfgAllArt.FP.part1 = RPS_databrowser(cfg, data);
cfgAllArt.FP.part1 = keepfields(cfgAllArt.FP.part1, {'artfctdef', 'showcallinfo'});
  
fprintf('Condition PredDiff...\n');
cfg.artifact = artifact.PD.part1.artfctdef.threshold.artifact;
cfg.condition = 2;
ft_warning off;
cfgAllArt.PD.part1 = RPS_databrowser(cfg, data);
cfgAllArt.PD.part1 = keepfields(cfgAllArt.PD.part1, {'artfctdef', 'showcallinfo'});
  
fprintf('Condition PredSame...\n');
cfg.artifact = artifact.PS.part1.artfctdef.threshold.artifact;
cfg.condition = 3;
ft_warning off;
cfgAllArt.PS.part1 = RPS_databrowser(cfg, data);
cfgAllArt.PS.part1 = keepfields(cfgAllArt.PS.part1, {'artfctdef', 'showcallinfo'});
  
fprintf('Condition Control...\n');
cfg.artifact = artifact.C.part1.artfctdef.threshold.artifact;
cfg.condition = 4;
ft_warning off;
cfgAllArt.C.part1 = RPS_databrowser(cfg, data);
cfgAllArt.C.part1 = keepfields(cfgAllArt.C.part1, {'artfctdef', 'showcallinfo'});
  
fprintf('\nSearch for artifacts with part 2...\n');
cfg.part = 2;

fprintf('Condition FreePlay...\n');
cfg.artifact = artifact.FP.part2.artfctdef.threshold.artifact;
cfg.condition = 1;
ft_warning off;
cfgAllArt.FP.part2 = RPS_databrowser(cfg, data);
cfgAllArt.FP.part2 = keepfields(cfgAllArt.FP.part2, {'artfctdef', 'showcallinfo'});
  
fprintf('Condition PredDiff...\n');
cfg.artifact = artifact.PD.part2.artfctdef.threshold.artifact;
cfg.condition = 2;
ft_warning off;
cfgAllArt.PD.part2 = RPS_databrowser(cfg, data);
cfgAllArt.PD.part2 = keepfields(cfgAllArt.PD.part2, {'artfctdef', 'showcallinfo'});
  
fprintf('Condition PredSame...\n');
cfg.artifact = artifact.PS.part2.artfctdef.threshold.artifact;
cfg.condition = 3;
ft_warning off;
cfgAllArt.PS.part2 = RPS_databrowser(cfg, data);
cfgAllArt.PS.part2 = keepfields(cfgAllArt.PS.part2, {'artfctdef', 'showcallinfo'});
  
fprintf('Condition Control...\n');
cfg.artifact = artifact.C.part2.artfctdef.threshold.artifact;
cfg.condition = 4;
ft_warning off;
cfgAllArt.C.part2 = RPS_databrowser(cfg, data);
cfgAllArt.C.part2 = keepfields(cfgAllArt.C.part2, {'artfctdef', 'showcallinfo'});
  
ft_warning on;

end