function [ masked_cap ] = apply_exclusions_to_capacity( capacity, exclusion_mask )
%APPLY_EXCLUSIONS Applies exclusions to capacity data maps.
%
%   [ masked_cap ] = apply_exclusions_to_capacity( capacity, exclusion_mask)
%
%   capacity - Original capacity matrix (single channel or all)
%   exclusion_mask - Array whose dimensions match that of the capacity
%   array. A value of '1' indicates that transmission is allowed at that
%   point and a value of '0' indicates that transmission is not allowed at
%   that point.
%
%   Returns the capacity matrix where the capacity is taken to be zero for
%   those values where transmission is not allowed.


%noise(exclusion_mask == 0) = inf;

masked_cap = capacity .* exclusion_mask;

end

