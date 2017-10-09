function [ data ] = RPS_calcMeanPLV( data )
% RPS_CALCMEANPLV estimates the mean of the phase locking values for all
% dyads and electrodes over the different conditions.
%
% Use as
%   [ data ] = RPS_calcMeanPLV( data )
%
%  where the input data have to be the result from RPS_PHASELOCKVAL
%
% This function requires the fieldtrip toolbox
% 
% See also RPS_DATASTRUCTURE, RPS_PHASELOCKVAL

% Copyright (C) 2017, Daniel Matthes, MPI CBS 

% -------------------------------------------------------------------------
% Estimate mean Phase Locking Value (mPLV)
% -------------------------------------------------------------------------
for condition=1:1:4
  switch condition
    case 1
      fprintf('Calc mean PLVs with a center frequency of %d Hz...\n', ...           
          data.centerFreq);
      fprintf('Condition FreePlay...\n');
      dataTmp = data.FP;
    case 2
      fprintf('Condition PredDiff...\n');
      dataTmp = data.PD;
    case 3
      fprintf('Condition PredSame...\n');
      dataTmp = data.PS;
    case 4
      fprintf('Condition Control...\n');
      dataTmp = data.C;
  end
        
  numOfTrials = size(dataTmp.dyad.PLV, 2);
  shifts = size(dataTmp.dyad.PLV, 1);

  dataTmp.dyad.mPLV{shifts, numOfTrials} = [];
  for i=1:1:numOfTrials
    for j=1:1:shifts
      dataTmp.dyad.mPLV{j,i} = mean(dataTmp.dyad.PLV{j,i}, 2);
    end
  end
  dataTmp.dyad = rmfield(dataTmp.dyad, {'time', 'PLV'});
  
  switch condition
    case 1
      data.FP = dataTmp;
    case 2
      data.PD = dataTmp;
    case 3
      data.PS = dataTmp;
    case 4
      data.C = dataTmp;
  end
end

end

