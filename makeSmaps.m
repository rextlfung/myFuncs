%% makeSmaps.m
%
% Wrapper function to estimate sensitivity maps using either:
% 1. PISCO
% 2. BART
%
% Input arguments:
% ksp = 3D k-space data. Typically acquired using GRE. 3D tensor.
% method = 'pisco' or 'bart'. String.
% 
% Output arguments:
% 
%
% Last modified Jan 30th, 2025. Rex Fung

function [smaps, emaps] = makeSmaps(ksp, method)
    % Read in dimensions
    [Nx, Ny, Nz, Nc] = size(ksp);

    if strcmp(method, 'bart')
        [smaps, emaps] = bart('ecalib', ksp);
        smaps = squeeze(smaps(:,:,:,:,1));
    elseif strcmp(method, 'pisco')
        %% Selection of calibration data

        cal_length = 32; % Length of each dimension of the calibration data
        
        center_x = ceil(Nx/2)+even_pisco(Nx);
        center_y = ceil(Ny/2)+even_pisco(Ny);
        center_z = ceil(Nz/2)+even_pisco(Nz);
        
        cal_index_x = center_x + [-floor(cal_length/2):floor(cal_length/2)-even_pisco(cal_length/2)];
        cal_index_y = center_y + [-floor(cal_length/2):floor(cal_length/2)-even_pisco(cal_length/2)];
        cal_index_z = center_z + [-floor(cal_length/2):floor(cal_length/2)-even_pisco(cal_length/2)];
        
        kCal = ksp(cal_index_x, cal_index_y, cal_index_z, :);
        
        %% Nullspace-based algorithm parameters
        
        dim_sens = [Nx,Ny,Nz];                  % Desired dimensions for the estimated sensitivity maps.
        
        tau      = 3;                         % Kernel radius. Default: 3
        
        threshold = 0.08;                     % Threshold for C-matrix singular values. Default: 0.05
                                              % Note: In this example we don't use the default value.
        
        M = 20;                               % Number of iterations for Power Iteration. Default: 30
                                              % Note: In this example we use a smaller value
                                              % to speed up the calculations.
        
        PowerIteration_flag_convergence = 1;  % Binary variable. 1 = convergence error is displayed 
                                              % for Power Iteration if the method has not converged 
                                              % for some voxels after the iterations indicated by 
                                              % the user. Default: 1
        
        PowerIteration_flag_auto = 1;         % Binary variable. 1 = Power Iteration is run until
                                              % convergence in case the number of iterations
                                              % indicated by the user is too small. Default: 0
        
        interp_zp = 24;                       % Amount of zero-padding to create the low-resolution grid 
                                              % if FFT-interpolation is used. Default: 24
        
        gauss_win_param = 100;                % Parameter for the Gaussian apodizing window used to 
                                              % generate the low-resolution image in the FFT-based 
                                              % interpolation approach. This is the reciprocal of the 
                                              % standard deviation of the Gaussian window. Default: 100
        
        sketch_dim = 300;                     % Dimension of the sketch matrix used to calculate a
                                              % basis for the nullspace of the C matrix using a sketched SVD. 
                                              % Default: 500. Note: In this example we use a smaller value
                                              % to speed up the calculations.
        
        visualize_C_matrix_sv = 1;            % Binary variable. 1 = Singular values of the C matrix are displayed.
                                              % Default: 0. 
                                              % Note: In this example we set it to 1 to visualize the singular values
                                              % of the C matrix. If sketched_SVD = 1 and if the curve of the singular values flattens out,
                                              % it suggests that the sketch dimension is appropriate for the data.
                                              
        %% PISCO techniques
        
        % The following techniques are used if the corresponding binary variable is equal to 1
        
        kernel_shape = 1;                     % Binary variable. 1 = ellipsoidal shape is adopted for 
                                              % the calculation of kernels (instead of rectangular shape).
                                              % Default: 1
        
        FFT_nullspace_C_calculation = 1;      % Binary variable. 1 = FFT-based calculation of nullspace 
                                              % vectors of C by calculating C'*C directly (instead of 
                                              % calculating C first). Default: 1
        
        sketched_SVD = 1;                     % Binary variable. 1 = sketched SVD is used to calculate 
                                              % a basis for the nullspace of the C matrix (instead of 
                                              % calculating the nullspace vectors directly and then the 
                                              % basis). Default: 1
        
        PowerIteration_G_nullspace_vectors = 1; % Binary variable. 1 = Power Iteration approach is 
                                                % used to find nullspace vectors of the G matrices 
                                                % (instead of using SVD). Default: 1
        
        FFT_interpolation = 1;                % Binary variable. 1 = sensitivity maps are calculated on 
                                              % a small spatial grid and then interpolated to a grid with 
                                              % nominal dimensions using an FFT-approach. Default: 1
        
        verbose = 1;                          % Binary variable. 1 = PISCO information is displayed. 
                                              % Default: 1

        if isempty(which('PISCO_sensitivity_map_estimation'))
            error(['The function PISCO_senseMaps_estimation.m is not found in your MATLAB path. ' ...
                   'Please ensure that all required files are available and added to the path.']);
        end
        
        [smaps, emaps] = PISCO_sensitivity_map_estimation( ...
            kCal, ...
            dim_sens, ...                          % Data and output size
            'tau', tau, ...
            'threshold', threshold, ...
            'kernel_shape', kernel_shape, ...            % Kernel and threshold parameters
            'FFT_nullspace_C_calculation', FFT_nullspace_C_calculation, ...             % FFT nullspace calculation flag
            'PowerIteration_G_nullspace_vectors', PowerIteration_G_nullspace_vectors, ...      % Power Iteration flag
            'M', M, ...
            'PowerIteration_flag_convergence', PowerIteration_flag_convergence, ...      % Power Iteration params
            'PowerIteration_flag_auto', PowerIteration_flag_auto, ...                % Power Iteration auto flag
            'FFT_interpolation', FFT_interpolation, ...
            'interp_zp', interp_zp, ...
            'gauss_win_param', gauss_win_param, ... % Interpolation params
            'sketched_SVD', sketched_SVD, ...
            'sketch_dim', sketch_dim, ...
            'visualize_C_matrix_sv', visualize_C_matrix_sv, ... % SVD/sketching params
            'verbose', verbose ...                                  % Verbosity
        );
    end
end

%% Auxiliary functions

function result = even_pisco(int)
% Function that checks if an integer is even.
%
% Input parameters:
%   --int:    Integer value to be checked.
%
% Output parameters:
%   --result: Logical value. Returns 1 (true) if int is even, 0 (false) otherwise.
%
    result = not(rem(int,2));
end

function tempForDisplay = mdisp(x)
% Function used to visualize multichannel images.
% If the input corresponds to a 3D array of dimensions Nx x Ny x Nc, the
% output corresponds to a 2D array that displays Nc images of dimension
% Nx x Ny.
%
% Input parameters:
%   --x:              3D array of size Nx x Ny x Nc, where Nc is the number
%                     of channels.
%
% Output parameters:
%   --tempForDisplay: 2D array that arranges the Nc images of size Nx x Ny
%                     into a single displayable image.
%

    [Nx,Ny,Nc] = size(x);
    f = factor(Nc);if numel(f)==1;f = [1,f];end
    tempForDisplay = reshape(permute(reshape(x,[Nx,Ny,prod(f(1:floor(numel(f)/2))),...
        prod(f(floor(numel(f)/2)+1:end))]),[1,3,2,4]),[Nx*prod(f(1:floor(numel(f)/2))),...
        Ny*prod(f(floor(numel(f)/2)+1:end))]); 
end