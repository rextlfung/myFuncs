function make4DGif(data, filename, delayTime)
% MAKE4DGIF Create an animated GIF from 4D data with frame counter + FPS
%   make4DGif(data, filename, delayTime)
%
%   data      : 4D array (X × Y × Z × T)
%   filename  : output file name, e.g. 'output.gif'
%   delayTime : delay between frames in seconds (default 0.1)

    if nargin < 3
        delayTime = 0.1; % default
    end

    % make first dimension horizontal (same as interactive viewer)
    data = permute(data, [2, 1, 3, 4]);

    % Normalize globally across all frames
    dataMin = min(data(:));
    dataMax = max(data(:));

    nFrames = size(data, 4);

    for t = 1:nFrames
        % Extract one volume
        volumeData = data(:, :, :, t);
        numSlices = size(volumeData, 3);

        % Grid layout for gallery
        nCols = ceil(numSlices.^0.6);
        nRows = ceil(numSlices / nCols);

        % Normalize
        volumeData = (volumeData - dataMin) / (dataMax - dataMin);

        [sx, sy, ~] = size(volumeData);
        canvas = ones(nRows * sx, nCols * sy);

        % Fill the gallery
        for idx = 1:numSlices
            row = floor((idx-1) / nCols);
            col = mod((idx-1), nCols);
            xIdx = (row*sx + 1):(row*sx + sx);
            yIdx = (col*sy + 1):(col*sy + sy);
            canvas(xIdx, yIdx) = volumeData(:, :, idx);
        end

        % Convert to RGB for text overlay
        rgbImage = repmat(canvas, 1, 1, 3);  % grayscale -> RGB

        % Add frame counter + fps in bottom-right corner
        labelStr = sprintf('Frame %d / %d | %.2f s per frame', t, nFrames, delayTime);
        rgbImage = insertText(rgbImage, [size(rgbImage,2)-10, size(rgbImage,1)-10], ...
                              labelStr, 'FontSize', 18, 'BoxOpacity', 0, ...
                              'AnchorPoint','RightBottom', 'TextColor','black');

        % Convert back to indexed image for GIF
        [imind, cm] = rgb2ind(rgbImage, 256);

        if t == 1
            imwrite(imind, cm, filename, 'gif', 'Loopcount', inf, 'DelayTime', delayTime);
        else
            imwrite(imind, cm, filename, 'gif', 'WriteMode', 'append', 'DelayTime', delayTime);
        end
    end

    fprintf('GIF saved as %s\n', filename);
end
