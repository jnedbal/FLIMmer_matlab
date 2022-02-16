% Find the zero position of the polarizer
function polarizerButton(handle, ~)
    global handles    
%     if strcmp(handle.Tag, 'off')
%         return
%     end

    i = find(handle == handles.button.pol) - 1;
    % Disable the controls
    onOffPolHandles('off')
    % Set the zero position
    polSend([uint8('m'), i]);
end