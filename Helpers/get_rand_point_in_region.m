function [idx1 idx2] = get_rand_point_in_region(region_mask)
%   [idx1 idx2] = get_rand_point_in_region(region_mask)
%
%   Returns the indices (idx1, idx2) of a random point (uniform
%   distribution) for which region_mask(idx1,idx2) evaluates to true.

in = 0;
while ~in
    idx1 = randi(size(region_mask,1));
    idx2 = randi(size(region_mask,2));
    in = region_mask(idx1, idx2);
end

end