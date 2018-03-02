function [ num ] = RPS_checkCondition( condition )
% RPS_CHECKCONDITION - This functions checks the defined condition. 
%
% Use as
%   [ num ] = RPS_checkCondition( condition )
%
% If condition is a number the function checks, if this number is equal to 
% one of the default values and return this number in case of confirmity. 
% If condition is a string, the function returns the associated number, if
% the given string is valid. Otherwise the function throws an error.
%
% All available condition strings and numbers are defined in
% RPS_DATASTRUCTURE
%
% SEE also RPS_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Default values
% -------------------------------------------------------------------------
defaultVals = [1, 2, 3, 4];

% -------------------------------------------------------------------------
% Check Condition
% -------------------------------------------------------------------------
if isnumeric(condition)                                                     % if condition is already numeric
  if isempty(find(defaultVals == condition, 1))
    error('%d is not a valid condition', condition);
  else
    num = condition;
  end
else                                                                        % if condition is specified as string
  switch condition
    case 'FreePlay'
      num = 1;
    case 'PredDiff'
      num = 2;
    case 'PredSame'
      num = 3;
    case 'Control'
      num = 4;
    otherwise
      error('%s is not a valid condition', condition);
  end
end
