function mask = circleMask(nx, ny, radiusFrac)
%CIRCLEMASK  Binary circular sampling mask.
%   mask = CIRCLEMASK(nx, ny) returns a logical mask of size [nx, ny]
%   with a filled circle centered in the image.
%
%   mask = CIRCLEMASK(nx, ny, radiusFrac) lets you specify the circle
%   radius as a fraction of the *smaller dimension* (default = 0.4).
%
%   Example:
%       C = circleMask(256, 320, 0.35);
%       imagesc(C); axis image off; colormap(gray); set(gca,'YDir','normal');

    if nargin < 3 || isempty(radiusFrac), radiusFrac = 0.4; end

    % Normalized grid: X,Y in [-0.5,0.5]
    [X, Y] = meshgrid(linspace(-0.5, 0.5, ny), linspace(-0.5, 0.5, nx));

    % Circle radius relative to smaller dimension
    r = radiusFrac * min(1, nx/ny);

    % Distance from center
    D = sqrt(X.^2 + (Y.*(nx/ny)).^2);  % scale Y to keep circle circular if nx≠ny

    mask = (D <= r);
    mask = logical(mask);
end
