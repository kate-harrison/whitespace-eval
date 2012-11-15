function [] = make_crosshair(x, y, varargin)
%   [] = make_crosshair(x, y, [color], [linewidth])
%
%   Plots vertical and horizontal lines on the current figure which
%   intersect at (x,y) with (optinal) color 'color' and (optional)
%   linewidth 'linewidth'.
%
%   Defaults:
%       color = 'k'
%       linewidth = 2
%
%   Caution: If you've set the axis using something like
%                       axis([-inf inf 0 1])
%       the line for that axis (in the example, the x axis) will not show
%       up. This happens because the line lengths are set using the axis
%       values (this ensures they stretch across the whole figure). Lines
%       whose endpoints are at infinity do not show up in Matlab.

if (nargin >= 3)
    color = varargin{1};
else
    color = 'k';
end

if (nargin >= 4)
    lw = varargin{2};
else
    lw = 2;
end

ax = axis;

h = line([x x], ax(3:4), 'color', color, 'linewidth', lw);
uistack(h, 'bottom');
h = line(ax(1:2), [y y], 'color', color, 'linewidth', lw);
uistack(h, 'bottom');



end