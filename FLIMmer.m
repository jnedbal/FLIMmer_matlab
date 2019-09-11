function FLIMmer
close all
global handles      % Struct with various handles
global setting      % Struct holding settings

%% Check if the file setting exists
if exist('config.mat', 'file') == 2
    load('config.mat', 'setting')
else
    setting.Arduino.pot = 0;
end

%% Create a figure
setting.fig.unitH = 20;
setting.fig.unitW = 180;

handles.fig = figure('Units', 'Pixels', ...
                     'Toolbar', 'none', ...
                     'MenuBar', 'none', ...
                     'Resize', 'off', ...
                     'NumberTitle', 'off', ...
                     'Name', 'FLIMmer', ...
                     'CloseRequestFcn', @shutdown);
% Create a callback, which is called when the figure is moved, this is to
% remember the last figure location
drawnow
% Stop some Matlab warning
warning('off', 'MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');
% get JavaFrame. You might see some warnings.
jFig = get(handles.fig, 'JavaFrame'); 
jWindow = jFig.fHG2Client.getWindow;
jbh = handle(jWindow, 'CallbackProperties'); % Prevent memory leak
% Create the callback on the move of the figure
set(jbh, 'ComponentMovedCallback', {@figMove});
% Set the figure position
%% Check if the previous position was stored
if isfield(setting.fig, 'pos')
    % Check that the figure is not outside of the screen
    sPos = get(0, 'ScreenSize');
    if all(setting.fig.pos([1, 2]) + setting.fig.pos([3, 4]) <= ...
           sPos([3, 4]))
       % Set the figure position to whereever it was last time
       handles.fig.Position = setting.fig.pos;
    end
end

    
% Set the figure size to match its content
handles.fig.Position(3) = setting.fig.unitW;
handles.fig.Position(4) = 11 * setting.fig.unitH;

setting.fig.pos = handles.fig.Position;



%% Create a dropdown list of serial ports
pos = [1, ...
       setting.fig.pos(4) - setting.fig.unitH, ...
       setting.fig.unitW, ...
       setting.fig.unitH];
handles.dropdown.port = uicontrol('Style', 'popupmenu', ...
                                           'String', seriallist, ...
                                           'Position', pos, ...
                                           'Callback', @serialDropdown);
% Check if the port setting has been stored
if isfield(setting, 'port')
    % Check if any of the available serial ports have been already selected
    index = ~cellfun(@isempty, ...
                     regexp(handles.dropdown.port.String, setting.port));
    if any(index)
        handles.dropdown.port.Value = find(index);
    end
end

%% Create a pushbutton for serial connect
pos(2) = pos(2) - setting.fig.unitH;
handles.button.connect = uicontrol('Style', 'pushbutton', ...
                                            'String', 'Connect', ...
                                            'Position', pos, ...
                                            'HorizontalAlignment', 'center', ...
                                            'Callback', @connectButton, ...
                                            'BackgroundColor', [0.4 0 0], ...
                                            'ForegroundColor', [1 1 1]);

%% Create a pushbutton for the shutter button
pos(2) = pos(2) - setting.fig.unitH * 1.5;
handles.button.shutter = uicontrol('Style', 'pushbutton', ...
                                            'String', 'Shutter ???', ...
                                            'Position', pos .* [1 1 1 1.5], ...
                                            'HorizontalAlignment', 'center', ...
                                            'Callback', @shutterButton, ...
                                            'BackgroundColor', [0.4 0 0], ...
                                            'ForegroundColor', [1 1 1], ...
                                            'Tag', 'off');
% Set the fontsize to 150 % of the usual
handles.button.shutter.FontSize = 1.5 * handles.button.shutter.FontSize;

%% Create a box for HV power supply power
pos(2) = pos(2) - setting.fig.unitH;
handles.text.HV = uicontrol('Style', 'text', ...
                                     'String', 'HV Power ???', ...
                                     'Position', pos, ...
                                     'HorizontalAlignment', 'center', ...
                                     'BackgroundColor', [0.4 0 0], ...
                                     'ForegroundColor', [1 1 1]);

