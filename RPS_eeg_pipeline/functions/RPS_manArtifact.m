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
%   cfg.threshArt = output of RPS_AUTOARTIFACT (see file RPS_dxx_05a_autoart_yyy.mat)
%   cfg.manArt    = output of RPS_IMPORTALLCONDITIONS (see file RPS_dxx_01b_manart_yyy.mat)
%   cfg.dyad      = number of dyad (only necessary for adding markers to databrowser view) (default: []) 
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_PREPROCESSING, RPS_DATABROWSER, RPS_AUTOARTIFACT,
% RPS_IMPORTALLCONDITIONS

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
threshArt = ft_getopt(cfg, 'threshArt', []);
manArt    = ft_getopt(cfg, 'manArt', []);
dyad      = ft_getopt(cfg, 'dyad', []);

if isempty(threshArt)
  threshArt.FP.part1.artfctdef.threshold.artifact = [];
  threshArt.PD.part1.artfctdef.threshold.artifact = [];
  threshArt.PS.part1.artfctdef.threshold.artifact = [];
  threshArt.C.part1.artfctdef.threshold.artifact  = [];
  threshArt.FP.part2.artfctdef.threshold.artifact = [];
  threshArt.PD.part2.artfctdef.threshold.artifact = [];
  threshArt.PS.part2.artfctdef.threshold.artifact = [];
  threshArt.C.part2.artfctdef.threshold.artifact  = [];
end

if isempty(manArt)
  manArt.FP.part1.artfctdef.xxx.artifact  = [];
  manArt.PD.part1.artfctdef.xxx.artifact  = [];
  manArt.PS.part1.artfctdef.xxx.artifact  = [];
  manArt.C.part1.artfctdef.xxx.artifact   = [];
  manArt.FP.part2.artfctdef.xxx.artifact  = [];
  manArt.PD.part2.artfctdef.xxx.artifact  = [];
  manArt.PS.part2.artfctdef.xxx.artifact  = [];
  manArt.C.part2.artfctdef.xxx.artifact   = [];
end

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

fprintf('\n<strong>Search for artifacts with participant 1...</strong>\n');
cfg.part = 1;

fprintf('<strong>Condition FreePlay...</strong>\n');
cfg.threshArt = threshArt.FP.part1.artfctdef.threshold.artifact;
cfg.manArt    = manArt.FP.part1.artfctdef.xxx.artifact;
cfg.condition = 1;
ft_warning off;
RPS_easyArtfctmapPlot(cfg, threshArt);                                      % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420]; 
cfgAllArt.FP.part1 = RPS_databrowser(cfg, data);
close all;
cfgAllArt.FP.part1 = keepfields(cfgAllArt.FP.part1, {'artfctdef', 'showcallinfo'});
  
fprintf('<strong>Condition PredDiff...</strong>\n');
cfg.threshArt = threshArt.PD.part1.artfctdef.threshold.artifact;
cfg.manArt    = manArt.PD.part1.artfctdef.xxx.artifact;
cfg.condition = 2;
ft_warning off;
RPS_easyArtfctmapPlot(cfg, threshArt);                                      % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];
cfgAllArt.PD.part1 = RPS_databrowser(cfg, data);
close all;
cfgAllArt.PD.part1 = keepfields(cfgAllArt.PD.part1, {'artfctdef', 'showcallinfo'});
  
fprintf('<strong>Condition PredSame...</strong>\n');
cfg.threshArt = threshArt.PS.part1.artfctdef.threshold.artifact;
cfg.manArt    = manArt.PS.part1.artfctdef.xxx.artifact;
cfg.condition = 3;
ft_warning off;
RPS_easyArtfctmapPlot(cfg, threshArt);                                      % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];
cfgAllArt.PS.part1 = RPS_databrowser(cfg, data);
close all;
cfgAllArt.PS.part1 = keepfields(cfgAllArt.PS.part1, {'artfctdef', 'showcallinfo'});
  
fprintf('<strong>Condition Control...</strong>\n');
cfg.threshArt = threshArt.C.part1.artfctdef.threshold.artifact;
cfg.manArt    = manArt.C.part1.artfctdef.xxx.artifact;
cfg.condition = 4;
ft_warning off;
RPS_easyArtfctmapPlot(cfg, threshArt);                                      % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];
cfgAllArt.C.part1 = RPS_databrowser(cfg, data);
close all;
cfgAllArt.C.part1 = keepfields(cfgAllArt.C.part1, {'artfctdef', 'showcallinfo'});
  
fprintf('\n<strong>Search for artifacts with participant 2...</strong>\n');
cfg.part = 2;

fprintf('<strong>Condition FreePlay...</strong>\n');
cfg.threshArt = threshArt.FP.part2.artfctdef.threshold.artifact;
cfg.manArt    = manArt.FP.part2.artfctdef.xxx.artifact;
cfg.condition = 1;
ft_warning off;
RPS_easyArtfctmapPlot(cfg, threshArt);                                      % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];
cfgAllArt.FP.part2 = RPS_databrowser(cfg, data);
close all;
cfgAllArt.FP.part2 = keepfields(cfgAllArt.FP.part2, {'artfctdef', 'showcallinfo'});
  
fprintf('<strong>Condition PredDiff...</strong>\n');
cfg.threshArt = threshArt.PD.part2.artfctdef.threshold.artifact;
cfg.manArt    = manArt.PD.part2.artfctdef.xxx.artifact;
cfg.condition = 2;
ft_warning off;
RPS_easyArtfctmapPlot(cfg, threshArt);                                      % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];
cfgAllArt.PD.part2 = RPS_databrowser(cfg, data);
close all;
cfgAllArt.PD.part2 = keepfields(cfgAllArt.PD.part2, {'artfctdef', 'showcallinfo'});
  
fprintf('<strong>Condition PredSame...</strong>\n');
cfg.threshArt = threshArt.PS.part2.artfctdef.threshold.artifact;
cfg.manArt    = manArt.PS.part2.artfctdef.xxx.artifact;
cfg.condition = 3;
ft_warning off;
RPS_easyArtfctmapPlot(cfg, threshArt);                                      % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];
cfgAllArt.PS.part2 = RPS_databrowser(cfg, data);
close all;
cfgAllArt.PS.part2 = keepfields(cfgAllArt.PS.part2, {'artfctdef', 'showcallinfo'});
  
fprintf('<strong>Condition Control...</strong>\n');
cfg.threshArt = threshArt.C.part2.artfctdef.threshold.artifact;
cfg.manArt    = manArt.C.part2.artfctdef.xxx.artifact;
cfg.condition = 4;
ft_warning off;
RPS_easyArtfctmapPlot(cfg, threshArt);                                      % plot artifact map
fig = gcf;                                                                  % default position is [560 528 560 420]
fig.Position = [0 528 560 420];
cfgAllArt.C.part2 = RPS_databrowser(cfg, data);
close all;
cfgAllArt.C.part2 = keepfields(cfgAllArt.C.part2, {'artfctdef', 'showcallinfo'});
  
ft_warning on;

end
