function interactive3D(data)
% INTERACTIVE3D Interactive viewer for 3D (x,y,time) data
%   Scroll wheel, slider, or arrow keys to move through time

    % Ensure orientation matches expectation (x horizontal)
    data = permute(data, [2, 1, 3]);

    % Compute global intensity scaling
    dataMin = min(data(:));
    dataMax = max(data(:));

    % Create figure
    fig = figure('Name', '3D Time Viewer', 'NumberTitle', 'off', ...
                 'WindowScrollWheelFcn', @scrollCallback, ...
                 'WindowKeyPressFcn', @keyPressCallback);

    % Create axes filling almost entire figure
    ax = axes('Parent', fig, ...
              'Position', [0 0.05 1 0.95]); % leave space for slider
    ax.PositionConstraint = 'innerposition';

    % Frame number text (top-center overlay)
    frameText = uicontrol('Style', 'text', ...
                          'Parent', fig, ...
                          'Units', 'normalized', ...
                          'Position', [0.28 0.97 0.1 0.03], ...
                          'String', '', ...
                          'FontSize', 12, ...
                          'BackgroundColor', 'k', ...
                          'ForegroundColor', 'w', ...
                          'HorizontalAlignment', 'center');

    % Slider (bottom)
    scrollBar = uicontrol('Style', 'slider', ...
                          'Parent', fig, ...
                          'Units', 'normalized', ...
                          'Position', [0 0 1 0.04], ...
                          'Min', 1, 'Max', size(data, 3), ...
                          'Value', 1, ...
                          'SliderStep', [1/(size(data,3)-1) , 10/(size(data,3)-1)], ...
                          'Callback', @sliderCallback);

    % Store handles
    handles.data = data;
    handles.ax = ax;
    handles.imgHandle = []; % placeholder for imagesc handle
    handles.currentTime = 1;
    handles.maxTime = size(data, 3);
    handles.frameText = frameText;
    handles.scrollBar = scrollBar;
    handles.dataMin = dataMin;
    handles.dataMax = dataMax;
    guidata(fig, handles);

    % Initial plot
    plotFrame(fig);
end

function scrollCallback(src, event)
    handles = guidata(src);
    if event.VerticalScrollCount > 0
        handles.currentTime = min(handles.currentTime + 1, handles.maxTime);
    else
        handles.currentTime = max(handles.currentTime - 1, 1);
    end
    set(handles.scrollBar, 'Value', handles.currentTime);
    guidata(src, handles);
    plotFrame(src);
end

function sliderCallback(src, ~)
    fig = ancestor(src, 'figure');
    handles = guidata(fig);
    handles.currentTime = round(get(src, 'Value'));
    guidata(fig, handles);
    plotFrame(fig);
end

function keyPressCallback(src, event)
    handles = guidata(src);
    switch event.Key
        case {'rightarrow','uparrow'}
            handles.currentTime = min(handles.currentTime + 1, handles.maxTime);
        case {'leftarrow','downarrow'}
            handles.currentTime = max(handles.currentTime - 1, 1);
        otherwise
            return;
    end
    set(handles.scrollBar, 'Value', handles.currentTime);
    guidata(src, handles);
    plotFrame(src);
end

function plotFrame(fig)
    handles = guidata(fig);

    % Get 2D frame at current time
    img = handles.data(:, :, handles.currentTime);

    % Normalize consistently across time
    img = (img - handles.dataMin) / (handles.dataMax - handles.dataMin);

    if isempty(handles.imgHandle) || ~isvalid(handles.imgHandle)
        handles.imgHandle = imagesc(handles.ax, img);
        axis(handles.ax, 'image', 'off');
        colormap(handles.ax, gray);
    else
        set(handles.imgHandle, 'CData', img);
    end

    % Update frame text
    set(handles.frameText, 'String', ...
        sprintf('Frame %d / %d', handles.currentTime, handles.maxTime));

    guidata(fig, handles);
    drawnow;
end
