function [result] = string_contains(string, substr)
%   [result] = string_contains(string, substr)
%
%   Checks for the presence of substr in string. Returns 1 if present, 0
%   otherwise.


result = ~isempty(regexpi(string, substr));


end