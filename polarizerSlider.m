function polarizerSlider(handle, ~)
    global handles
    global setting

    % If this slider is deactivated, skip this call
    if strcmp(handle.Enable, 'off')
        return
    end
%     if strcmp(handle.Tag, 'off')
%         % Fill in with the original data
%         in = find(handle == handles.slider.pol);
%         handle.Value = setting.Polarizer.val(in);
%         return
%     end

    % Disable the controls
    onOffPolHandles('off')
    % Get the index of the slider pressed
    setting.Polarizer.callIn = find(handle == handles.slider.pol);
    % Get the target value
    slidVal = round(handle.Value);
    fprintf('%d\t%d\n', slidVal, setting.Polarizer.val(setting.Polarizer.callIn));
    % Calculate the differential between the desired and current positions
    steps = slidVal - setting.Polarizer.val(setting.Polarizer.callIn);
    % Convert the target value so it is always a forward motion
    steps = mod(steps + 800, 800);
    % If there is no change in steps, just quit
    if steps == 0
        % Enable the controls
        onOffPolHandles('on')
        return
    end
    handle.Tag = 'off';
    % Add the motor index to the value
    steps = steps + (2 ^ 15) * (setting.Polarizer.callIn - 1);
    setting.Polarizer.val(setting.Polarizer.callIn) = slidVal;
    handles.edit.pol(setting.Polarizer.callIn).String = num2str(slidVal);
    % Update the pulldown menu
    switch setting.Polarizer.callIn
        case 1
            if any(slidVal == setting.polarizer.em.parallel)
                handles.dropdown.pol(1).Value = 1;
            elseif any(slidVal == setting.polarizer.em.perpendicular)
                handles.dropdown.pol(1).Value = 2;
            else
                handles.dropdown.pol(1).Value = 3;
            end
        case 2
            if any(slidVal == setting.polarizer.exc.parallel)
                handles.dropdown.pol(2).Value = 1;
            elseif any(slidVal == setting.polarizer.exc.perpendicular)
                handles.dropdown.pol(2).Value = 2;
            else
                handles.dropdown.pol(2).Value = 3;
            end
    end
                
    % Hide the figure, while the motor is moving
    % Send the command to move the motor
    polSend([uint8('M'), bitand(steps, 255), bitshift(steps, -8)]);
end