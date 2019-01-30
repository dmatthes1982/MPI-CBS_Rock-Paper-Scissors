function [ data_eogcomp ] = RPS_selectBadComp( data_eogcomp, data_icacomp )
% RPS_VERIFYCOMP is a function to verify visually the ICA components having 
% a high correlation with one of the measured EOG signals.
%
% Use as
%   [ data_eogcomp ] = RPS_verifyComp( data_eogcomp, data_icacomp )
%
% where the input data_eogcomp has to be the result of RPS_CORRCOMP ans 
% data_icacomp the result of RPS_ICA
%
% This function requires the fieldtrip toolbox
%
% See also RPS_CORRCOMP, RPS_ICA and FT_DATABROWSER

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Verify correlating components
% -------------------------------------------------------------------------
fprintf('<strong>Verify EOG-correlating components at participant 1</strong>\n');
fprintf('<strong>Condition FreePlay...</strong>\n');
data_eogcomp.FP.part1 = verifyComp(data_eogcomp.FP.part1, data_icacomp.FP.part1);
fprintf('\n<strong>Condition PredDiff...</strong>\n');
data_eogcomp.PD.part1 = verifyComp(data_eogcomp.PD.part1, data_icacomp.PD.part1);
fprintf('\n<strong>Condition PredSame...</strong>\n');
data_eogcomp.PS.part1 = verifyComp(data_eogcomp.PS.part1, data_icacomp.PS.part1);
fprintf('\n<strong>Condition Control...</strong>\n');
data_eogcomp.C.part1  = verifyComp(data_eogcomp.C.part1, data_icacomp.C.part1);


fprintf('\n<strong>Verify EOG-correlating components at participant 2</strong>\n');
fprintf('<strong>Condition FreePlay...</strong>\n');
data_eogcomp.FP.part2 = verifyComp(data_eogcomp.FP.part2, data_icacomp.FP.part2);
fprintf('\n<strong>Condition PredDiff...</strong>\n');
data_eogcomp.PD.part2 = verifyComp(data_eogcomp.PD.part2, data_icacomp.PD.part2);
fprintf('\n<strong>Condition PredSame...</strong>\n');
data_eogcomp.PS.part2 = verifyComp(data_eogcomp.PS.part2, data_icacomp.PS.part2);
fprintf('\n<strong>Condition Control...</strong>\n');
data_eogcomp.C.part2  = verifyComp(data_eogcomp.C.part2, data_icacomp.C.part2);

end

%--------------------------------------------------------------------------
% SUBFUNCTION which does the verification of the EOG-correlating components
%--------------------------------------------------------------------------
function [ dataEOGComp ] = verifyComp( dataEOGComp, dataICAcomp )

numOfElements = 1:length(dataEOGComp.elements);

if ~isempty(numOfElements)
  idx = find(ismember(dataICAcomp.label, dataEOGComp.elements))';

  cfg               = [];
  cfg.layout        = 'mpi_002_customized_acticap32.mat';
  cfg.viewmode      = 'component';
  cfg.zlim          = 'maxabs';
  cfg.channel       = idx;
  cfg.blocksize     = 30;
  cfg.showcallinfo  = 'no';

  ft_info off;
  ft_databrowser(cfg, dataICAcomp);
  set(gcf, 'Position', [0, 0, 1000, 500]);
  movegui(gcf, 'center');
  colormap jet;
  ft_info on;

  commandwindow;
  selection = false;

  while selection == false
    fprintf('Do you want to deselect some of theses components?\n')
    for i = numOfElements
      [~, pos] = max(abs([dataEOGComp.eoghCorr(idx(i)) ...
                      dataEOGComp.eogvCorr(idx(i))]));
      if pos == 1
        corrVal = dataEOGComp.eoghCorr(idx(i)) * 100;
      else
        corrVal = dataEOGComp.eogvCorr(idx(i)) * 100;
      end
      fprintf('[%d] - %s - %2.1f %% correlation \n', i, ...
                      dataEOGComp.elements{i}, corrVal);
    end
    fprintf('Comma-seperate your selection and put it in squared brackets!\n');
    fprintf('Press simply enter if you do not want to deselect any component!\n');
    x = input('\nPlease make your choice! (i.e. [1,2,3]): ');

    if ~isempty(x)
      if ~all(ismember(x, numOfElements))
        selection = false;
        fprintf('At least one of the selected components does not exist.\n');
      else
        selection = true;
        fprintf('Component(s) %d will not used for eye artifact correction\n', x);

        dataEOGComp.elements = dataEOGComp.elements(~ismember(numOfElements,x));
      end
    else
      selection = true;
      fprintf('No Component will be rejected.\n');
    end
  end

  close(gcf);
else
  cprintf([1,0.5,0],'No component has passed the selected correlation threshold. Nothing to verify!\n');
  cprintf([1,0.5,0],'IMPORTANT: The following cleaning operation will keep the data as it is!\n');
end

end