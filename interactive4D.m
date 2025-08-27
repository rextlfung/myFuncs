function interactive4D(data)
% INTERACTIVE4D Interactive 4D viewer with fullscreen gallery
%   Images fill the window, slider + text overlay at edges

    % make first dimension horizontal
    data = permute(data, [2, 1, 3, 4]);

    % Compute global intensity scaling
    dataMin = min(data(:));
    dataMax = max(data(:));

    % Create figure
    fig = figure('Name', '4D Volume Gallery', 'NumberTitle', 'off', ...
                 'WindowScrollWheelFcn', @scrollCallback, ...
                 'WindowKeyPressFcn', @keyPressCallback);

    % Create axes filling almost entire figure
    ax = axes('Parent', fig, ...
              'Position', [0 0 1 1]); % fill window
    ax.PositionConstraint = 'innerposition';

    xlabel(ax, 'x');
    ylabel(ax, 'y');

    % Create frame number text (top-center overlay)
    frameText = uicontrol('Style', 'text', ...
                          'Parent', fig, ...
                          'Units', 'normalized', ...
                          'Position', [0.4 0.96 0.2 0.04], ...
                          'String', '', ...
                          'FontSize', 12, ...
                          'BackgroundColor', fig.Color, ...
                          'ForegroundColor', 'k', ...
                          'HorizontalAlignment', 'center');

    % Create scrollbar (thin bar at bottom)
    scrollBar = uicontrol('Style', 'slider', ...
                          'Parent', fig, ...
                          'Units', 'normalized', ...
                          'Position', [0 0 1 0.04], ...
                          'Min', 1, 'Max', size(data, 4), ...
                          'Value', 1, ...
                          'SliderStep', [1/(size(data,4)-1) , 10/(size(data,4)-1)], ...
                          'Callback', @sliderCallback);

    % Store handles
    handles.data = data;
    handles.ax = ax;
    handles.imgHandle = []; % placeholder for imagesc handle
    handles.currentTime = 1;
    handles.maxTime = size(data, 4);
    handles.frameText = frameText;
    handles.scrollBar = scrollBar;
    handles.dataMin = dataMin;
    handles.dataMax = dataMax;
    guidata(fig, handles);

    % Initial plot
    plotGallery(fig);
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
    plotGallery(src);
end

function sliderCallback(src, ~)
    fig = ancestor(src, 'figure');
    handles = guidata(fig);
    handles.currentTime = round(get(src, 'Value'));
    guidata(fig, handles);
    plotGallery(fig);
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
    plotGallery(src);
end

function plotGallery(fig)
    handles = guidata(fig);

    if ~isvalid(handles.ax)
        return;
    end

    volumeData = handles.data(:, :, :, handles.currentTime);
    numSlices = size(volumeData, 3);

    nCols = ceil(numSlices.^0.6);
    nRows = ceil(numSlices / nCols);

    % Normalize consistently across time
    volumeData = (volumeData - handles.dataMin) / (handles.dataMax - handles.dataMin);

    [sx, sy, ~] = size(volumeData);
    canvas = ones(nRows * sx, nCols * sy);

    for idx = 1:numSlices
        row = floor((idx-1) / nCols);
        col = mod((idx-1), nCols);
        xIdx = (row*sx + 1):(row*sx + sx);
        yIdx = (col*sy + 1):(col*sy + sy);
        canvas(xIdx, yIdx) = volumeData(:, :, idx);
    end

    if isempty(handles.imgHandle) || ~isvalid(handles.imgHandle)
        handles.imgHandle = imagesc(handles.ax, canvas);
        axis(handles.ax, 'image', 'off');
        colormap(handles.ax, gray);
    else
        set(handles.imgHandle, 'CData', canvas);
    end

    % Update frame number text
    if isfield(handles, 'frameText') && isvalid(handles.frameText)
        set(handles.frameText, 'String', sprintf('Frame %d / %d', handles.currentTime, handles.maxTime));
    end

    guidata(fig, handles);
    drawnow;
end
