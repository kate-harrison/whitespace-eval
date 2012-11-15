function [map lat_coords long_coords] = get_us_area(map_size, varargin)
%   [map lat_coords long_coords] = get_us_area(map_size, *)
%
%   If the optional second argument is used (with any value), the map will
%   *not* be pre-masked to be zero outside the US.

if (~isempty(varargin))
    extra = '_full_';
else
    extra = '';
end

% Check to make sure that the map size is valid
validate_flags('', 'map_size', map_size);

file = load(['us_area' extra map_size '.mat']);
% Variables within (e.g. for the 201x301 case)
% 	lat_coords	<1x201 double>
% 	long_coords	<1x301 double>
% 	max_lat	50
% 	max_long	-66
% 	min_lat	24
% 	min_long	-126
% 	num_lat_div	200
% 	num_long_div	300
% 	us_area	<201x301 double>

map = file.us_area;
lat_coords = file.lat_coords;
long_coords = file.long_coords;

end