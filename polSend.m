function polSend(command)
    global setting

    cmd = [uint8(numel(command) + 1), uint8(command)];
    setting.waiting4data = true;
    % Send it to Arduino
    fwrite(setting.serPol, cmd)
    % Wait for the Arduino to respond
    while setting.waiting4data; end
end