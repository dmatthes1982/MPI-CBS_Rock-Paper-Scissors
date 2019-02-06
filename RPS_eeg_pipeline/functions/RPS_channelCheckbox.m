function [ badLabel ] = RPS_channelCheckbox( cfg )
% RPS_CHANNELCHECKBOX is a function, which displays a small GUI for the 
% selection of bad channels. It returns a cell array including the labels
% of the bad channels
%
% Use as
%   [ badLabel ]  = RPS_channelCheckbox( cfg )
%
% The configuration options are
%   cfg.maxchan   = The maximum number of channels, which can marked as bad. (default: 2)
%                   This value should not be greater than 10% of the total number of channels
%
% This function requires the fieldtrip toolbox.
%
% SEE also UIFIGURE, UICHECKBOX, UIBUTTON, UIRESUME, UIWAIT

% Copyright (C) 2018-2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Get and check config options
% -------------------------------------------------------------------------
maxchan  = ft_getopt(cfg, 'maxchan', 2);

% -------------------------------------------------------------------------
% Create GUI
% -------------------------------------------------------------------------
SelectBadChannels = uifigure;
SelectBadChannels.Position = [150 400 535 210];
SelectBadChannels.Name = 'Select bad channels';

warningLabel = uilabel(SelectBadChannels);
warningLabel.Position = [55 180 410 15];
warningLabel.FontColor = [1,0.5,0];
warningLabel.Text = '';

% Create F7CheckBox
Elec.F7 = uicheckbox(SelectBadChannels);
Elec.F7.Text = 'F7';
Elec.F7.Position = [45 150 80 15];
% Create FzCheckBox
Elec.Fz = uicheckbox(SelectBadChannels);
Elec.Fz.Text = 'Fz';
Elec.Fz.Position = [125 150 80 15];
% Create F8CheckBox
Elec.F8 = uicheckbox(SelectBadChannels);
Elec.F8.Text = 'F8';
Elec.F8.Position = [205 150 80 15];
% Create FC5CheckBox
Elec.FC5 = uicheckbox(SelectBadChannels);
Elec.FC5.Text = 'FC5';
Elec.FC5.Position = [285 150 80 15];
% Create FC1CheckBox
Elec.FC1 = uicheckbox(SelectBadChannels);
Elec.FC1.Text = 'FC1';
Elec.FC1.Position = [365 150 80 15];
% Create FC2CheckBox
Elec.FC2 = uicheckbox(SelectBadChannels);
Elec.FC2.Text = 'FC2';
Elec.FC2.Position = [445 150 80 15];

% Create FC6CheckBox
Elec.FC6 = uicheckbox(SelectBadChannels);
Elec.FC6.Text = 'FC6';
Elec.FC6.Position = [45 125 80 15];
% Create T7CheckBox
Elec.T7 = uicheckbox(SelectBadChannels);
Elec.T7.Text = 'T7';
Elec.T7.Position = [125 125 80 15];
% Create C3CheckBox
Elec.C3 = uicheckbox(SelectBadChannels);
Elec.C3.Text = 'C3';
Elec.C3.Position = [205 125 80 15];
% Create CzCheckBox
Elec.Cz = uicheckbox(SelectBadChannels);
Elec.Cz.Text = 'Cz';
Elec.Cz.Position = [285 125 80 15];
% Create C4CheckBox
Elec.C4 = uicheckbox(SelectBadChannels);
Elec.C4.Text = 'C4';
Elec.C4.Position = [365 125 80 15];
% Create T8CheckBox
Elec.T8 = uicheckbox(SelectBadChannels);
Elec.T8.Text = 'T8';
Elec.T8.Position = [445 125 80 15];

% Create FCzCheckBox
Elec.FCz = uicheckbox(SelectBadChannels);
Elec.FCz.Text = 'FCz';
Elec.FCz.Position = [45 100 80 15];
% Create CP1CheckBox
Elec.CP1 = uicheckbox(SelectBadChannels);
Elec.CP1.Text = 'CP1';
Elec.CP1.Position = [125 100 80 15];
% Create CP2CheckBox
Elec.CP2 = uicheckbox(SelectBadChannels);
Elec.CP2.Text = 'CP2';
Elec.CP2.Position = [205 100 80 15];
% Create TP10CheckBox
Elec.TP10 = uicheckbox(SelectBadChannels);
Elec.TP10.Text = 'TP10';
Elec.TP10.Position = [285 100 80 15];
% Create P7CheckBox
Elec.P7 = uicheckbox(SelectBadChannels);
Elec.P7.Text = 'P7';
Elec.P7.Position = [365 100 80 15];
% Create P3CheckBox
Elec.P3 = uicheckbox(SelectBadChannels);
Elec.P3.Text = 'P3';
Elec.P3.Position = [445 100 80 15];

