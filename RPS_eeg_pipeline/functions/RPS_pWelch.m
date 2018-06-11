function [ data ] = RPS_pWelch( cfg, data )
% RPS_PWELCH calculates the power spectral density using Welch's method for
% every condition of every participant in the dataset.
%
% Use as
%   [ data ] = RPS_pWelch( cfg, data)
%
% where the input data hast to be the result from RPS_SEGMENTATION
%
% The configuration options are
%   cfg.foi = frequency of interest - begin:resolution:end (default: 1:1:50)
%
% This function requires the fieldtrip toolbox.
%
% See also RPS_SEGMENTATION

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
foi = ft_getopt(cfg, 'foi', 1:1:50);

% -------------------------------------------------------------------------
% psd settings
% -------------------------------------------------------------------------
cfg                 = [];
cfg.method          = 'mtmfft';
cfg.output          = 'pow';
cfg.channel         = 'all';                                                % calculate spectrum for all channels
cfg.trials          = 'all';                                                % calculate spectrum for every trial  
cfg.keeptrials      = 'yes';                                                % do not average over trials
cfg.pad             = 'maxperlen';                                          % do not use padding
cfg.taper           = 'hanning';                                            % hanning taper the segments
cfg.foi             = foi;                                                  % frequencies of interest
cfg.feedback        = 'no';                                                 % suppress feedback output
cfg.showcallinfo    = 'no';                                                 % suppress function call output

% -------------------------------------------------------------------------
% Calculate power spectral density using Welch's method
% -------------------------------------------------------------------------
fprintf('<strong>Calc power spectral density of participant 1...</strong>\n');
fprintf('Condition FreePlay...\n');
ft_warning off;
data.FP.part1 = ft_freqanalysis(cfg, data.FP.part1);
ft_warning on;
data.FP.part1 = pWelch(data.FP.part1, 1);
fprintf('Condition PredDiff...\n');
ft_warning off;
data.PD.part1 = ft_freqanalysis(cfg, data.PD.part1);
ft_warning on;
data.PD.part1 = pWelch(data.PD.part1, 2);
fprintf('Condition PredSame...\n');
ft_warning off;
data.PS.part1 = ft_freqanalysis(cfg, data.PS.part1);
ft_warning on;
data.PS.part1 = pWelch(data.PS.part1, 3);
fprintf('Condition Control...\n');
ft_warning off;
data.C.part1 = ft_freqanalysis(cfg, data.C.part1);
ft_warning on;
data.C.part1 = pWelch(data.C.part1, 4);

fprintf('<strong>Calc power spectral density of participant 2...</strong>\n');
fprintf('Condition FreePlay...\n');
ft_warning off;
data.FP.part2 = ft_freqanalysis(cfg, data.FP.part2); 
ft_warning on;
data.FP.part2 = pWelch(data.FP.part2, 1);
fprintf('Condition PredDiff...\n');
ft_warning off;
data.PD.part2 = ft_freqanalysis(cfg, data.PD.part2); 
ft_warning on;
data.PD.part2 = pWelch(data.PD.part2, 2);
fprintf('Condition PredSame...\n');
ft_warning off;
data.PS.part2 = ft_freqanalysis(cfg, data.PS.part2); 
ft_warning on;
data.PS.part2 = pWelch(data.PS.part2, 3);
fprintf('Condition Control...\n');
ft_warning off;
data.C.part2 = ft_freqanalysis(cfg, data.C.part2); 
ft_warning on;
data.C.part2 = pWelch(data.C.part2, 4);

end

% -------------------------------------------------------------------------
% Local functions
% -------------------------------------------------------------------------
function [ data_pWelch ] = pWelch(data_psd, condNum)
% -------------------------------------------------------------------------
% Load general definitions
% -------------------------------------------------------------------------
filepath = fileparts(mfilename('fullpath'));
load(sprintf('%s/../general/RPS_generalDefinitions.mat', filepath), ...
     'generalDefinitions');  

val       = ismember(generalDefinitions.phaseNum{condNum}, data_psd.trialinfo);
trialinfo = generalDefinitions.phaseNum{condNum}(val)';
powspctrm = zeros(length(trialinfo), length(data_psd.label), length(data_psd.freq));

for i = 1:1:length(trialinfo)
  val       = ismember(data_psd.trialinfo, trialinfo(i));
  tmpspctrm = data_psd.powspctrm(val,:,:);
  powspctrm(i,:,:) = median(tmpspctrm, 1);
end

data_pWelch.label = data_psd.label;
data_pWelch.dimord = data_psd.dimord;
data_pWelch.freq = data_psd.freq;
data_pWelch.powspctrm = powspctrm;
data_pWelch.trialinfo = trialinfo;
data_pWelch.cfg.previous = data_psd.cfg;
data_pWelch.cfg.pwelch_median = 'yes';
data_pWelch.cfg.pwelch_mean = 'no';

end