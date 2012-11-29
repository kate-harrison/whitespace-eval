function [] = make_region_mask(region_mask_label)
%   [] = make_region_mask(region_mask_label)
%
% Creates a matrix of binary values to answer the question "is this point
% in the region?" The region, among other parameters, are set in
% Helpers/get_simulation_value.m
%
% See also: get_simulation_value.m

error_if_region_unsupported('US');

switch(get_simulation_value('region_code'))
    case 'US',
        make_us_mask(region_mask_label);
    otherwise,
        error('Unsupported region code.');
end

end




function [] = make_us_mask(region_mask_label)


map_size = region_mask_label.map_size;

filename = generate_filename(region_mask_label);

% If we don't need to compute, exit now
if (get_compute_status(filename) == 0)
    return;
end


%% Set the bounds for the rectangle we'd like to create
[min_lat max_lat] = get_simulation_value('minmax_lat');
[min_long max_long] = get_simulation_value('minmax_long');

[num_lat_div num_long_div] = get_map_dims_from_string(map_size);
lat_coords = linspace(min_lat, max_lat, num_lat_div);
long_coords = linspace(min_long, max_long, num_long_div);

[longs_map lats_map] = meshgrid(long_coords, lat_coords);
longs_vec = longs_map(:);
lats_vec = lats_map(:);

is_in_us = zeros(length(lat_coords), length(long_coords));

map_points = [longs_vec, lats_vec];


%% Retrieve the region's polygon
[S,A] = get_simulation_value('region_shapefile');


%% Determine which points are inside the polygon
region_code = get_simulation_value('region_code');

in_vec = zeros(size(lats_vec));

for i = 1:length(S)
    
    switch(region_code)
        case 'US',
            % Omit Alaska and Hawaii
            if (i == 2 || i == 11)
                continue;
            end
        otherwise,
    end


    idcs = [0 find(isnan(S(i).Lon))];

    for j = 1:length(idcs)-1
        idcs2 = idcs(j)+1:idcs(j+1)-1;
        plot_lat = S(i).Lat(idcs2);
        plot_long = S(i).Lon(idcs2);
        poly_points = [plot_long; plot_lat]';
        [in] = inpoly(map_points, poly_points);

        in_vec = in_vec | in;
    end
end


%% Reshape the data
is_in_us = reshape(in_vec, size(is_in_us));


%% Save the data
save(save_filename(region_mask_label), 'is_in_us', 'num_lat_div', 'num_long_div', ...
    'max_lat', 'min_lat', 'max_long', 'min_long', 'long_coords', 'lat_coords');


end