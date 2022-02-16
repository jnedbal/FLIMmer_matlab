function onOffPolHandles(state)
    % Function to enable/disable the polarizer controls
    global handles

    handles.slider.pol(1).Visible = state;
    handles.slider.pol(2).Visible = state;
    handles.edit.pol(1).Visible = state;
    handles.edit.pol(2).Visible = state;
    handles.button.pol(1).Visible = state;
    handles.button.pol(2).Visible = state;
    handles.dropdown.pol(1).Visible = state;
    handles.dropdown.pol(2).Visible = state;
    handles.button.lasShut.Visible = state;
    handles.button.connectPol.Visible = state;
    drawnow
end