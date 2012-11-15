function [map lat_coords long_coords] = get_us_map(map_size, varargin)
%   [map lat_coords long_coords] = get_us_map(map_size, [num_layers])
%
%   Loads a matrix (defined by long_coords, lat_coords) which is 1 inside
%   of the US and 0 outside of the US.
%
%    o map_size - dimensions for the resulting map [ 200x300 | 201x301 |
%           400x600]
%    o num_layers (optional) - number of copies (third dimension)
%           [ {1} | integer]


if isempty(varargin)
    num_layers = 1;
else
    num_layers = varargin{1};
end

% Check to make sure that the map size is valid
validate_flags('', 'map_size', map_size);

file = load(['in_us' map_size '.mat']);
% Variables within (sample for map_size = 200x300)
% 	is_in_us	<200x300 double>
% 	lat_coords	<1x200 double>
% 	long_coords	<1x300 double>
% 	max_lat	50
% 	max_long	-66
% 	min_lat	24
% 	min_long	-126
% 	num_lat_div	200
% 	num_long_div	300

is_in_us = file.is_in_us;


map = shiftdim(repmat(is_in_us, [1 1 num_layers]),2);
map = logical(map);

lat_coords = file.lat_coords;
long_coords = file.long_coords;


end