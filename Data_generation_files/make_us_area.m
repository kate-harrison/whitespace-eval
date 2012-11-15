function [] = make_us_area(map_size)
%   [] = make_us_area(map_size)
%
% Finds the area represented by each point in the US
% Assume that it extends lat_div_size/2 east-west
% Assume that it extends long_div_size/2 north-south


validate_flags('', 'map_size', map_size);
filename = ['Data/us_area' map_size '.mat'];

% If we don't need to compute, exit now
if (get_compute_status(filename) == 0)
    return;
end



[is_in_us lat_coords long_coords] = get_us_map(map_size, 1);

% Make a blank array
us_area = is_in_us*0;

% Figure out the distance between each point
% Exploit uniformity and just use the first two values
lat_div_size = lat_coords(2) - lat_coords(1);
long_div_size = long_coords(2) - long_coords(1);

% For each point in the US...
for i = 1:length(lat_coords)
    for j = 1:length(long_coords)
        
%         if (~is_in_us(i,j))
%             continue;
%         end
        
        % Calculate its area by pinpointing each corner of the trapezoid it
        % represents
        % Assume that it extends lat_div_size/2 east-west
        NW_lat = lat_coords(i) + lat_div_size/2;
        SW_lat = NW_lat;
        NE_lat = lat_coords(i) - lat_div_size/2;
        SE_lat = NE_lat;
        % Assume that it extends long_div_size/2 north-south
        NW_long = long_coords(j) + long_div_size/2;
        SW_long = long_coords(j) - long_div_size/2;
        NE_long = NW_long;
        SE_long = SW_long;
        
        %plot(NW_long, NW_lat, 'o', SW_long, SW_lat, 'o', SE_long, SE_lat, 'o', NE_long, NE_lat), 'o';
        
        % This is the same between east and west
        height = latlong_to_km(NW_lat, NW_long, SW_lat, SW_long);
        
        top = latlong_to_km(NW_lat, NW_long, NE_lat, NE_long);
        bottom = latlong_to_km(SW_lat, SW_long, SE_lat, SE_long);
        
        area = 0.5*height*(top+bottom);
        
        us_area(i,j) = area;
        
    end
end

% figure; imagesc(us_area); axis xy; colorbar;

save(['Data/us_area_full_' map_size '.mat'], 'us_area', 'lat_coords', 'long_coords');

us_area = us_area .* is_in_us;  % zero outside the US
% figure; imagesc(us_area); axis xy; colorbar;


save(filename, 'us_area', 'lat_coords', 'long_coords');