function [ varargout ] = load_tract_info(year)
%   [ varargout ] = load_tract_info(year)
%
%   If called with ZERO or ONE output argument, loads the entire tract_info
%   structure. Used predominantly for obtaining coordinate information.
%     [ tract_info] = load_tract_info(year)
%
%   If called with MORE THAN ONE output argument, loads select variables.
%   This option is much faster than loading the entire structure.
%     [ population pop_density land_area total_area ] = load_tract_info(year)
%
%   Loads the tract information for the given census year. Tract
%   information includes polygons, population, population density, land
%   area, and total area.

valid_years = get_simulation_value('valid_pop_data_years');
valid_years_cells = cell(size(valid_years));
for i = 1:length(valid_years)
    valid_years_cells{i} = valid_years(i);
end

switch(year)
    case valid_years_cells,%{2000, 2010},
        filename = [get_population_data_dir(year) ...
            '/tract_info' num2str(year) '.mat'];
    otherwise
        error(['Invalid population data year: ' num2str(year) ...
            '. Valid options are: ' num2str(valid_years)]);
end

if (nargout <= 1)   % one or fewer output arguments
    file = load(filename, 'tract_info');
    varargout{1} = file.tract_info;
else
    file = load(filename, 'pop', 'pop_density', 'land_area', 'total_area');
    varargout = {file.pop, file.pop_density, file.land_area, file.total_area};
end

end