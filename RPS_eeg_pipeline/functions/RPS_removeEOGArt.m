function [ data ] = RPS_removeEOGArt( data_eogcomp, data )
% RPS_REMOVEEOGART is a function which removes eye artifacts from data
% using in advance estimated ica components
%
% Use as
%   [ data ] = RPS_removeEOGArt( data_eogcomp, data )
%
% where data_eogcomp has to be the result of RPS_VERIFYCOMP or 
% RPS_CORRCOMP and data has to be the result of RPS_PREPROCESSING
%
% This function requires the fieldtrip toolbox
%
% See also RPS_VERIFYCOMP, RPS_CORRCOMP, RPS_PREPROCESSING,
% FT_COMPONENTANALYSIS and FT_REJECTCOMPONENT

% Copyright (C) 2017, Daniel Matthes, MPI CBS

fprintf('<strong>Cleanig data of participant 1 from eye-artifacts...</strong>\n');
fprintf('Condition FreePlay...\n');
data.FP.part1 = removeArtifacts(data_eogcomp.FP.part1, data.FP.part1);
fprintf('Condition PredDiff...\n');
data.PD.part1 = removeArtifacts(data_eogcomp.PD.part1, data.PD.part1);
fprintf('Condition PredSame...\n');
data.PS.part1 = removeArtifacts(data_eogcomp.PS.part1, data.PS.part1);
fprintf('Condition Control...\n');        
data.C.part1 = removeArtifacts(data_eogcomp.C.part1, data.C.part1);

fprintf('<strong>Cleanig data of participant 2 from eye-artifacts...</strong>\n');
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
dataComp = ft_componentanalysis(cfg, dataOfPart);                           % estimate components with the in previous part 3 calculated unmixing matrix
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
