function [ data_eogcomp ] = RPS_selectBadComp( data_eogcomp, data_icacomp )
% RPS_ELECTBADCOMP is a function for exploring previously estimated ICA
% components visually. Within the GUI, each component can be set to either
% keep or reject for a later artifact correction operation. The result of
% RPS_DETEOGCOMP are preselected, but it should be visually explored too.
%
% Use as
%   [ data_eogcomp ] = RPS_selectBadComp( data_eogcomp, data_icacomp )
%
% where the input data_eogcomp has to be the result of RPS_DETEOGCOMP
% and data_icacomp the result of RPS_ICA
%
% This function requires the fieldtrip toolbox
%
% See also RPS_DETEOGCOMP, RPS_ICA and FT_ICABROWSER

% Copyright (C) 2017-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Verify correlating components
% -------------------------------------------------------------------------
fprintf('<strong>Select ICA components which shall be subtracted from data of participant 1</strong>\n');
fprintf('<strong>Condition FreePlay...</strong>\n');
data_eogcomp.FP.part1 = selectComp(data_eogcomp.FP.part1, data_icacomp.FP.part1);
fprintf('\n<strong>Condition PredDiff...</strong>\n');
data_eogcomp.PD.part1 = selectComp(data_eogcomp.PD.part1, data_icacomp.PD.part1);
fprintf('\n<strong>Condition PredSame...</strong>\n');
data_eogcomp.PS.part1 = selectComp(data_eogcomp.PS.part1, data_icacomp.PS.part1);
fprintf('\n<strong>Condition Control...</strong>\n');
data_eogcomp.C.part1  = selectComp(data_eogcomp.C.part1, data_icacomp.C.part1);


fprintf('\n<strong>Select ICA components which shall be subtracted from data of participant 2</strong>\n');
fprintf('<strong>Condition FreePlay...</strong>\n');
data_eogcomp.FP.part2 = selectComp(data_eogcomp.FP.part2, data_icacomp.FP.part2);
fprintf('\n<strong>Condition PredDiff...</strong>\n');
data_eogcomp.PD.part2 = selectComp(data_eogcomp.PD.part2, data_icacomp.PD.part2);
fprintf('\n<strong>Condition PredSame...</strong>\n');
data_eogcomp.PS.part2 = selectComp(data_eogcomp.PS.part2, data_icacomp.PS.part2);
fprintf('\n<strong>Condition Control...</strong>\n');
data_eogcomp.C.part2  = selectComp(data_eogcomp.C.part2, data_icacomp.C.part2);

end

%--------------------------------------------------------------------------
% SUBFUNCTION which provides the ft_icabrowser for verification of the
% EOG-correlating components and for the selection of further bad
% components.
%--------------------------------------------------------------------------
function [ dataEOGComp ] = selectComp( dataEOGComp, dataICAcomp )

numOfElements = 1:length(dataEOGComp.elements);
idx = find(ismember(dataICAcomp.label, dataEOGComp.elements))';

fprintf(['Select components to reject!\n'...
         'Components which exceeded the selected EOG correlation '...'
         'threshold are already marked as bad.\n'...
         'These are:\n']);

for i = numOfElements
  [~, pos] = max(abs([dataEOGComp.eoghCorr(idx(i)) ...
                  dataEOGComp.eogvCorr(idx(i))]));
  if pos == 1
    corrVal = dataEOGComp.eoghCorr(idx(i)) * 100;
  else
    corrVal = dataEOGComp.eogvCorr(idx(i)) * 100;
  end
  fprintf('[%d] - component %d - %2.1f %% correlation\n', i, idx(i), corrVal);
end

filepath = fileparts(mfilename('fullpath'));                                % load cap layout
load(sprintf('%s/../layouts/mpi_002_customized_acticap32.mat', filepath), ...
     'lay');

cfg               = [];
cfg.rejcomp       = idx;
cfg.blocksize     = 30;
cfg.layout        = lay;
cfg.zlim          = 'maxabs';
cfg.colormap      = 'jet';
cfg.showcallinfo  = 'no';

ft_warning off;
badComp = ft_icabrowser(cfg, dataICAcomp);
ft_warning on;

if sum(badComp) == 0
  cprintf([1,0.5,0],'No component is selected!\n');
  cprintf([1,0.5,0],'NOTE: The following cleaning operation will keep the data unchanged!\n');
end

dataEOGComp.elements = dataICAcomp.label(badComp);

end
