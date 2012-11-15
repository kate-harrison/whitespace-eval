function [max_val] = get_max_val(data)
%   [max_val] = get_max_val(data)
%
%   Finds the maximum non-infinite value in data(:).
%
%   Note: there's nothing fancy here, it's just a wrapper for:
%           max_val = max(data(isfinite(data)));



max_val = max(data(isfinite(data)));

end