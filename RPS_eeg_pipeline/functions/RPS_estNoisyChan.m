function [ data_out ] = RPS_estNoisyChan( data_in )
% RPS_ESTNOISYCHAN is a function which is detecting automatically noisy
% channels. Channels are marked as noisy/bad channels when its total power
% from 3Hz on is above 1.5 * IQR + Q3 or below Q1 - 1.5 * IQR.
%
% Use as
%   [ data_out ] = RPS_estNoisyChan( cfg, data_in )
%
% where input data has to be the result of RPS_CONCATDATA.
%
% Reference:
%   [Wass 2018] "Parental neural responsivity to infants visual attention: 
%                 how mature brains scaffold immature brains during social 
%                 interaction."
%
% This function requires the fieldtrip toolbox
%
% See also RPS_CONCATDATA

% Copyright (C) 2018, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Check data
% -------------------------------------------------------------------------
if numel(data_in.FP.part1.trialinfo) ~= 1 || numel(data_in.FP.part2.trialinfo) ~= 1
  error('Dataset has more than one trial. Data has to be concatenated!');
end

% -------------------------------------------------------------------------
% General settings
% -------------------------------------------------------------------------
participants  = [1,1,1,1,2,2,2,2];
condString    = {'FP','PD','PS','C','FP','PD','PS','C'};

for i = 1:1:8
  switch i                                                                  % extract data
    case 1
      data = data_in.FP.part1;
    case 2
      data = data_in.PD.part1;
    case 3
      data = data_in.PS.part1;
    case 4
      data = data_in.C.part1;
    case 5
      data = data_in.FP.part2;
    case 6
      data = data_in.PD.part2;
    case 7
      data = data_in.PS.part2;
    case 8
      data = data_in.C.part2;
  end
  
  fprintf('<strong>Estimating noisy channels of participant %d in condition %s...</strong>\n', ...
          participants(i), condString{i});
  % -----------------------------------------------------------------------
  % Re-referencing
  % -----------------------------------------------------------------------
  %cfg               = [];
  %cfg.reref         = 'yes';                                                % enable re-referencing
  %cfg.refchannel    = {'all', '-V1', '-V2', '-H1', '-H2', 'REF'};           % specify new reference
  %cfg.implicitref   = 'REF';                                                % add implicit channel 'REF' to the channels
  %cfg.refmethod     = 'avg';                                                % average over selected electrodes
  %cfg.channel       = {'all', '-V1', '-V2', '-H1', '-H2'};                  % use all channels
  %cfg.trials        = 'all';                                                % use all trials
  %cfg.feedback      = 'no';                                                 % feedback should not be presented
  %cfg.showcallinfo  = 'no';                                                 % prevent printing the time and memory after each function call

  %fprintf('Re-referencing to CAR...\n');
  %data = ft_preprocessing(cfg, data);

  % -----------------------------------------------------------------------
  % Estimate power spectrum
  % -----------------------------------------------------------------------
  cfg                 = [];
  cfg.method          = 'mtmfft';
  cfg.output          = 'pow';
  cfg.channel           = {'all', '-V1', '-V2', '-H1', '-H2', '-REF'};      % calculate spectrum for all channels, except V1, V2, H1 and H2
  cfg.trials          = 'all';                                              % calculate spectrum for every trial
  cfg.keeptrials      = 'yes';                                              % do not average over trials
  cfg.pad             = 'nextpow2';                                         % do not use padding
  cfg.taper           = 'hanning';                                          % hanning taper the segments
  cfg.foilim          = [0 250];                                            % frequency band of interest
  cfg.feedback        = 'no';                                               % suppress feedback output
  cfg.showcallinfo    = 'no';                                               % suppress function call output
  
  fprintf('Estimate power spectrum...\n');
  data = ft_freqanalysis( cfg, data);
  
  % -----------------------------------------------------------------------
  % Estimate total power of each channel
  % -----------------------------------------------------------------------
  fprintf('Add all power values from 3 Hz on together...\n');
  loc                 = find(data.freq < 3, 1, 'last');                     % Apply highpass at 3 Hz to suppress eye artifacts and baseline drifts
  data.totalpow       = sum(squeeze(data.powspctrm(:,:,loc:end)), 2);
  data.quartile       = prctile(data.totalpow, [25,50,75]);
  data.interquartile  = data.quartile(3) - data.quartile(1);
  data.outliers       = (data.totalpow > ( data.quartile(3) + ...
                          1.5 * data.interquartile)) | ...
                        (data.totalpow < ( data.quartile(1) - ...
                          1.5 * data.interquartile));  
  
  % -----------------------------------------------------------------------
  % Generate output
  % -----------------------------------------------------------------------
  data.freqrange  = {[3 max(data.freq)]};
  data.dimord     = 'chan_freqrange';
  data            = removefields(data, {'freq', 'cumsumcnt', 'cumtapcnt'...
                                        'trialinfo', 'cfg', 'powspctrm'});
  
  switch i                                                                  % reassign results 
    case 1
      data_out.FP.part1 = data;
    case 2
      data_out.PD.part1 = data;
    case 3
      data_out.PS.part1 = data;
    case 4
      data_out.C.part1 = data;
    case 5
      data_out.FP.part2 = data;
    case 6
      data_out.PD.part2 = data;
    case 7
      data_out.PS.part2 = data;
    case 8
      data_out.C.part2 = data;
  end
end

end
