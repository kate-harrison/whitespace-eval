function [perc] = get_percentile_from_ccdf(cdfX, cdfY, percentile)
%   [perc] = get_percentile_from_ccdf(cdfX, cdfY, percentile)
%
%   Finds the percentile^th percentile using the data in cdfX, cdfY


perc_index = find(cdfY <= (percentile), 1, 'last');
perc = cdfX(perc_index);


end