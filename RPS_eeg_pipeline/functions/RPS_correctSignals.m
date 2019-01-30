function [ data ] = RPS_correctSignals( data_eogcomp, data )
% RPS_CORRECTSIGNALS is a function which removes artifacts from data
% using previously estimated ica components
%
% Use as
%   [ data ] = RPS_correctSignals( data_eogcomp, data )
%
% where data_eogcomp has to be the result of RPS_SELECTBADCOMP or
% RPS_DETEOGCOMP and data has to be the result of RPS_PREPROCESSING
%
% This function requires the fieldtrip toolbox
%
% See also RPS_SELECTBADCOMP, RPS_DETEOGCOMP, RPS_PREPROCESSING,
% FT_COMPONENTANALYSIS and FT_REJECTCOMPONENT

% Copyright (C) 2017-2019, Daniel Matthes, MPI CBS

fprintf('<strong>Artifact correction with data of participant 1...</strong>\n');
fprintf('Condition FreePlay...\n');
data.FP.part1 = removeArtifacts(data_eogcomp.FP.part1, data.FP.part1);
fprintf('Condition PredDiff...\n');
data.PD.part1 = removeArtifacts(data_eogcomp.PD.part1, data.PD.part1);
fprintf('Condition PredSame...\n');
data.PS.part1 = removeArtifacts(data_eogcomp.PS.part1, data.PS.part1);
fprintf('Condition Control...\n');        
data.C.part1 = removeArtifacts(data_eogcomp.C.part1, data.C.part1);

fprintf('<strong>Artifact correction with data of participant 2...</strong>\n');
fprintf('Condition FreePlay...\n');
data.FP.part2 = removeArtifacts(data_eogcomp.FP.part2, data.FP.part2);
fprintf('Condition PredDiff...\n');
data.PD.part2 = removeArtifacts(data_eogcomp.PD.part2, data.PD.part2);
fprintf('Condition PredSame...\n');
data.PS.part2 = removeArtifacts(data_eogcomp.PS.part2, data.PS.part2);
fprintf('Condition Control...\n');        
data.C.part2 = removeArtifacts(data_eogcomp.C.part2, data.C.part2);

end

% -------------------------------------------------------------------------
% SUBFUNCTION which does the removal of artifacts
% -------------------------------------------------------------------------
function [ dataOfPart ] = removeArtifacts(  dataEOG, dataOfPart )

cfg               = [];
cfg.unmixing      = dataEOG.unmixing;
cfg.topolabel     = dataEOG.topolabel;
cfg.demean        = 'no';
cfg.showcallinfo  = 'no';

ft_info off;
dataComp = ft_componentanalysis(cfg, dataOfPart);                           % estimate components by using the in previous part 3 calculated unmixing matrix
ft_info on;

for i=1:length(dataEOG.elements)
  dataEOG.elements(i) = strrep(dataEOG.elements(i), 'runica', 'component'); % change names of eog-like components from runicaXXX to componentXXX
end

cfg               = [];
cfg.component     = find(ismember(dataComp.label, dataEOG.elements))';      % to be removed component(s)
cfg.demean        = 'no';
cfg.showcallinfo  = 'no';
cfg.feedback      = 'no';

ft_info off;
ft_warning off;
dataOfPart = ft_rejectcomponent(cfg, dataComp, dataOfPart);                 % revise data
ft_warning on;
ft_info on;

end
