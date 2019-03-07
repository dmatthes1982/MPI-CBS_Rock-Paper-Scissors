function [passband] = RPS_pbSelectbox()
% RPS_PBSELECTBOX is a function, which displays a small GUI for the
% specification of passbands. It returns a cell array including the minimum
% and maximum frequency of each passband.
%
% Use as
%   [ passband ]  = RPS_pbSelectbox( cfg )
%
% This function requires the fieldtrip toolbox.
%
% SEE also UIFIGURE, UIEDITFIELD, UIBUTTON, UIRESUME, UIWAIT

% Copyright (C) 2019, Daniel Matthes, MPI CBS

% -------------------------------------------------------------------------
% Create GUI
% -------------------------------------------------------------------------
pbSelectbox = uifigure;
pbSelectbox.Position = [150 400 360 190];
pbSelectbox.CloseRequestFcn = @(pbSelectbox, evt)SaveButtonPushed(pbSelectbox);
pbSelectbox.Name = 'Specifiy passbands';

% Create fmin label
fminlbl = uilabel(pbSelectbox);
fminlbl.Position = [154 150 52 15];
fminlbl.Text = 'fmin';
% Create fmax label
fmaxlbl = uilabel(pbSelectbox);
fmaxlbl.Position = [263 150 54 15];
fmaxlbl.Text = 'fmax';

% Create alpha label
alpha.lbl = uilabel(pbSelectbox);
alpha.lbl.Position = [45 125 80 15];
alpha.lbl.Text = 'alpha';
% Create alpha fmin editfield
alpha.fmin = uieditfield(pbSelectbox, 'numeric');
alpha.fmin.Position = [125 125 80 15];
alpha.fmin.Value = 8;
alpha.fmin.Limits = [8 11.8];
% Create alpha fmax editfield
alpha.fmax = uieditfield(pbSelectbox, 'numeric');
alpha.fmax.Position = [235 125 80 15];
alpha.fmax.Value = 12;
alpha.fmax.Limits = [8.2 13];

% Create beta label
beta.lbl = uilabel(pbSelectbox);
beta.lbl.Position = [45 100 80 15];
beta.lbl.Text = 'beta';
% Create beta fmin editfield
beta.fmin = uieditfield(pbSelectbox, 'numeric');
beta.fmin.Position = [125 100 80 15];
beta.fmin.Value = 13;
beta.fmin.Limits = [13 29.8];
% Create beta fmax editfield
beta.fmax = uieditfield(pbSelectbox, 'numeric');
beta.fmax.Position = [235 100 80 15];
beta.fmax.Value = 30;
beta.fmax.Limits = [13.2 30];

% Create gamma label
gamma.lbl = uilabel(pbSelectbox);
gamma.lbl.Position = [45 75 80 15];
gamma.lbl.Text = 'gamma';
% Create beta fmin editfield
gamma.fmin = uieditfield(pbSelectbox, 'numeric');
gamma.fmin.Position = [125 75 80 15];
gamma.fmin.Value = 31;
gamma.fmin.Limits = [30 47.8];
% Create beta fmax editfield
gamma.fmax = uieditfield(pbSelectbox, 'numeric');
gamma.fmax.Position = [235 75 80 15];
gamma.fmax.Value = 48;
gamma.fmax.Limits = [31.2 250];

% Create SaveButton
btn = uibutton(pbSelectbox, 'push');
btn.ButtonPushedFcn = @(btn, evt)SaveButtonPushed(pbSelectbox);
btn.Position = [130 27 100 21];
btn.Text = 'Save';

% Create ValueChangedFcn pointers
alpha.fmin.ValueChangedFcn    = @(fmin, evt)EditFieldValueChanged(alpha);
alpha.fmax.ValueChangedFcn    = @(fmax, evt)EditFieldValueChanged(alpha);
beta.fmin.ValueChangedFcn     = @(fmin, evt)EditFieldValueChanged(beta);
beta.fmax.ValueChangedFcn     = @(fmax, evt)EditFieldValueChanged(beta);
gamma.fmin.ValueChangedFcn    = @(fmin, evt)EditFieldValueChanged(gamma);
gamma.fmax.ValueChangedFcn    = @(fmax, evt)EditFieldValueChanged(gamma);

% -------------------------------------------------------------------------
% Wait for user input and return selection after btn 'save' was pressed
% -------------------------------------------------------------------------
% Wait until btn is pushed
uiwait(pbSelectbox);

if ishandle(pbSelectbox)                                                    % if gui still exists
  passband = {[alpha.fmin.Value     alpha.fmax.Value], ...                  % return existing selection
              [beta.fmin.Value      beta.fmax.Value], ...
              [gamma.fmin.Value     gamma.fmax.Value], ...
              };
  delete(pbSelectbox);
else                                                                        % otherwise return default settings
  passband = {[8    12], ...
              [13   30], ...
              [31   48], ...
              };
end

end

% -------------------------------------------------------------------------
% Event Functions
% -------------------------------------------------------------------------
% Button pushed function: btn
function  SaveButtonPushed(pbSelectbox)
  uiresume(pbSelectbox);                                                    % resume from wait status                                                                             
end

% edit field value changed function
function EditFieldValueChanged(passband)
  passband.fmin.Limits(2) = passband.fmax.Value - 0.2;                      % assure a minimum bandwidth of 0.2 Hz
  passband.fmax.Limits(1) = passband.fmin.Value + 0.2;
end
