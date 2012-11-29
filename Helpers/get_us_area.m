function [map lat_coords long_coords] = get_us_area(map_size, varargin)
%   [map lat_coords long_coords] = get_us_area(map_size, *)
%
%   If the optional second argument is used (with any value), the map will
%   *not* be pre-masked to be zero outside the US.

% Determine the type
if ~isempty(varargin)
    type = 'full';
else
    type = 'masked';
end

% Load the data
region_areas_label = generate_label('region_areas', map_size, type);
[map lat_coords long_coords] = load_by_label(region_areas_label);

end