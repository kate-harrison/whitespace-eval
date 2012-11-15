function [low_idx, high_idx low_val high_val] = find_surrounding(val, array)
% [idx_x idx_y] = get_indices(xi, yi, lat_coords, long_coords, width)
%
% ** Assumes the values in array are ascending **
%
% FIND_SURROUNDING Find the indices and values of the element in array
% which is closest (absolute distance) to val.



low_idx = find(array < val, 1, 'last');
high_idx = find(val < array, 1, 'first');

if (isempty(low_idx))
    low_idx = 1;
end

if (isempty(high_idx))
    high_idx = length(array);
end

low_val = array(low_idx);
high_val = array(high_idx);





end