%% Create a slider for HV supply voltage
pos(2) = pos(2) - setting.fig.unitH;
handles.slider.HV = uicontrol('Style', 'slider', ...
                                       'Position', pos, ...
                                       'Min', 0, ...
                                       'Max', 255, ...
                                       'SliderStep', [1, 32] / 255, ...
                                       'Callback', @HVslider, ...
                                       'Enable', 'off', ...
                                       'Value', setting.Arduino.pot);


%% Create a text box for HV supply voltage
pos(2) = pos(2) - setting.fig.unitH;
handles.edit.HV = uicontrol('Style', 'edit', ...
                                     'Position', pos, ...
                                     'String', num2str(setting.Arduino.pot), ...
                                     'HorizontalAlignment', 'center', ...
                                     'Callback', @HVedit, ...
                                     'Enable', 'off');

%% Create a pushbutton to set the potentiometer
pos(2) = pos(2) - setting.fig.unitH;
handles.button.setPot = uicontrol('Style', 'pushbutton', ...
                                           'String', 'Set Voltage', ...
                                           'Position', pos, ...
                                           'HorizontalAlignment', 'center', ...
                                           'Callback', @setPotButton, ...
                                           'BackgroundColor', [0.4 0 0], ...
                                           'ForegroundColor', [1 1 1], ...
                                           'Tag', 'off');

%% Create a box for HV power supply power
pos(2) = pos(2) - setting.fig.unitH * 1.5;
handles.text.HVset = uicontrol('Style', 'text', ...
                                        'String', '???', ...
                                        'Position', pos .* [1 1 1 1.5], ...
                                        'HorizontalAlignment', 'center', ...
                                        'BackgroundColor', [0.4 0 0], ...
                                        'ForegroundColor', [1 1 1]);
% Set the fontsize to 200 % of the usual
handles.text.HVset.FontSize = 2 * handles.text.HVset.FontSize;

%% Create a pushbutton for the shutter button
pos(2) = pos(2) - setting.fig.unitH;
handles.button.progPot = uicontrol('Style', 'pushbutton', ...
                                            'String', 'Program Voltage', ...
                                            'Position', pos, ...
                                            'HorizontalAlignment', 'center', ...
                                            'Callback', @progPotButton, ...
                                            'BackgroundColor', [0.4 0 0], ...
                                            'ForegroundColor', [1 1 1], ...
                                            'Tag', 'off');


%% Create a box for Firmware Name
pos(2) = pos(2) - setting.fig.unitH;
handles.text.ID = uicontrol('Style', 'text', ...
                            'String', '', ...
                            'Position', pos);

end


function figMove(~, ~)
    global setting
    global handles

    % Store the figure position
    setting.fig.pos = handles.fig.Position;

    % Save the settings into a mat file
    save('config.mat', 'setting')
end

function shutterButton(~, ~)
    global handles

    % If this function is disabled, don't do anything
    if isequal(handles.button.shutter.Tag, 'off')
        return
    end
    % Toggle the shutter button    
    ardSend('T');
end

function HVslider(~, ~)
    global handles
    global setting

    % Update the HV edit box with the value on the slider
    handles.edit.HV.String = num2str(handles.slider.HV.Value);
    % Store the value of the digital pot value
    setting.Arduino.pot = handles.slider.HV.Value;
end

function HVedit(~, ~)
    global handles
    global setting

    % Check whether the value is not numeric
    % Check if a negative value has been provided
    % Check if a value higher than the maximum limit has been provided
    editVal = str2double(handles.edit.HV.String);
    if isnan(editVal) || ...
            editVal < handles.slider.HV.Min || ...
            editVal > handles.slider.HV.Max
        % Update the HV edit box with the value on the slider
        handles.edit.HV.String = num2str(handles.slider.HV.Value);
        return
    end
    % Check if the value is rounded, if not round it
    if editVal ~= round(editVal)
        % The value is not a whole number. Round it.
        editVal = round(editVal);
        % Set the edit value to the rounded value
        handles.edit.HV.String = num2str(editVal);
    end
    % Set the slider to the value of the edit box
    handles.slider.HV.Value = editVal;
    % Store the value of the digital pot value
    setting.Arduino.pot = handles.slider.HV.Value;
end

