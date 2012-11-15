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
%   Loads the tract information for the given census year (valid options:
%   2000, 2010). Tract information includes polygons, population,
%   population density, land area, and total area.


switch(year)
    case {2000, 2010},
        filename = ['Population_and_tower_data/Population/' num2str(year) ...
            '/tract_info' num2str(year) '.mat'];
    otherwise
        error(['Invalid population data year: ' num2str(year) ...
            '. Valid options are 2000 and 2010.']);
end

if (nargout <= 1)   % one or fewer output arguments
    file = load(filename, 'tract_info');
    varargout{1} = file.tract_info;
else
    file = load(filename, 'pop', 'pop_density', 'land_area', 'total_area');
    varargout = {file.pop, file.pop_density, file.land_area, file.total_area};
end

end