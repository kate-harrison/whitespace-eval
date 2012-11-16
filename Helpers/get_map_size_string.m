function [map_size] = get_map_size_string(map_dims)
%   [map_size] = get_map_size_string(map_dims)
%
%   From the dimensions of a map (matrix), determine its unique string
%   (e.g. '200x300').
%
%   See also: get_map_dims_from_string.m

switch(length(map_dims))
    case {0, 1}, error(['Not enough dimensions to be a map: ' num2str(length(map_dims))]);
    case 2, map_size = [num2str(map_dims(1)) 'x' num2str(map_dims(2))];
    case 3, map_size = [num2str(map_dims(2)) 'x' num2str(map_dims(3))];
    otherwise, error(['Too many dimensions to be a map: ' num2str(length(map_dims))]);
end

end