function [ file ] = load_population_data(map_size, year)
%   [ file ] = load_population_data(map_size, year)
%
%   Loads the population map file for the given census year (valid options:
%   2000, 2010) and map size (valid options: 200x300, 201x301, 400x600).


switch(year)
    case {2000, 2010},
        file = load(['Data/population_map ' map_size ' year=' num2str(year) '.mat']);
    otherwise,
        error(['Invalid population data year: ' num2str(year)]);
end

end