function [variance] = calculate_variance_from_cdf(cdfX, cdfY)
%   [variance] = calculate_variance_from_cdf(cdfX, cdfY)
%
%   This function calculates the variance given CDF data (e.g. that
%   produced by the function 'calculate_cdf_from_map'). It is in fact a
%   very thin wrapper around the built-in Matlab function 'var' which can
%   already calculate weighted variance. The purpose of this wrapper is to
%   make it clear and simple to calculate the variance after a call to
%   'calculate_cdf_from_map'.
%
%   This function does the following:
%       variance = var(cdfX, cdfY);
%
%   See also: calculate_cdf_from_map, var

variance = var(cdfX, cdfY);

end