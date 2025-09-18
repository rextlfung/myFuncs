function mask = blockMmask(nx, ny, strokeFrac)
%BLOCKMMASK  Binary Michigan-style block "M" sampling mask.
%   mask = BLOCKMMASK(nx, ny) returns a logical mask of size [nx, ny].
%   mask = BLOCKMMASK(nx, ny, strokeFrac) lets you set stroke thickness
%   as a fraction of the width (default 0.18). Valid range ~[0.05, 0.45].
%
%   The "M" is constructed as the union of four strokes of uniform
%   thickness: left/right verticals and two diagonals meeting at the
%   bottom-center. Geometry is defined in normalized [0,1]x[0,1] space
%   so the shape keeps its proportions for any nx,ny.
%
%   Example:
%       M = blockMmask(256, 320, 0.20);
%       imagesc(M); axis image off; colormap(gray); set(gca,'YDir','normal');
%
%   Tip: For k-space sampling, use ~M to sample the complement if desired.

    if nargin < 3 || isempty(strokeFrac), strokeFrac = 0.18; end
    % Clamp to sane range
    t = max(0.05, min(0.45, strokeFrac));  % stroke thickness as fraction of width
    r = t/2;                               % radius used in distance test

    % Normalized grid: X left->right in [0,1], Y top->bottom in [0,1]
    [X, Y] = meshgrid(linspace(0,1,ny), linspace(0,1,nx));

    % Centerlines of the four strokes (in normalized coords)
    % Vertical stems (centered at x = t/2 and x = 1-t/2), spanning full height
    Dleft  = dist_to_segment(X, Y, t/2,   0, t/2,   1);
    Dright = dist_to_segment(X, Y, 1-t/2, 0, 1-t/2, 1);

    % Diagonals from inner top corners down to bottom center
    DdiagL = dist_to_segment(X, Y, t,     0, 0.5,   1);
    DdiagR = dist_to_segment(X, Y, 1 - t, 0, 0.5,   1);

    % Uniform-thickness "M" = union of tubes around those segments
    mask = (Dleft <= r) | (Dright <= r) | (DdiagL <= r) | (DdiagR <= r);
    mask = logical(mask);
end

% --- helper (local function) ---
function D = dist_to_segment(X, Y, ax, ay, bx, by)
%DIST_TO_SEGMENT  Per-pixel Euclidean distance to a line segment AB.
    dx = bx - ax; dy = by - ay;
    denom = dx.^2 + dy.^2;
    % Protect against degenerate segments (shouldn't happen here)
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
