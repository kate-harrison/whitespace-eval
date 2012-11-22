function [] = error_if_region_unsupported(varargin)
%   [] = error_if_region_unsupported(region1, region2, ...)
%
%   Produces an error if the current region code (obtained from
%   get_simulation_value.m) is not in the list of supported regions.
%
%   Examples:
%       error_if_region_unsupported('US', 'AUS')
%       error_if_region_unsupported('US')
%
%   See also: get_simulation_value

switch(get_simulation_value('region_code'))
    case varargin,
        % nothing, region is on the supported list
    otherwise,
        error(['Unsupported region: ' get_simulation_value('region_code')]);
end