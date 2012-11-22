function [] = make_region_outline(region_outline_label)
%   [] = make_region_outline(region_outline_label)
%
%   Makes polygons which are outlines of the US states for use as an
%   overlay in make_map().

error_if_region_unsupported('US');

map_size = region_outline_label.map_size;
filename = save_filename(region_outline_label);

% If we don't need to compute, exit now
if (get_compute_status(filename) == 0)
    return;
end



%% Read in the shapefile (standard with Matlab)
[S,A] = shaperead('usastatehi', 'usegeocoords', true);

%% Move coordinates from structure to array format
state_lats = [];
state_longs = [];

% Loop over the states
for i = 1:51
    % Omit Alaska and Hawaii
    if (i == 2 || i == 11)
        continue;
    end
    
    state_lats = [state_lats, 0/0, S(i).Lat];
    state_longs = [state_longs, 0/0, S(i).Lon];
end

% Load in the latice we'll use
[null, lat_coords, long_coords] = get_us_map(map_size);


%% Snap the vertices to grid points
lats = ones(size(state_lats))*0/0;
longs = ones(size(state_lats))*0/0;

change_range = @(OldValue, OldMin, OldMax, NewMin, NewMax)(((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin;


min_lat = min(lat_coords);
max_lat = max(lat_coords);
min_long = min(long_coords);
max_long = max(long_coords);


lats = change_range(state_lats, min_lat, max_lat, 1, length(lat_coords));
longs = change_range(state_longs, min_long, max_long, 1, length(long_coords));


save(filename, 'lats', 'longs');

end