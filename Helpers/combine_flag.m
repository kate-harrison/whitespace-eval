function [flag] = combine_flag(type, year)
%   [flag] = combine_flag(type, year)
%
%   Performs the inverse of split_flag.m.
%
%   See also: split_flag

flag = [type '-' num2str(year)];

end