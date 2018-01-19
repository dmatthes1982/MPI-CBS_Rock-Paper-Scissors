function [ data ] = RPS_selectdata( cfg, data )
% RPS_SELECTDATA extracts specified channels from a dataset
%
% Use as
%   [ data  ] = RPS_selectdata( cfg, data )
%
% where input data can be nearly every sensor space data
%
% The configuration options are
%   cfg.channel = Nx1 cell-array with selection of channels (default = 'all')
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_PREPROCESSING, RPS_SEGMENTATION, RPS_CONCATDATA,
% RPS_BPFILTERING

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
channel = ft_getopt(cfg, 'channel', 'all');

% -------------------------------------------------------------------------
% Channel extraction
% -------------------------------------------------------------------------
cfg              = [];
cfg.channel      = channel;
cfg.showcallinfo = 'no';

if isfield(data, 'part1')
  data.part1 = ft_selectdata(cfg, data.part1);
  data.part2 = ft_selectdata(cfg, data.part2);
else
  data.FP.part1 = ft_selectdata(cfg, data.FP.part1);
  data.FP.part2 = ft_selectdata(cfg, data.FP.part2);
  data.PD.part1 = ft_selectdata(cfg, data.PD.part1);
  data.PD.part2 = ft_selectdata(cfg, data.PD.part2);
  data.PS.part1 = ft_selectdata(cfg, data.PS.part1);
  data.PS.part2 = ft_selectdata(cfg, data.PS.part2);
  data.C.part1 = ft_selectdata(cfg, data.C.part1);
  data.C.part2 = ft_selectdata(cfg, data.C.part2);
end

end

