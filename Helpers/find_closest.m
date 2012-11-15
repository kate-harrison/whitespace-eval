function [idx, val] = find_closest(val, array)
% FIND_CLOSEST Find the index and value of the element in array
% which is closest (absolute distance) to val.
%   [idx, val] = find_closest(val, array)

[Y, idx] = min(abs(array-val));
val = array(idx);


end