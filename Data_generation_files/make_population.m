function [] = make_population(population_label)
%   function [] = make_population(population_label)
%
% Makes a file that lists the population density of the US at each point.
%
% Assume that the population is zero if we can't find a zip code for the
% coordinates.
%
% Run time: approx. 2.5 hours for 200x300 map
%           approx. 9.2 hours for 400x600 map
%
% See also: generate_label

error_if_region_unsupported('US');


% % The statement below is no longer true but you could cleverly adapt them
% % with a little effort.
% If you cannot devote the full 2.5 hours, uncomment the three lines below
% and comment the first line of the file to run it as a script. 

% clc; clear all; close all;
% year = 2010
% varargin = {'400x600'}


%% Load existing data
map_size = population_label.map_size;

filename = save_filename(population_label);

% If we don't need to compute, exit now
if (get_compute_status(filename) == 0)
    return;
end

[us_area lat_coords long_coords] = get_us_area(map_size);
is_in_us = get_us_map(map_size, 1);

[type year] = split_flag(population_label.population_type);
year = str2num(year);

tract_info = load_tract_info(year);

%% Create bounding boxes for the polygons
for i = 1:length(tract_info)
    tract_info(i).max_lat = max(tract_info(i).lats);
    tract_info(i).min_lat = min(tract_info(i).lats);
    tract_info(i).max_long = max(tract_info(i).longs);
    tract_info(i).min_long = min(tract_info(i).longs);
end

%% Create the population maps

tic

% Start with a map that is -1 in the US, 0 outside
population = is_in_us * 0.0;
min_pop_density = is_in_us * inf;
max_pop_density = is_in_us * -1;



lat_half_width = (lat_coords(2) - lat_coords(1))/2;
long_half_width = (long_coords(2) - long_coords(1))/2;


% figure; hold on;
% For each point in the US
for i = 1:length(lat_coords)
    if (mod(i,1) == 0)
        display(['Working on lat coord ' num2str(i) ' out of ' num2str(length(lat_coords))]);
    end
    
    for j = 1:length(long_coords)
        if (mod(j,100) == 0)
            display(['   Working on long coord ' num2str(j) ' out of ' num2str(length(long_coords))]);
        end

        
        % Skip points outside the US
        if (~is_in_us(i,j))
            continue;
        end

        clear map_pt
        map_pt.y = lat_coords(i) + [-1 1 1 -1]*lat_half_width;
        map_pt.x = long_coords(j) + [-1 -1 1 1]*long_half_width;
        map_pt.hole = 0;
        
        max_lat = max(map_pt.y);
        min_lat = min(map_pt.y);
        max_long = max(map_pt.x);
        min_long = min(map_pt.x);
        
        % For each tract
        for n = 1:length(tract_info)
            
            % Overlap logic: http://www.rgrjr.com/emacs/overlap.html
            if (~((tract_info(n).min_lat < max_lat) && (min_lat < tract_info(n).max_lat)) || ...
                    ~((tract_info(n).min_long < max_long) && (min_long < tract_info(n).max_long)));
                continue;
            end
            
            
            
            idcs = [0 find(isnan(tract_info(n).longs))];
            
            % For each polygon within the tract
            for m = 1:length(idcs)-1
                idcs2 = idcs(m)+1:idcs(m+1)-1;
                clear tract_poly
                tract_poly.y = tract_info(n).lats(idcs2);
                tract_poly.x = tract_info(n).longs(idcs2);
                tract_poly.hole = 0;
                
                % Find the overlap
                overlap_poly = PolygonClip(map_pt, tract_poly, 1);
                
                % If no overlap, skip to the next polygon
                if (isempty(overlap_poly))
                    continue;
                end
                
                % Add up the "area" of the overlap
                poly_area = 0;
                for k = 1:length(overlap_poly)
                    poly_area = poly_area + ...
                        polyarea(overlap_poly(k).x, overlap_poly(k).y);
                end
                
                % Find the percentage of the total area
                total_area = polyarea(tract_poly.x, tract_poly.y);
                perc_area = poly_area / total_area;
                
                % Add the portion of the population in that tract that
                % should be in this pixel
                population(i,j) = population(i,j) + tract_info(n).pop * perc_area;
                min_pop_density(i,j) = min(min_pop_density(i,j), tract_info(n).pop_density);
                max_pop_density(i,j) = max(max_pop_density(i,j), tract_info(n).pop_density);
                
                
            end
        end





    end
end


total_pop = sum(sum(population))

% Assign the population density
pop_density = population ./ us_area;

save(filename, 'population', 'pop_density', ...
    'lat_coords', 'long_coords', 'max_pop_density', 'min_pop_density');

toc
