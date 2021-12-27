function [data_out] =RPS_robustRef(data_in, data_badchan)
% DEEP_ROBUSTREF does an average based re-referencing of eeg data using 
% only good channels for building the reference
%
% Use as
%   [data_out] =DEEP_robustRef(data_in, badchan)
%
% data_badchan is generated in part 2 of the pipeline during the first
% preprocessing step

% Copyright (C) 2021, Ira Marriott Haresign, University of East London,
% Daniel Matthes, HTWK Leipzig, Laboratory for Biosignal Processing

% get noisy chan numbers
noisy_chans_part1.FP = data_badchan.FP.part1.outliers==1;
noisy_chans_part1.PD = data_badchan.PD.part1.outliers==1;
noisy_chans_part1.PS = data_badchan.PS.part1.outliers==1;
noisy_chans_part1.C  = data_badchan.C.part1.outliers ==1;
 
noisy_chans_part2.FP = data_badchan.FP.part2.outliers==1;
noisy_chans_part2.PD = data_badchan.PD.part2.outliers==1;
noisy_chans_part2.PS = data_badchan.PS.part2.outliers==1;
noisy_chans_part2.C  = data_badchan.C.part2.outliers ==1;


% -------------------------------------------------------------------------
% Re-Referencing of Participant 1 data
% -------------------------------------------------------------------------

for i=1:1:length(data_in.FP.part1.trial)
    FP.part1_input = data_in.FP.part1.trial{i};
    % exclude EOGV and EOGH from rereferencing
    FP.part1_reduced = FP.part1_input(1:end-2,:);                                     % Note: number of channels is not fixed, but EOGH and EOGV are always at the end

    % remove noisy chans from data
    tmp.FP.part1 = FP.part1_reduced;
    tmp.FP.part1(noisy_chans_part1.FP,:)=[];
    
    % get robust average reference
    FP.part1_robustRef = mean(tmp.FP.part1,1);
    
    % rereference continuous data to robustRef
    FP.part1_referenced = FP.part1_reduced - FP.part1_robustRef;

    % add back previously removed EOGV and EOGH channels 
    eog_chans.FP.part1 = FP.part1_input(end-1:end, :);
    
    % replace trial with rereferenced one
    data_in.FP.part1.trial{i} = cat(1, FP.part1_referenced, eog_chans.FP.part1);
end


for i=1:1:length(data_in.PD.part1.trial)
    PD.part1_input = data_in.PD.part1.trial{i};
    % exclude EOGV and EOGH from rereferencing
    PD.part1_reduced = PD.part1_input(1:end-2,:);                                     % Note: number of channels is not fixed, but EOGH and EOGV are always at the end

    % remove noisy chans from data
    tmp.PD.part1 = PD.part1_reduced;
    tmp.PD.part1(noisy_chans_part1.PD,:)=[];
    
    % get robust average reference
    PD.part1_robustRef = mean(tmp.PD.part1,1);
    
    % rereference continuous data to robustRef
    PD.part1_referenced = PD.part1_reduced - PD.part1_robustRef;

    % add back previously removed EOGV and EOGH channels 
    eog_chans.PD.part1 = PD.part1_input(end-1:end, :);
    
    % replace trial with rereferenced one
    data_in.PD.part1.trial{i} = cat(1, PD.part1_referenced, eog_chans.PD.part1);
end


for i=1:1:length(data_in.PS.part1.trial)
    PS.part1_input = data_in.PS.part1.trial{i};
    % exclude EOGV and EOGH from rereferencing
    PS.part1_reduced = PS.part1_input(1:end-2,:);                                     % Note: number of channels is not fixed, but EOGH and EOGV are always at the end

    % remove noisy chans from data
    tmp.PS.part1 = PS.part1_reduced;
    tmp.PS.part1(noisy_chans_part1.PS,:)=[];
    
    % get robust average reference
    PS.part1_robustRef = mean(tmp.PS.part1,1);
    
    % rereference continuous data to robustRef
    PS.part1_referenced = PS.part1_reduced - PS.part1_robustRef;

    % add back previously removed EOGV and EOGH channels 
    eog_chans.PS.part1 = PS.part1_input(end-1:end, :);
    
    % replace trial with rereferenced one
    data_in.PS.part1.trial{i} = cat(1, PS.part1_referenced, eog_chans.PS.part1);
end


