%% Play fMRI movie and k-space data side by side
% Input arguments:
% V: fMRI data (3D image time series)
% K: fMRI data (3D k-space time series)
% orientation: 'axial', 'coronal', or 'sagittal'
% delay: pause between each frame (in seconds)
%
% Last updated Feb 27, 2024
function playFMRI(V, K, orientation, delay)
    Nframes = size(V,4);

    % permute data to desired orientation
    if strcmp(orientation,'coronal')
        V_perm = permute(V, [1 3 2 4]);
        V_perm = flip(V_perm, 2);
        K_perm = permute(K, [1 3 2 4]);
        K_perm = flip(K_perm, 2);
    elseif strcmp(orientation,'sagittal')
        V_perm = permute(V, [2 3 1 4]);
        V_perm = flip(V_perm, 2);
        K_perm = permute(K, [2 3 1 4]);
        K_perm = flip(K_perm, 2);
    end

    % Get log-scaled magnitude of k-space
    K_perm_mag = log(abs(K_perm));

    % 
    figure('WindowState','maximized');
    for frame = 1:Nframes
        fig = tiledlayout('flow','TileSpacing','tight');
        nexttile; im(V_perm(:,:,:,frame))
        nexttile; im(K_perm_mag(:,:,:,frame))
        title(fig, sprintf('Frame %d', frame))
        pause(delay);
    end
end

%% Attic (or should I say basement)

% % Quick visualization
% close all; figure;
% for frame = 1:Nframes
%     tiledlayout('flow','TileSpacing','tight');
%     nexttile; im('mid3', V(:,:,:,frame))
%     nexttile; im('mid3', abs(K(:,:,:,frame)).^0.2)
%     pause(1/24); % 24 fps
% end