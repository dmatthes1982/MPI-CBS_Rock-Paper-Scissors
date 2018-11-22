function [ data ] = RPS_preprocessing( cfg, data )
% RPS_PREPROCESSING does the preprocessing of the raw data. 
%
% Use as
%   [ data ] = RPS_preprocessing(cfg, data)
%
% where the input data has to be the result of RPS_IMPORTATASET
%
% The configuration options are
%   cfg.bpfreq            = passband range [begin end] (default: [0.1 48])
%   cfg.bpfilttype        = bandpass filter type, 'but' or 'fir' (default: fir')
%   cfg.bpinstabilityfix  = deal with filter instability, 'no' or 'split' (default: 'no')
%   cfg.dftfilter         = 'no' or 'yes'  line noise removal using discrete fourier transform (default = 'no')
%   cfg.dftfreq           = line noise frequencies in Hz for DFT filter (default = [50 100 150])
%   cfg.reref             = re-referencing: 'yes' or 'no' (default: 'yes')
%   cfg.refchannel        = re-reference channel (default: 'TP10')
%   cfg.samplingRate      = sampling rate in Hz (default: 500)
%
% Currently this function applies only a bandpass filter to the data.
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_IMPORTDATASET, FT_PREPROCESSING, RPS_DATASTRUCTURE

% Copyright (C) 2017, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
bpfreq            = ft_getopt(cfg, 'bpfreq', [0.1 48]);
bpfilttype        = ft_getopt(cfg, 'bpfilttype', 'fir');
bpinstabilityfix  = ft_getopt(cfg, 'bpinstabilityfix', 'no');
dftfilter         = ft_getopt(cfg, 'dftfilter', 'no');
dftfreq           = ft_getopt(cfg, 'dftfreq', [50 100 150]);
reref             = ft_getopt(cfg, 'reref', 'yes');
refchannel        = ft_getopt(cfg, 'refchannel', 'TP10');
samplingRate      = ft_getopt(cfg, 'samplingRate', 500);

if ~(samplingRate == 500 || samplingRate == 250 || samplingRate == 125)     
  error('Only the following sampling rates are permitted: 500, 250 or 125 Hz');
end  

% -------------------------------------------------------------------------
% Preprocessing settings
% -------------------------------------------------------------------------
% general filtering
cfgBP                   = [];
cfgBP.bpfilter          = 'yes';                                            % use bandpass filter
cfgBP.bpfreq            = bpfreq;                                           % bandpass range  
cfgBP.bpfilttype        = bpfilttype;                                       % bandpass filter type
cfgBP.bpinstabilityfix  = bpinstabilityfix;                                 % deal with filter instability
cfgBP.dftfilter         = dftfilter;                                        % dft filter for line noise removal
cfgBP.dftfreq           = dftfreq;                                          % line noise frequencies
cfgBP.channel           = 'all';                                            % use all channels
cfgBP.trials            = 'all';                                            % use all trials
cfgBP.feedback          = 'no';                                             % feedback should not be presented
cfgBP.showcallinfo      = 'no';                                             % prevent printing the time and memory after each function call

% re-referencing
cfgReref               = [];
cfgReref.reref         = reref;                                             % enable re-referencing
if ~iscell(refchannel)
  cfgReref.refchannel    = {refchannel, 'REF'};                             % specify new reference
else
  cfgReref.refchannel    = [refchannel, {'REF'}];
end
cfgReref.implicitref   = 'REF';                                             % add implicit channel 'REF' to the channels
cfgReref.refmethod     = 'avg';                                             % average over selected electrodes (in our case insignificant)
cfgReref.channel       = 'all';                                             % use all channels
cfgReref.trials        = 'all';                                             % use all trials
cfgReref.feedback      = 'no';                                              % feedback should not be presented
cfgReref.showcallinfo  = 'no';                                              % prevent printing the time and memory after each function call
cfgReref.calceogcomp   = 'yes';                                             % calculate eogh and eogv 

% downsampling
cfgDS                  = [];
cfgDS.resamplefs       = samplingRate;
cfgDS.feedback         = 'no';                                              % feedback should not be presented
cfgDS.showcallinfo     = 'no';                                              % prevent printing the time and memory after each function call

% -------------------------------------------------------------------------
% Preprocessing
% -------------------------------------------------------------------------
fprintf('<strong>Preproc participant 1...</strong>\n');
fprintf('Condition FreePlay...\n');
orgFs = data.FP.part1.fsample;
data.FP.part1   = bpfilter(cfgBP, data.FP.part1);
data.FP.part1   = rereference(cfgReref, data.FP.part1);
if orgFs ~= samplingRate
  data.FP.part1   = downsampling(cfgDS, data.FP.part1);
else
  data.FP.part1.fsample = orgFs;
end

fprintf('Condition PredDiff...\n');
orgFs = data.PD.part1.fsample;
data.PD.part1   = bpfilter(cfgBP, data.PD.part1);
data.PD.part1   = rereference(cfgReref, data.PD.part1);
if orgFs ~= samplingRate
  data.PD.part1   = downsampling(cfgDS, data.PD.part1);
else
  data.PD.part1.fsample = orgFs;
end

fprintf('Condition PredSame...\n');
orgFs = data.PS.part1.fsample;
data.PS.part1   = bpfilter(cfgBP, data.PS.part1);
data.PS.part1   = rereference(cfgReref, data.PS.part1);
if orgFs ~= samplingRate
  data.PS.part1   = downsampling(cfgDS, data.PS.part1);
else
  data.PS.part1.fsample = orgFs;
end

fprintf('Condition Control...\n');
orgFs = data.C.part1.fsample;
data.C.part1   = bpfilter(cfgBP, data.C.part1);
data.C.part1   = rereference(cfgReref, data.C.part1);
if orgFs ~= samplingRate
  data.C.part1   = downsampling(cfgDS, data.C.part1);
else
  data.C.part1.fsample = orgFs;
end

fprintf('<strong>Preproc participant 2...</strong>\n');
fprintf('Condition FreePlay...\n');
orgFs = data.FP.part2.fsample;
data.FP.part2   = bpfilter(cfgBP, data.FP.part2);
data.FP.part2   = rereference(cfgReref, data.FP.part2);
if orgFs ~= samplingRate
  data.FP.part2   = downsampling(cfgDS, data.FP.part2);
else
  data.FP.part2.fsample = orgFs;
end

fprintf('Condition PredDiff...\n');
orgFs = data.PD.part2.fsample;
data.PD.part2   = bpfilter(cfgBP, data.PD.part2);
data.PD.part2   = rereference(cfgReref, data.PD.part2);
if orgFs ~= samplingRate
  data.PD.part2   = downsampling(cfgDS, data.PD.part2);
else
  data.PD.part2.fsample = orgFs; 
end

fprintf('Condition PredSame...\n');
orgFs = data.PS.part2.fsample;
data.PS.part2   = bpfilter(cfgBP, data.PS.part2);
data.PS.part2   = rereference(cfgReref, data.PS.part2);
if orgFs ~= samplingRate
  data.PS.part2   = downsampling(cfgDS, data.PS.part2);
else
  data.PS.part2.fsample = orgFs; 
end

fprintf('Condition Control...\n');
orgFs = data.C.part2.fsample;
data.C.part2   = bpfilter(cfgBP, data.C.part2);
data.C.part2   = rereference(cfgReref, data.C.part2);
if orgFs ~= samplingRate
  data.C.part2   = downsampling(cfgDS, data.C.part2);
else
  data.C.part2.fsample = orgFs; 
end

end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------

function [ data_out ] = bpfilter( cfgB, data_in )
  
data_out = ft_preprocessing(cfgB, data_in);
  
end

function [ data_out ] = downsampling( cfgD, data_in )

ft_info off;
data_out = ft_resampledata(cfgD, data_in);
ft_info on;

end

function [ data_out ] = rereference( cfgR, data_in )

calcceogcomp = cfgR.calceogcomp;

if strcmp(calcceogcomp, 'yes')
  cfgtmp              = [];
  cfgtmp.channel      = {'H1', 'H2'};                                       % EOGH
  cfgtmp.reref        = 'yes';
  cfgtmp.refchannel   = 'H2';
  cfgtmp.showcallinfo = 'no';
  cfgtmp.feedback     = 'no';
  
  eogh                = ft_preprocessing(cfgtmp, data_in);
  eogh.label{1}       = 'EOGH';
  
  cfgtmp              = [];
  cfgtmp.channel      = 'EOGH';
  cfgtmp.showcallinfo = 'no';
  
  eogh                = ft_selectdata(cfgtmp, eogh); 
  
  cfgtmp              = [];
  cfgtmp.channel      = {'V1', 'V2'};                                       % EOGV
  cfgtmp.reref        = 'yes';
  cfgtmp.refchannel   = 'V2';
  cfgtmp.showcallinfo = 'no';
  cfgtmp.feedback     = 'no';
  
  eogv                = ft_preprocessing(cfgtmp, data_in);
  eogv.label{1}       = 'EOGV';
  
  cfgtmp              = [];
  cfgtmp.channel      = 'EOGV';
  cfgtmp.showcallinfo = 'no';
  
  eogv                = ft_selectdata(cfgtmp, eogv);
end

cfgR = removefields(cfgR, {'calcceogcomp'});
data_out = ft_preprocessing(cfgR, data_in);

if strcmp(calcceogcomp, 'yes')
  cfgtmp              = [];
  cfgtmp.showcallinfo = 'no';
  ft_info off;
  data_out            = ft_appenddata(cfgtmp, data_out, eogv, eogh);
  ft_info on;

end

end
