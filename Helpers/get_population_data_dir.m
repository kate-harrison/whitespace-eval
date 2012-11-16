function [dir_name] = get_population_data_dir(varargin)
%   [dir_name] = get_population_data_dir([year])
%
%   Get the base directory for the raw population data. If no year is
%   specified, the default will be taken from get_simluation_value.m. Does
%   NOT include the trailing /.
%
%   Note: year should be specified as an integer (e.g. 2010). Valid values
%   can be found using get_simulation_value('valid_pop_data_years')
%
%   See also: get_simulation_value

if nargin == 0
    population_year = get_simulation_value('pop_data_year');
else
    population_year = varargin{1};
end

dir_name = [get_simulation_value('population_data_dir') ...
    '/' num2str(population_year)];

end