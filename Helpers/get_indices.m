function [idx_x idx_y] = get_indices(xi, yi, lat_coords, long_coords, width)
%   [idx_x idx_y] = get_indices(xi, yi, lat_coords, long_coords, width)
%
%   Finds the coordinates that describe a square with side length 2*width+1
%   around the point (xi, yi) given the latitude and longitude coordinates
%   of the map.


% %   [xi, yi, lat_coords, long_coords]
% [xi, yi, lat_coords, long_coords] = varargin{1:4};
% if (length(varargin) < 5)
%     width = 11; % this is about 150 km in each direction (minimum)
% else
%     width = varargin{5};
% end


idx_x = [max(1, xi - width) : min(xi + width, length(lat_coords))];
idx_y = [max(1, yi - width) : min(yi + width, length(long_coords))];
end