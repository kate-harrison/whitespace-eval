function [num_lat_div num_long_div] = get_map_dims_from_string(dims_string)
%   [num_lat_div num_long_div] = get_map_dims_from_string(dims_string)
%
%   From a map size string (e.g. '200x300'), return the map dimensions
%   (e.g. [200 300]).
%
%   See also: get_map_size_string.m

split = regexp(dims_string, 'x', 'split');
num_lat_div = str2double(split{1});
num_long_div = str2double(split{2});

end