function [map lat_coords long_coords] = get_us_map(map_size, varargin)
%   [map lat_coords long_coords] = get_us_map(map_size, [num_layers])
%
%   Loads a matrix (defined by long_coords, lat_coords) which is 1 inside
%   of the US and 0 outside of the US.
%
%    o map_size - dimensions for the resulting map [ 200x300 | 201x301 |
%           400x600] (taken from get_simulation_value.m)
%    o num_layers (optional) - number of copies (third dimension)
%           [ {1} | integer]
%
%   See also: get_simulation_value

% Determine the number of layers
if isempty(varargin)
    num_layers = 1;
else
    num_layers = varargin{1};
end

% Check to make sure that the map size is valid
validate_flags('', 'map_size', map_size);

% Load the data
region_mask_label = generate_label('region_mask', map_size);
[region_mask lat_coords long_coords] = load_by_label(region_mask_label);

% Create the copies and convert the matrix to logical values
map = shiftdim(repmat(region_mask, [1 1 num_layers]),2);
map = logical(map);

end