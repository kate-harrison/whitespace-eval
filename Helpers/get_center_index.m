function [idx1 idx2] = get_center_index(array)
%   function [idx1 idx2] = get_center_index(array)
%
% Works for 1D or 2D arrays
%  * 1D only assigns idx1 (idx2 = 0)
%  * 2D assigns idx1, idx2 (row, column)
%
%  * If there is an odd number of indices, returns the center index.
%  * If there is an even number of indices, returns close to center (left or
% up from center in that dimension).


[m n] = size(array);

oneD = m == 1 | n == 1;

if (oneD)
    idx1 = ceil(length(array)/2);
    idx2 = 0;
else
    idx1 = ceil(size(array,1)/2);
    idx2 = ceil(size(array,2)/2);
end


end