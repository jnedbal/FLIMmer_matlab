function polarizerDropdown(handle, ~)
    global handles
    global setting
%     if strcmp(handle.Tag, 'off')
%         return
%     end

    in = find(handle == handles.dropdown.pol);
    % Check if question mark is selected
    if isequal(handles.dropdown.pol(in).String{...
                   handles.dropdown.pol(in).Value}, '?')
        return
    end
    % Disable the controls
    onOffPolHandles('off')
    % orientation of the polarizer
    orientation = {'parallel', 'perpendicular'};
    orientation = orientation{handles.dropdown.pol(in).Value};
    % Type of polarizer
    polType = {'em', 'exc'};
    polType = polType{in};
    % Work out the position into which the polarizer needs to move to
    % First, get the difference between the actual position and the desired
    % position
    polPos = setting.polarizer.(polType).(orientation) - ...
             setting.Polarizer.val(in);
	% Next figure out which is the next one, if any
    polIn = min(polPos(polPos >= 0));
    % If the result is zero, it means there is no need to move
    if polIn == 0
        onOffPolHandles('on')
        return
    end
    % If none, it is obviously the first one is correct
    if isempty(polIn)
        polIn = 1;
    else
        polIn = polPos == polIn;
    end
    % Set the slider to the target value
    handles.slider.pol(in).Value = ...
        setting.polarizer.(polType).(orientation)(polIn);
    % Call the slider update function
    polarizerSlider(handles.slider.pol(in), false)
end