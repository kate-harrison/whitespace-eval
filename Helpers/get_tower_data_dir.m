function [dir_name] = get_tower_data_dir(varargin)
%   [dir_name] = get_tower_data_dir([year])
%
%   Get the base directory for the raw tower assignment data. If no year is
%   specified, the default will be taken from get_simluation_value.m. Does
%   NOT include the trailing /.
%
%   Note: year should be specified as an string (e.g. '2011'). Valid values
%   can be found using get_simulation_value('valid_tower_data_years')
%
%   See also: get_simulation_value

if nargin == 0
    tower_year = get_simulation_value('tower_data_year');
else
    tower_year = varargin{1};
end

dir_name = [get_simulation_value('tower_data_dir') '/' tower_year];

end