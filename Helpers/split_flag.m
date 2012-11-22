function [type year] = split_flag(flag)
%   [type year] = split_flag(flag)
%
%   Splits strings such as 'cr-2011' or 'real-2010' used to describe
%   channel type and population type, respectively. If an input such as
%   'cr' is provided (no year attached), the output year is set to 'none'.
%
%   Note that year is output as a string to allow for differentiation
%   between two datasets from the same year (e.g. 2011a and 2011b).
%
%   See also: combine_flag


split = regexpi(flag, '-', 'split');

type = split{1};

switch(length(split))
    case 1,
        year = 'none';
    case 2,
        year = split{2};
    otherwise,
        error(['Input string of unknown format: ' flag]);
end
        
end