function setPotButton(~, ~)
    global setting
    global handles

    % If this function is disabled, don't do anything
    if isequal(handles.button.setPot.Tag, 'off')
        return
    end
    % Send the value to the Arduino
    ardSend([uint8('P'), setting.Arduino.pot]);
    % Display the value on the textbox
    handles.text.HVset.String = num2str(setting.Arduino.pot);

    % Save the setting for next load into a mat file
    save('config.mat', 'setting')
end

function progPotButton(~, ~)
    global setting
    global handles

    % If this function is disabled, don't do anything
    if isequal(handles.button.progPot.Tag, 'off')
        return
    end
    % First ask whether one really wants to overwrite the default voltage
    % setting
    answer = questdlg('Do you want to overwrite the default Voltage setting?', 'FLIMmer', 'No', 'Yes', 'No');
    if isempty(answer) || isequal(answer, 'No')
        return
    end
    % Send the value to the Arduino
    ardSend([uint8('P'), setting.Arduino.pot]);
    % Give the Arduino some time (100ms) to deal with the last transfer
    pause(0.1);
    % Send the value to the Arduino
    ardSend([uint8('N'), setting.Arduino.pot]);
    % Display the value on the textbox
    handles.text.HVset.String = num2str(setting.Arduino.pot);
    
    setting.Arduino.NVwiper = setting.Arduino.pot;

    % Save the setting for next load into a mat file
    save('config.mat', 'setting')
end

function serialDropdown(~, ~)
    global handles
    global setting

    setting.port = ...
        handles.dropdown.port.String{handles.dropdown.port.Value};
    % Save the settings into a mat file
    save('config.mat', 'setting')
end

function connectButton(~, ~)
    global setting
    global handles

    switch handles.button.connect.String
        case 'Connect'
            ardConnect
            % Change the button string
            handles.button.connect.String = 'Connected';
            handles.button.connect.BackgroundColor = [0 0.4 0];
        case 'Connected'
            % Close the serial port
            fclose(setting.serial);
            % Remove the callback function
            setting.serial.BytesAvailableFcn = '';
            % Change the button string
            handles.button.connect.String = 'Connect';
            handles.button.connect.BackgroundColor = [0.4 0 0];
            handles.text.HV.String = 'HV Power ???';
            handles.text.HV.BackgroundColor = [0.4 0 0];
            handles.slider.HV.Enable = 'off';
            handles.edit.HV.Enable = 'off';
            handles.button.shutter.String = 'Shutter ???';
            handles.button.shutter.Tag = 'off';
            handles.button.shutter.BackgroundColor = [0.4 0 0];
            handles.button.shutter.ForegroundColor = [1 1 1];
            handles.text.HVset.String = '???';
            handles.text.HVset.BackgroundColor = [0.4 0 0];
            handles.text.HVset.ForegroundColor = [1 1 1];
            handles.button.setPot.Tag = 'off';
            handles.button.progPot.Tag = 'off';
            handles.button.setPot.BackgroundColor = [0.4 0 0];
            handles.button.progPot.BackgroundColor = [0.4 0 0];
            handles.text.ID.String = '';
    end
end

function shutdown(~, ~)
    global setting
    global handles

    fclose(setting.serial);
    delete(handles.fig);
end


%%%%%%%%%%%%%%%%%%%%%%%%%
%   Serial Functions    %
%%%%%%%%%%%%%%%%%%%%%%%%%
function ardConnect
    global setting

    % Create serial port object
    setting.serial = serial(setting.port);
    % add a callback to bytes available. This is designed for the code to
    % listen to any messages from the Arduino
    setting.serial.BytesAvailableFcn = @ardCalling;
    setting.serial.BytesAvailableFcnMode = 'byte';
    setting.serial.BytesAvailableFcnCount = 2;
    % Open the serial port
    fopen(setting.serial);
    % Wait for the Arduino to wake up
    h = msgbox('Waiting for Arduino to respond', 'Arduino', 'modal');
    % Ensure the box appears
    drawnow
    % Wait two second to ensure the arduino is working
    pause(2);
	% Check if there is anything in the serial read buffer
    if setting.serial.BytesAvailable > 0
        % Dump the buffer
        fread(setting.serial, setting.serial.BytesAvailable);
    end
    % Close the message box
    delete(h);
    % query the Arduino for identity
    ardSend('I');
    % query the Arduino for identity
    ardSend('V');
    % check the HV power supply state
    ardSend('H');
    % check the shutter state
    ardSend('S');
    % check the NV wiper setting
    ardSend('E');
