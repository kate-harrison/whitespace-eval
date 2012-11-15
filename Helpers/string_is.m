function [result] = string_is(string1, string2)
%   [result] = string_is(string1, string2)
%
%   Checks for the equivalence of two strings. Returns 1 if equivalent
%   (aside from case), 0 otherwise.
%
%   Note: this is not a fancy function, just a wrapper for strcmpi because
%   this function name makes code more readable.

result = strcmpi(string1, string2);



end