function [map_size] = determine_map_size(map_dims)

switch(length(map_dims))
    case {0, 1}, error(['Not enough dimensions to be a map: ' num2str(length(map_dims))]);
    case 2, map_size = [num2str(map_dims(1)) 'x' num2str(map_dims(2))];
    case 3, map_size = [num2str(map_dims(2)) 'x' num2str(map_dims(3))];
    otherwise, error(['Too many dimensions to be a map: ' num2str(length(map_dims))]);
end

end