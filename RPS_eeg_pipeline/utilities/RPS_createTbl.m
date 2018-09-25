function RPS_createTbl( cfg )
% RPS_CREATETBL generates '*.xls' files for the documentation of the data 
% processing process. Currently two different types of doc files are
% supported.
%
% Use as
%   RPS_createTbl( cfg )
%
% The configuration options are
%   cfg.desFolder   = destination folder (default: '/data/pt_01843/eegData/DualEEG_RPS_processedData/00_settings/')
%   cfg.type        = type of documentation file (options: 'settings', 'plv')
%   cfg.param       = additional params for type 'plv' (options: 'alpha', 'beta', 'gamma');
%   cfg.sessionStr  = number of session, format: %03d, i.e.: '003' (default: '001')
%
% Explanation:
%   type settings - holds information about the selectable values: fsample, reference and ICAcorrVal
%   type plv      - holds the number of good trials for each condition in case of plv estimation
%
% This function requires the fieldtrip toolbox.

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get config options
% -------------------------------------------------------------------------
desFolder   = ft_getopt(cfg, 'desFolder', ...
          '/data/pt_01843/eegData/DualEEG_RPS_processedData/00_settings/');
type        = ft_getopt(cfg, 'type', []);
param       = ft_getopt(cfg, 'param', []);
sessionStr  = ft_getopt(cfg, 'sessionStr', []);

if isempty(type)
  error(['cfg.type has to be specified. It could be either ''settings'' '...
         'or ''plv''.']);
end

if strcmp(type, 'plv')
  if isempty(param)
    error([ 'cfg.param has to be specified. Selectable options: '...
            '''10Hz'', ''20Hz''']);
  end
end

if isempty(sessionStr)
  error('cfg.sessionStr has to be specified');
end

% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/RPS_generalDefinitions.mat', filepath), ...
     'generalDefinitions');

% -------------------------------------------------------------------------
% Create table
% -------------------------------------------------------------------------
switch type
  case 'settings'
    T = table(1,{'unknown'},{'unknown'},{'unknown'},{'unknown'}, ...
              {'unknown'},{'unknown'},{'unknown'},{'unknown'},0, ...
              {'unknown'},{'unknown'},{'unknown'},0,{'unknown'},0, ...
              {'unknown'},{'unknown'},{'unknown'});
    T.Properties.VariableNames = {'dyad', 'bChanFPp1', 'bChanFPp2', ...
                                  'bChanPDp1', 'bChanPDp2', 'bChanPSp1',...
                                  'bChanPSp2', 'bChanCp1', 'bChanCp2', ...
                                  'fsample', 'reference', 'bandpass', ...
                                  'lineNoiseFilt', 'ICAcorrVal', ...
                                  'artMethod', 'artThreshold', ...
                                  'rejectBadCycles', 'artRejectPLV', ...
                                  'artRejectPSD'};
    filepath = [desFolder type '_' sessionStr '.xls'];
    writetable(T, filepath);
  case 'plv'
    A(1) = {1};
    numberOfColumns = length(generalDefinitions.phaseNum{1}) + ...
                      length(generalDefinitions.phaseNum{2}) + ...
                      length(generalDefinitions.phaseNum{3}) + ...
                      length(generalDefinitions.phaseNum{4}) + 1;
    A(2:numberOfColumns) = {0};
    T = cell2table(A);
    FP  = num2cell(generalDefinitions.phaseNum{1});
    PD  = num2cell(generalDefinitions.phaseNum{2});
    PS  = num2cell(generalDefinitions.phaseNum{3});
    C   = num2cell(generalDefinitions.phaseNum{4});
    FP  = cellfun(@(x) sprintf('S%d_FP', x), FP, 'UniformOutput', 0); 
    PD  = cellfun(@(x) sprintf('S%d_PD', x), PD, 'UniformOutput', 0);
    PS  = cellfun(@(x) sprintf('S%d_PS', x), PS, 'UniformOutput', 0);
    C   = cellfun(@(x) sprintf('S%d_C', x), C, 'UniformOutput', 0);
    VarNames = [{'dyad'} FP PD PS C];
    T.Properties.VariableNames = VarNames;
    filepath = [desFolder type '_' param '_' sessionStr '.xls'];
    writetable(T, filepath); 
  otherwise
    error('cfg.type is not valid. Use either ''settings'' or ''plv''.');
end

end