% Create PzCheckBox
Elec.Pz = uicheckbox(SelectBadChannels);
Elec.Pz.Text = 'Pz';
Elec.Pz.Position = [45 75 80 15];
% Create P4CheckBox
Elec.P4 = uicheckbox(SelectBadChannels);
Elec.P4.Text = 'P4';
Elec.P4.Position = [125 75 80 15];
% Create P8CheckBox
Elec.P8 = uicheckbox(SelectBadChannels);
Elec.P8.Text = 'P8';
Elec.P8.Position = [205 75 80 15];
% Create O1CheckBox
Elec.O1 = uicheckbox(SelectBadChannels);
Elec.O1.Text = 'O1';
Elec.O1.Position = [285 75 80 15];
% Create OzCheckBox
Elec.Oz = uicheckbox(SelectBadChannels);
Elec.Oz.Text = 'Oz';
Elec.Oz.Position = [365 75 80 15];
% Create O2CheckBox
Elec.O2 = uicheckbox(SelectBadChannels);
Elec.O2.Text = 'O2';
Elec.O2.Position = [445 75 80 15];

% Create SaveButton
btn = uibutton(SelectBadChannels, 'push');
btn.ButtonPushedFcn = @(btn, evt)SaveButtonPushed(SelectBadChannels);
btn.Position = [217 27 101 21];
btn.Text = 'Save';

% Create ValueChangedFcn pointers
Elec.F7.ValueChangedFcn = @(F7, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.Fz.ValueChangedFcn = @(Fz, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.F8.ValueChangedFcn = @(F8, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.FC5.ValueChangedFcn = @(FC5, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.FC1.ValueChangedFcn = @(FC1, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.FC2.ValueChangedFcn = @(FC2, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.FC6.ValueChangedFcn = @(FC6, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.T7.ValueChangedFcn = @(T7, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.C3.ValueChangedFcn = @(C3, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.Cz.ValueChangedFcn = @(Cz, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.C4.ValueChangedFcn = @(C4, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.T8.ValueChangedFcn = @(T8, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.FCz.ValueChangedFcn = @(FCz, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.CP1.ValueChangedFcn = @(CP1, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.CP2.ValueChangedFcn = @(CP2, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.TP10.ValueChangedFcn = @(TP10, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.P7.ValueChangedFcn = @(P7, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.P3.ValueChangedFcn = @(P3, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.Pz.ValueChangedFcn = @(Pz, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.P4.ValueChangedFcn = @(P4, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.P8.ValueChangedFcn = @(P8, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.O1.ValueChangedFcn = @(O1, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.Oz.ValueChangedFcn = @(Oz, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);
Elec.O2.ValueChangedFcn = @(O2, evt)CheckboxValueChanged(Elec, warningLabel, btn, maxchan);

% -------------------------------------------------------------------------
% Wait for user input and return selection after btn 'save' was pressed
% -------------------------------------------------------------------------
% Wait until btn is pushed
uiwait(SelectBadChannels);

if ishandle(SelectBadChannels)                                              % if gui still exists
  badLabel = [Elec.F7.Value; Elec.Fz.Value; Elec.F8.Value; ...              % return existing selection
              Elec.FC5.Value; Elec.FC1.Value; Elec.FC2.Value; ...
              Elec.FC6.Value; Elec.T7.Value; Elec.C3.Value; ...
              Elec.Cz.Value; Elec.C4.Value; Elec.T8.Value; ...
              Elec.FCz.Value; Elec.CP1.Value; Elec.CP2.Value; ...
              Elec.TP10.Value; Elec.P7.Value; Elec.P3.Value; ...
              Elec.Pz.Value; Elec.P4.Value; Elec.P8.Value; ...
              Elec.O1.Value; Elec.Oz.Value; Elec.O2.Value];
  label    = {'F7', 'Fz', 'F8', 'FC5', 'FC1', 'FC2', 'FC6' 'T7', 'C3', ...
              'Cz', 'C4', 'T8', 'FCz', 'CP1', 'CP2', 'TP10', 'P7', 'P3',...
              'Pz', 'P4', 'P8', 'O1', 'Oz', 'O2'};
  badLabel = label(badLabel);
  if isempty(badLabel)
    badLabel = [];
  end
  delete(SelectBadChannels);                                                % close gui
else                                                                        % if gui was already closed (i.e. by using the close symbol)
  badLabel = [];                                                            % return empty selection
end

end

% -------------------------------------------------------------------------
% Event Functions
% -------------------------------------------------------------------------
% Button pushed function: btn
function  SaveButtonPushed(SelectBadChannels)
  uiresume(SelectBadChannels);                                              % resume from wait status                                                                             
end

% Checkbox value changed function
function  CheckboxValueChanged(Elec, warningLabel, btn, maxchan)
  badLabel = [Elec.F7.Value; Elec.Fz.Value; Elec.F8.Value; ...              % get status of all checkboxes
              Elec.FC5.Value; Elec.FC1.Value; Elec.FC2.Value; ...
              Elec.FC6.Value; Elec.T7.Value; Elec.C3.Value; ...
              Elec.Cz.Value; Elec.C4.Value; Elec.T8.Value; ...
              Elec.FCz.Value; Elec.CP1.Value; Elec.CP2.Value; ...
              Elec.TP10.Value; Elec.P7.Value; Elec.P3.Value; ...
              Elec.Pz.Value; Elec.P4.Value; Elec.P8.Value; ...
              Elec.O1.Value; Elec.Oz.Value; Elec.O2.Value];
  NumOfBad = sum(double(badLabel));
  if NumOfBad > maxchan
    warningLabel.Text = sprintf(['Too many channels selected! It''s '...
                  'only allowed to repair maximum %d channels.'], maxchan);
    btn.Enable = 'off';
  else
    warningLabel.Text = '';
    btn.Enable = 'on';
  end    
end
