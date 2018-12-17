function [ data ] = RPS_preprocessing( cfg, data )
% RPS_PREPROCESSING does the basic bandpass filtering of the raw data
% and is calculating the EOG signals.
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
%   cfg.part1BadChan      = bad channels of participant 1 which should be excluded (default: [])
%   cgf.part2BadChan      = bad channels of participant 2 which should be excluded (default: [])
%
% Currently this function applies only a bandpass filter to the data.
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_IMPORTDATASET, RPS_SELECTBADCHAN, FT_PREPROCESSING

% Copyright (C) 2017-2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
bpfreq            = ft_getopt(cfg, 'bpfreq', [0.1 48]);
bpfilttype        = ft_getopt(cfg, 'bpfilttype', 'fir');
bpinstabilityfix  = ft_getopt(cfg, 'bpinstabilityfix', 'no');
dftfilter         = ft_getopt(cfg, 'dftfilter', 'no');
dftfreq           = ft_getopt(cfg, 'dftfreq', [50 100 150]);
part1BadChan      = ft_getopt(cfg, 'part1BadChan', []);
part2BadChan      = ft_getopt(cfg, 'part2BadChan', []);

% -------------------------------------------------------------------------
% Channel configuration
% -------------------------------------------------------------------------
if ~isempty(part1BadChan.FP)
  part1BadChan.FP = cellfun(@(x) sprintf('-%s', x), part1BadChan.FP, ...
                            'UniformOutput', false);
end
if ~isempty(part1BadChan.PD)
  part1BadChan.PD = cellfun(@(x) sprintf('-%s', x), part1BadChan.PD, ...
                            'UniformOutput', false);
end
if ~isempty(part1BadChan.PS)
  part1BadChan.PS = cellfun(@(x) sprintf('-%s', x), part1BadChan.PS, ...
                            'UniformOutput', false);
end
if ~isempty(part1BadChan.C)
  part1BadChan.C  = cellfun(@(x) sprintf('-%s', x), part1BadChan.C, ...
                            'UniformOutput', false);
end
if ~isempty(part2BadChan.FP)
  part2BadChan.FP = cellfun(@(x) sprintf('-%s', x), part2BadChan.FP, ...
                            'UniformOutput', false);
end
if ~isempty(part2BadChan.PD)
  part2BadChan.PD = cellfun(@(x) sprintf('-%s', x), part2BadChan.PD, ...
                            'UniformOutput', false);
end
if ~isempty(part2BadChan.PS)
  part2BadChan.PS = cellfun(@(x) sprintf('-%s', x), part2BadChan.PS, ...
                            'UniformOutput', false);
end
if ~isempty(part2BadChan.C)
  part2BadChan.C  = cellfun(@(x) sprintf('-%s', x), part2BadChan.C, ...
                            'UniformOutput', false);
end

