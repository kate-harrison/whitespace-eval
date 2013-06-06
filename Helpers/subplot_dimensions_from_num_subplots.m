function [dim1 dim2] = subplot_dimensions_from_num_subplots(num_subplots)
%   [dim1 dim2] = subplot_dimensions_from_num_subplots(num_subplots)
%
%   This function finds the [dim1 dim2] such that dim1*dim2 > num_subplots
%   and dim1 is close in magnitude to dim2. This is useful for
%   automatically generating the dimensions for an array of subplots given
%   the total number of subplots.
%
%   See also: subplot


if isprime(num_subplots)
    dim1 = ceil(sqrt(num_subplots));
    if dim1*(dim1-1) >= num_subplots
        dim2 = dim1-1;
    else
        dim2 = dim1;
    end
else
    factors = factor(num_subplots);
    dim1 = prod(factors(1:2:end));
    dim2 = prod(factors(2:2:end));
end

end