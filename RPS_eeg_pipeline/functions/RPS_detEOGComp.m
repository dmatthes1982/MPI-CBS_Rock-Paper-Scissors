function [ data_eogcomp ] = RPS_detEOGComp( cfg, data_icacomp, data_sensor )
% RPS_DETEOGCOMP determines components with a high correlation (> 80%)
% in respect of EOGV and EOGH components of the original data.
%
% Use as
%   [ data_eogcomp ] = RPS_detEOGComp( data_icacomp, data_sensor )
%
% The configuration options are
%    cfg.threshold = correlation threshold for marking eog-like components for each participant and condition
%                    (range: 0...1) default: {[0.8 0.8 0.8 0.8], [0.8 0.8 0.8 0.8]})
%
% where input data_icacomp has to be the results of RPS_ICA and
% data_sensor the results of RPS_SELECTDATA
%
% This function requires the fieldtrip toolbox
%
% See also RPS_ICA and RPS_SELECTDATA

% Copyright (C) 2017-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
threshold  = ft_getopt(cfg, 'threshold', {[0.8 0.8 0.8 0.8], [0.8 0.8 0.8 0.8]});

if (any(threshold{1} < 0) || any(threshold{1} > 1) )
  error('At least one threshold definition of participant 1 is out of range [0 1]');
end

if (any(threshold{2} < 0) || any(threshold{2} > 1) )
  error('At least one threshold definition of participant 2 is out of range [0 1]');
end

% -------------------------------------------------------------------------
% Estimate correlating components
% -------------------------------------------------------------------------
fprintf('<strong>Determine EOG-correlating components at participant 1...</strong>\n');
fprintf('Condition FreePlay...\n');
data_eogcomp.FP.part1 = corrComp(data_icacomp.FP.part1, data_sensor.FP.part1, threshold{1}(1));
fprintf('Condition PredDiff...\n');
data_eogcomp.PD.part1 = corrComp(data_icacomp.PD.part1, data_sensor.PD.part1, threshold{1}(2));
fprintf('Condition PredSame...\n');
data_eogcomp.PS.part1 = corrComp(data_icacomp.PS.part1, data_sensor.PS.part1, threshold{1}(3));
fprintf('Condition Control...\n');
data_eogcomp.C.part1  = corrComp(data_icacomp.C.part1, data_sensor.C.part1, threshold{1}(4));

fprintf('<strong>Determine EOG-correlating components at participant 2...</strong>\n');
fprintf('Condition FreePlay...\n');
data_eogcomp.FP.part2 = corrComp(data_icacomp.FP.part2, data_sensor.FP.part2, threshold{2}(1));
fprintf('Condition PredDiff...\n');
data_eogcomp.PD.part2 = corrComp(data_icacomp.PD.part2, data_sensor.PD.part2, threshold{2}(2));
fprintf('Condition PredSame...\n');
data_eogcomp.PS.part2 = corrComp(data_icacomp.PS.part2, data_sensor.PS.part2, threshold{2}(3));
fprintf('Condition Control...\n');
data_eogcomp.C.part2  = corrComp(data_icacomp.C.part2, data_sensor.C.part2, threshold{2}(4));

end

%--------------------------------------------------------------------------
% SUBFUNCTION which does the computation of the correlation coefficient
%--------------------------------------------------------------------------
function [ dataEOGComp ] = corrComp( dataICAComp, dataEOG, th )

numOfComp = length(dataICAComp.label);

eogvCorr = zeros(2,2,numOfComp);
eoghCorr = zeros(2,2,numOfComp);

eogvNum = strcmp('EOGV', dataEOG.label);
eoghNum = strcmp('EOGH', dataEOG.label);

for i=1:numOfComp
  eogvCorr(:,:,i) = corrcoef( dataEOG.trial{1}(eogvNum,:), ...
                              dataICAComp.trial{1}(i,:));
  eoghCorr(:,:,i) = corrcoef( dataEOG.trial{1}(eoghNum,:), ...
                              dataICAComp.trial{1}(i,:));
end

eogvCorr = squeeze(eogvCorr(1,2,:));
eoghCorr = squeeze(eoghCorr(1,2,:));

dataEOGComp.eogvCorr = eogvCorr;
dataEOGComp.eoghCorr = eoghCorr;

eogvCorr = abs(eogvCorr);
eoghCorr = abs(eoghCorr);

eogvCorr = (eogvCorr > th);
eoghCorr = (eoghCorr > th);

dataEOGComp.label      = dataICAComp.label;
dataEOGComp.topolabel  = dataICAComp.topolabel;
dataEOGComp.topo       = dataICAComp.topo;
dataEOGComp.unmixing   = dataICAComp.unmixing;
dataEOGComp.elements   = dataICAComp.label(eogvCorr | eoghCorr);

end