for i=1:1:length(data_in.C.part1.trial)
    C.part1_input = data_in.C.part1.trial{i};
    % exclude EOGV and EOGH from rereferencing
    C.part1_reduced = C.part1_input(1:end-2,:);                                     % Note: number of channels is not fixed, but EOGH and EOGV are always at the end

    % remove noisy chans from data
    tmp.C.part1 = C.part1_reduced;
    tmp.C.part1(noisy_chans_part1.C,:)=[];
    
    % get robust average reference
    C.part1_robustRef = mean(tmp.C.part1,1);
    
    % rereference continuous data to robustRef
    C.part1_referenced = C.part1_reduced - C.part1_robustRef;

    % add back previously removed EOGV and EOGH channels 
    eog_chans.C.part1 = C.part1_input(end-1:end, :);
    
    % replace trial with rereferenced one
    data_in.C.part1.trial{i} = cat(1, C.part1_referenced, eog_chans.C.part1);
end

% -------------------------------------------------------------------------
% Re-Referencing of Participant 2 data
% -------------------------------------------------------------------------

for i=1:1:length(data_in.FP.part2.trial)
    FP.part2_input = data_in.FP.part2.trial{i};
    % exclude EOGV and EOGH from rereferencing
    FP.part2_reduced = FP.part2_input(1:end-2,:);                                     % Note: number of channels is not fixed, but EOGH and EOGV are always at the end

    % remove noisy chans from data
    tmp.FP.part2 = FP.part2_reduced;
    tmp.FP.part2(noisy_chans_part2.FP,:)=[];
    
    % get robust average reference
    FP.part2_robustRef = mean(tmp.FP.part2,1);
    
    % rereference continuous data to robustRef
    FP.part2_referenced = FP.part2_reduced - FP.part2_robustRef;

    % add back previously removed EOGV and EOGH channels 
    eog_chans.FP.part2 = FP.part2_input(end-1:end, :);
    
    % replace trial with rereferenced one
    data_in.FP.part2.trial{i} = cat(1, FP.part2_referenced, eog_chans.FP.part2);
end


for i=1:1:length(data_in.PD.part2.trial)
    PD.part2_input = data_in.PD.part2.trial{i};
    % exclude EOGV and EOGH from rereferencing
    PD.part2_reduced = PD.part2_input(1:end-2,:);                                     % Note: number of channels is not fixed, but EOGH and EOGV are always at the end

    % remove noisy chans from data
    tmp.PD.part2 = PD.part2_reduced;
    tmp.PD.part2(noisy_chans_part2.PD,:)=[];
    
    % get robust average reference
    PD.part2_robustRef = mean(tmp.PD.part2,1);
    
    % rereference continuous data to robustRef
    PD.part2_referenced = PD.part2_reduced - PD.part2_robustRef;

    % add back previously removed EOGV and EOGH channels 
    eog_chans.PD.part2 = PD.part2_input(end-1:end, :);
    
    % replace trial with rereferenced one
    data_in.PD.part2.trial{i} = cat(1, PD.part2_referenced, eog_chans.PD.part2);
end


for i=1:1:length(data_in.PS.part2.trial)
    PS.part2_input = data_in.PS.part2.trial{i};
    % exclude EOGV and EOGH from rereferencing
    PS.part2_reduced = PS.part2_input(1:end-2,:);                                     % Note: number of channels is not fixed, but EOGH and EOGV are always at the end

    % remove noisy chans from data
    tmp.PS.part2 = PS.part2_reduced;
    tmp.PS.part2(noisy_chans_part2.PS,:)=[];
    
    % get robust average reference
    PS.part2_robustRef = mean(tmp.PS.part2,1);
    
    % rereference continuous data to robustRef
    PS.part2_referenced = PS.part2_reduced - PS.part2_robustRef;

    % add back previously removed EOGV and EOGH channels 
    eog_chans.PS.part2 = PS.part2_input(end-1:end, :);
    
    % replace trial with rereferenced one
    data_in.PS.part2.trial{i} = cat(1, PS.part2_referenced, eog_chans.PS.part2);
end


for i=1:1:length(data_in.C.part2.trial)
    C.part2_input = data_in.C.part2.trial{i};
    % exclude EOGV and EOGH from rereferencing
    C.part2_reduced = C.part2_input(1:end-2,:);                                     % Note: number of channels is not fixed, but EOGH and EOGV are always at the end

    % remove noisy chans from data
    tmp.C.part2 = C.part2_reduced;
    tmp.C.part2(noisy_chans_part2.C,:)=[];
    
    % get robust average reference
    C.part2_robustRef = mean(tmp.C.part2,1);
    
    % rereference continuous data to robustRef
    C.part2_referenced = C.part2_reduced - C.part2_robustRef;

    % add back previously removed EOGV and EOGH channels 
    eog_chans.C.part2 = C.part2_input(end-1:end, :);
    
    % replace trial with rereferenced one
    data_in.C.part2.trial{i} = cat(1, C.part2_referenced, eog_chans.C.part2);
end

data_out = data_in;
