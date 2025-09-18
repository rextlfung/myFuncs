function mask = blockUmask(nx, ny, strokeFrac)
%BLOCKUMASK  Binary Michigan-style block "U" sampling mask.
%   mask = BLOCKUMASK(nx, ny) returns a logical mask of size [nx, ny].
%   mask = BLOCKUMASK(nx, ny, strokeFrac) lets you set stroke thickness
%   as a fraction of the width (default 0.18).
%
%   The "U" is built as the union of three uniform-thickness strokes:
%   left/right verticals + bottom horizontal.
%
%   Example:
%       U = blockUmask(256, 320, 0.20);
%       imagesc(U); axis image off; colormap(gray); set(gca,'YDir','normal');

    if nargin < 3 || isempty(strokeFrac), strokeFrac = 0.18; end
    t = max(0.05, min(0.45, strokeFrac));  % stroke thickness as fraction of width
    r = t/2;

    % Normalized grid
    [X, Y] = meshgrid(linspace(0,1,ny), linspace(0,1,nx));

    % Vertical stems (centered at x = t/2 and 1-t/2), spanning full height
    Dleft  = dist_to_segment(X, Y, t/2,   0, t/2,   1);
    Dright = dist_to_segment(X, Y, 1-t/2, 0, 1-t/2, 1);

    % Bottom horizontal (from left inner corner to right inner corner)
    Dbottom = dist_to_segment(X, Y, t, 1 - t/2, 1 - t, 1 - t/2);

    % Combine strokes
    mask = (Dleft <= r) | (Dright <= r) | (Dbottom <= r);
    mask = logical(mask);
end

% --- helper ---
function D = dist_to_segment(X, Y, ax, ay, bx, by)
    dx = bx - ax; dy = by - ay;
    denom = dx.^2 + dy.^2;
    if denom == 0
        D = hypot(X - ax, Y - ay);
        return;
    end
    t = ((X - ax).*dx + (Y - ay).*dy) ./ denom;
    t = max(0, min(1, t));
    cx = ax + t.*dx;
    cy = ay + t.*dy;
    D = hypot(X - cx, Y - cy);
end