end

function ardSend(command)
    global setting

    cmd = [uint8(numel(command) + 1), uint8(command)];
    setting.waiting4data = true;
    % Send it to Arduino
    fwrite(setting.serial, cmd)
    % Wait for the Arduino to respond
    while setting.waiting4data; end
end

function ardCalling(~, ~)
    global setting
    global handles

    % Check if there is no data available, just exit
    if setting.serial.BytesAvailable == 0
        return
    end
    % Read the length of the response
    responseLength = fread(setting.serial, 1);
    % Wait for the Arduino to send the full string
    while setting.serial.BytesAvailable < responseLength; end
    % Read the string
    answer = fread(setting.serial, setting.serial.BytesAvailable)';
    % Decipher the answer
    switch char(answer(1))
        case 'I'
            setting.Arduino.ID = char(answer(2 : end));
        case 'V'
            setting.Arduino.version = char(answer(2 : end));
            handles.text.ID.String = sprintf('%s v%s', ...
                                             setting.Arduino.ID, ...
                                             setting.Arduino.version);
        case 'H'
            setting.Arduino.HVpowerOn = answer(2);
            switch setting.Arduino.HVpowerOn
                case 0
                    handles.text.HV.String = 'HV Power OFF';
                    handles.text.HV.BackgroundColor = [0.4 0 0];
                    handles.slider.HV.Enable = 'off';
                    handles.edit.HV.Enable = 'off';
                    handles.button.setPot.Tag = 'off';
                    handles.button.shutter.Tag = 'off';
                    handles.button.progPot.Tag = 'off';
                    handles.button.setPot.BackgroundColor = [0.4 0 0];
                    handles.button.progPot.BackgroundColor = [0.4 0 0];
                    handles.text.HVset.String = '???';
                case 1
                    handles.text.HV.String = 'HV Power ON';
                    handles.text.HV.BackgroundColor = [0 0.4 0];
                    handles.slider.HV.Enable = 'on';
                    handles.edit.HV.Enable = 'on';
                    handles.button.setPot.Tag = 'on';
                    handles.button.shutter.Tag = 'on';
                    handles.button.progPot.Tag = 'on';
                    handles.button.setPot.BackgroundColor = [0 0.4 0];
                    handles.button.progPot.BackgroundColor = [0 0.4 0];
                    handles.text.HVset.String = ...
                        num2str(setting.Arduino.NVwiper);
                    
            end
        case 'S'
            switch answer(2)
                case 1
                    setting.Arduino.shutter = 'CLOSED';
                    handles.button.shutter.BackgroundColor = [0 0 0];
                    handles.button.shutter.ForegroundColor = [1 1 1];
                    handles.button.shutter.String = 'Shutter CLOSED';
                case 0
                    setting.Arduino.shutter = 'OPEN';
                    handles.button.shutter.BackgroundColor = [1 1 1];
                    handles.button.shutter.ForegroundColor = [0 0 0];
                    handles.button.shutter.String = 'Shutter OPEN';
            end
        case 'E'
            setting.Arduino.NVwiper = answer(2);
            % Show the voltage, only if the HV power is on
            if setting.Arduino.HVpowerOn == 1
                handles.text.HVset.String = num2str(setting.Arduino.NVwiper);
                handles.text.HVset.BackgroundColor = [1 1 0];
                handles.text.HVset.ForegroundColor = [0 0 0];
            else
                handles.text.HVset.String = '???';
                handles.text.HVset.BackgroundColor = [0.4 0 0];
                handles.text.HVset.ForegroundColor = [1 1 1];
            end
        case 'P'
            assert(setting.Arduino.pot == answer(2), ...
                   'Arduino reported different pot value %d.', answer(2));
                
        otherwise
            disp('Arduino says:')
            disp(answer)
    end
    % Mark that data has been received
    setting.waiting4data = false;
end