part1Chan.FP  = [{'all'} part1BadChan.FP'];                                 % do bandpassfiltering only with good channels and remove the bad once
part1Chan.PD  = [{'all'} part1BadChan.PD'];
part1Chan.PS  = [{'all'} part1BadChan.PS'];
part1Chan.C   = [{'all'} part1BadChan.C'];
part2Chan.FP  = [{'all'} part2BadChan.FP'];
part2Chan.PD  = [{'all'} part2BadChan.PD'];
part2Chan.PS  = [{'all'} part2BadChan.PS'];
part2Chan.C   = [{'all'} part2BadChan.C'];

% -------------------------------------------------------------------------
% Basic bandpass settings
% -------------------------------------------------------------------------
cfg                   = [];
cfg.bpfilter          = 'yes';                                              % use bandpass filter
cfg.bpfreq            = bpfreq;                                             % bandpass range
cfg.bpfilttype        = bpfilttype;                                         % bandpass filter type
cfg.bpinstabilityfix  = bpinstabilityfix;                                   % deal with filter instability
cfg.dftfilter         = dftfilter;                                          % dft filter for line noise removal
cfg.dftfreq           = dftfreq;                                            % line noise frequencies
cfg.channel           = 'all';                                              % use all channels
cfg.trials            = 'all';                                              % use all trials
cfg.feedback          = 'no';                                               % feedback should not be presented
cfg.showcallinfo      = 'no';                                               % prevent printing the time and memory after each function call

fprintf('<strong>Filter participant 1 (basic bandpass)...</strong>\n');
fprintf('Condition FreePlay...\n');
cfg.channel   = part1Chan.FP;
data.FP.part1 = ft_preprocessing(cfg, data.FP.part1);

fprintf('Condition PredDiff...\n');
cfg.channel   = part1Chan.PD;
data.PD.part1 = ft_preprocessing(cfg, data.PD.part1);

fprintf('Condition PredSame...\n');
cfg.channel   = part1Chan.PS;
data.PS.part1 = ft_preprocessing(cfg, data.PS.part1);

fprintf('Condition Control...\n');
cfg.channel   = part1Chan.C;
data.C.part1  = ft_preprocessing(cfg, data.C.part1);

fprintf('<strong>Filter participant 2 (basic bandpass)...</strong>\n');
fprintf('Condition FreePlay...\n');
cfg.channel   = part2Chan.FP;
data.FP.part2 = ft_preprocessing(cfg, data.FP.part2);

fprintf('Condition PredDiff...\n');
cfg.channel   = part2Chan.PD;
data.PD.part2 = ft_preprocessing(cfg, data.PD.part2);

fprintf('Condition PredSame...\n');
cfg.channel   = part2Chan.PS;
data.PS.part2 = ft_preprocessing(cfg, data.PS.part2);

fprintf('Condition Control...\n');
cfg.channel   = part2Chan.C;
data.C.part2  = ft_preprocessing(cfg, data.C.part2);

fprintf('<strong>Estimate EOG signals for participant 1...</strong>\n');
fprintf('Condition FreePlay...\n');
data.FP.part1 = estimEOG(data.FP.part1);

fprintf('Condition PredDiff...\n');
data.PD.part1 = estimEOG(data.PD.part1);

fprintf('Condition PredSame...\n');
data.PS.part1 = estimEOG(data.PS.part1);

fprintf('Condition Control...\n');
data.C.part1  = estimEOG(data.C.part1);

fprintf('<strong>Estimate EOG signals for participant 2...</strong>\n');
fprintf('Condition FreePlay...\n');
data.FP.part2 = estimEOG(data.FP.part2);

fprintf('Condition PredDiff...\n');
data.PD.part2 = estimEOG(data.PD.part2);

fprintf('Condition PredSame...\n');
data.PS.part2 = estimEOG(data.PS.part2);

fprintf('Condition Control...\n');
data.C.part2  = estimEOG(data.C.part2);

end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------
function [ data_out ] = estimEOG( data_in )

cfg              = [];
cfg.channel      = {'H1', 'H2'};                                            % EOGH
cfg.reref        = 'yes';
cfg.refchannel   = 'H2';
cfg.showcallinfo = 'no';
cfg.feedback     = 'no';

eogh             = ft_preprocessing(cfg, data_in);
eogh.label{1}    = 'EOGH';

cfg              = [];
cfg.channel      = 'EOGH';
cfg.showcallinfo = 'no';

eogh             = ft_selectdata(cfg, eogh);

cfg              = [];
cfg.channel      = {'V1', 'V2'};                                            % EOGV
cfg.reref        = 'yes';
cfg.refchannel   = 'V2';
cfg.showcallinfo = 'no';
cfg.feedback     = 'no';

eogv             = ft_preprocessing(cfg, data_in);
eogv.label{1}    = 'EOGV';

cfg              = [];
cfg.channel      = 'EOGV';
cfg.showcallinfo = 'no';

eogv             = ft_selectdata(cfg, eogv);

cfg              = [];
cfg.showcallinfo = 'no';
ft_info off;
data_out         = ft_appenddata(cfg, data_in, eogv, eogh);
data_out.fsample = data_in.fsample;
ft_info on;

end
