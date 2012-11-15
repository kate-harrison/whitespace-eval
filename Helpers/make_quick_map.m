function [] = make_quick_map(data, varargin)
%   [] = make_quick_map(data, [colorbar_label])
%
%   This function provides a no-hassle way to make a map figure by calling
%   make_map() with common settings.
%
%   data - Data to plot.
%   colorbar_label (optional) - Label for the colorbar.
%
%
%
%   This function calls make_map() and uses the following settings:
%       save = off
%       state_outlines = on
%       colorbar_title = [set according to input]
%
%   For other settings, see also: make_map

switch(ndims(data))
    case 1, error('Cannot make a one-dimensional map');
%     case 2, ;   % already fine
    case 3, data = squeeze(sum(data));
end

if (nargin < 2)
    colorbar_label = '';
else
    colorbar_label = varargin{1};
end

map_size = determine_map_size(size(data));

is_in_us = get_us_map(map_size, 1);
data(~is_in_us) = inf;

make_map(data, 'save', 'off', 'colorbar_title', colorbar_label, ...
    'state_outlines', 'on');

end