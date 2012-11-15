function [] = make_us_map(map_size)
%   [] = make_us_map(map_size)
%
% Creates a matrix of binary values to answer the question "is this point
% in the US?"

validate_flags('', 'map_size', map_size);
filename = ['Data/in_us' map_size '.mat'];

% If we don't need to compute, exit now
if (get_compute_status(filename) == 0)
    return;
end



% Set the bounds for the rectangle we'd like to create
max_lat = 50;
min_lat = 24;
max_long = -66;
min_long = -126;


split = regexp(map_size, 'x', 'split');
num_lat_div = str2double(split{1});
num_long_div = str2double(split{2});
lat_coords = linspace(min_lat, max_lat, num_lat_div);
long_coords = linspace(min_long, max_long, num_long_div);

[longs_map lats_map] = meshgrid(long_coords, lat_coords);
longs_vec = longs_map(:);
lats_vec = lats_map(:);

is_in_us = zeros(length(lat_coords), length(long_coords));

map_points = [longs_vec, lats_vec];


%% Make the US polygon
[S,A] = shaperead('usastatehi.shp', 'usegeocoords', true);

% longs = [];
% lats = [];

in_vec = zeros(size(lats_vec));

for i = 1:length(S)
    
        % Omit Alaska and Hawaii
    if (i == 2 || i == 11)
        continue;
    end


    idcs = [0 find(isnan(S(i).Lon))];

    for j = 1:length(idcs)-1
        idcs2 = idcs(j)+1:idcs(j+1)-1;
        plot_lat = S(i).Lat(idcs2);
        plot_long = S(i).Lon(idcs2);
%         patch(plot_long, plot_lat, color);
        poly_points = [plot_long; plot_lat]';
        [in] = inpoly(map_points, poly_points);

        in_vec = in_vec | in;
    end
end




%% Reshape the data

is_in_us = reshape(in_vec, size(is_in_us));



%% Save
save(filename, 'is_in_us', 'num_lat_div', 'num_long_div', ...
    'max_lat', 'min_lat', 'max_long', 'min_long', 'long_coords', 'lat_coords');