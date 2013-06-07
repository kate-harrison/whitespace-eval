function [] = make_pl_squares(pl_squares_label)
%   [] = make_pl_squares(pl_squares_label)
%
%   Makes path-loss rectanges.


% If we don't need to compute, exit now
if (get_compute_status(pl_squares_label) == 0)
    return;
end

switch(pl_squares_label.type)
    case 'local',       make_local_pl_squares(pl_squares_label);
    case 'long_range',  make_long_range_pl_squares(pl_squares_label);
    otherwise,          error(['Unknown pathloss squares type: ' pl_squares_label.type]);
end


end


function [] = make_local_pl_squares(pl_squares_label)

population_type = pl_squares_label.population_type;
cr_haat = pl_squares_label.char_label.height;
map_size = pl_squares_label.map_size;
p = pl_squares_label.p;


% %% Fix the center interference across the US
% Goal: get equivalent path loss for our pixel and our nearest neighbor
% pixels
% We want to leave this unchanged for those pixels which have
%           tower_area > pixel_area
% and otherwise we wish to build a world around them.
%
% Took 767 seconds to get through i = 1, j = 139, k = 202


% filename = ['center_interference_patch_short p=' num2str(p) ', height= ' num2str(cr_haat) '.mat']
    
[us_area lat_coords long_coords] = get_us_area(map_size);
pop_d = get_pop_density(map_size, population_type, 1);
chan_list = get_simulation_value('chan_list');
is_in_us = get_us_map(map_size, 1);

% area/tower = people/tower / people/area
tower_area_map = p ./ pop_d;
tower_per_pixel_map = us_area ./ tower_area_map;
% we will not update if our cell contains more than one pixel -- too hard
% to guess at what happens here
dont_care_map = tower_per_pixel_map < 1;
dont_care_map(~is_in_us) = 1;

% num_points = numel(us_area);

% int(num_points).care = 0;
int(length(chan_list), size(us_area,1), size(us_area,2)).care = 0;

for i = 1:length(chan_list)
    channel = chan_list(i);
    display(['Current channel: ' num2str(channel)]);
    tic
    
    if (i == 2 || i == 3)
        continue;   % skip channels 3 and 4
    end

%     for j = 19
    for j = 1:length(lat_coords)
        if (all(dont_care_map(j,:)))    % none to update on this row
            continue;
        end
%         if (mod(j,50) == 0)
%         j
%         end
% for k = 138
        for k = 1:length(long_coords)
            if (dont_care_map(j,k))     % this pixel does not need updating
                continue;
            end

            % Time to update the pixel
            tower_area = tower_area_map(j,k);
            tower_per_pixel = tower_per_pixel_map(j,k);
            pixel_area = us_area(j,k);
            
            %% Setup
            %
            % * Red hexagon: our cell
            % * Green hexagons: other cells
            % * Black star: our transmitter
            % * Black dots: other transmitters
            % * Blue dot: our receiver
            % * Maroon circles: other transmitters that interfere with us

            
            num_towers = min(tower_per_pixel - 1, 50);   % remove ourselves from this calculation
%             limit = pixel_area/2;
%             [hexagons] = make_hexagon_grid([0,0], tower_area, limit, limit);
%             center_x = [hexagons.center_x];
%             center_y = [hexagons.center_y];
            % Move to a faster version that puts out exactly what we want
            % and no more
            
%             limit = [sqrt(100*tower_area) sqrt(1000*tower_area) sqrt(pixel_area)];
%             limit = [pixel_area^(.25) sqrt(pixel_area) pixel_area/2 pixel_area 2*pixel_area];
            limit = [sqrt(pixel_area) pixel_area/2 pixel_area 2*pixel_area];
            count = 1;
            while (count == 1 || num_hexes-1 < num_towers)
                [center_x center_y] = get_hexagon_grid_points([0,0], tower_area, limit(count), limit(count));
                count = count + 1;
                
                center_x = center_x(:);
                center_y = center_y(:);

                num_hexes = length(center_x);

                %             if num_hexes > 1000
                %                 num_hexes
                %             end

            end
            
            
            
            
            if (num_hexes-1 < num_towers)
                i
                j
                k
                num_hexes-1
                num_towers
                error('Not enough hexagons!');
            end
            
            center_idx = ceil(num_hexes / 2);

            
%             figure; hold on;
%             for i = 1:length(hexagons)
%                 fill(hexagons(i).xv, hexagons(i).yv, 'g');
%                 plot(hexagons(i).center_x, hexagons(i).center_y, 'k.');
%             end
%             
%             fill(hexagons(center_idx).xv, hexagons(center_idx).yv, 'r');
%             plot(hexagons(center_idx).center_x, hexagons(center_idx).center_y, 'k*', 'markersize', 10);

            % Old way used with make_hexagon_grid()
%             max_xv = max(hexagons(center_idx).xv;
%             x_center = hexagons(center_idx).center_x;
            % New way used with get_hexagon_grid_points()
            hexagon_side_length = sqrt(tower_area * 2/(3*sqrt(3)));
%             hexagon_height = sqrt(3)*hexagon_side_length;
            hexagon_width = 2*hexagon_side_length;
            max_xv = hexagon_width/2;
            
            
            x_center = center_x(center_idx);
            y_center = center_y(center_idx);

            
            rx_x = 5/8*(max_xv - x_center) + x_center;
            rx_y = y_center;
            
%             plot(rx_x, rx_y, 'b.', 'markersize', 10);
            
            
            distances = sqrt( (center_x - rx_x).^2 + (center_y - rx_y).^2  );
            rx_dist_to_tx = distances(center_idx);
            distances(center_idx) = inf;
            distances2 = sort(distances);
            
            tx_dists = distances2(1:ceil(num_towers));
            
%             for i = 1:length(tx_dists)
%                 idx = find(distances == tx_dists(i));
%                 for j = 1:length(idx)
%                     plot(hexagons(idx(j)).center_x, hexagons(idx(j)).center_y, 'mo', 'markersize', 10);
%                 end
%             end
%             axis tight;
%             axis off;
%             
%             for k = 1:length(tx_dists)
%                 circle([rx_x, rx_y], tx_dists(k), 50, 'r');
%             end




            %% Interference for the center pixel (according to setup)
            pathloss = apply_path_loss(1, channel, cr_haat, tx_dists);
            rnd = floor(num_towers);
            
            % fails if num_towers is an integer:
            % weighted_interference = (pathloss .* [ones(1, rnd)'; num_towers-rnd]) / num_towers;  
            
            % don't actually want to weight by tower area since we want to
            % end up with power per area
            %             weighted_interference = (pathloss .* [ones(1, rnd)'; ones(ceil(num_towers-rnd))*(num_towers-rnd)]) * tower_area;
            weighted_interference = (pathloss .* [ones(1, rnd)'; ones(ceil(num_towers-rnd))*(num_towers-rnd)]);
            center_interference = sum(weighted_interference) / num_towers;
            
            int(i,j,k).num_towers = num_towers;
            
            int(i,j,k).care = ~dont_care_map(j,k);
            int(i,j,k).center_interference = center_interference;
            
            %% Important: removing the continue line below will compute for a 3x3 grid but the rest of the code is not set up to handle this yet           
            continue;
            
            %% Interference from neighboring pixels
            % Find our location
            our_i = j;
            our_j = k;
            our_pixel_area = us_area(our_i, our_j);
            our_y = lat_coords(our_i);
            our_x = long_coords(our_j);
            
            
            % Find the receiver's location
            R = 6371;   % Earth's mean radius
            d = rx_dist_to_tx;
            lat1 = our_y * pi/180;
            long1 = our_x * pi/180;
            theta = 0;
            lat2 = asin(sin(lat1) * cos(d/R) + cos(lat1)*sin(d/R)*cos(theta));
            long2 = long1 + atan2(sin(theta) * sin(d/R) * cos(lat1), cos(d/R)-sin(lat1)*sin(lat2));
            rx_y = lat2 * 180/pi;
            rx_x = long2 * 180/pi;
            
            % rx_y = our_y;
            % rx_x = our_x;
            
            
            % Set up the neighboring pixels
            nb_i = our_i + [-1 0 1];
            nb_j = our_j + [-1 0 1];
            areas = us_area(nb_i, nb_j);
            ns = tower_per_pixel_map(nb_i, nb_j);
            ns(ns <= 1 & ns > 0) = 1;
            ns(ns > 1) = 9;
            [nb_i nb_j] = meshgrid(nb_i, nb_j);
            nb_y = lat_coords(nb_i);
            nb_x = long_coords(nb_j);
            
            x_width = long_coords(2) - long_coords(1);
            y_width = lat_coords(2) - lat_coords(1);
            
%             center_x = our_x;
%             center_y = our_y;
            

% continue

            ns(:) = 9;

            interference = zeros(3,3);
            distances = zeros(8*9,1);
            
            indices = [1 10 19; 28 0 37; 46 55 64];
            
            for a = 1:3
                for b = 1:3
                    if (a == 2 && b == 2)
                        continue;                % Our pixel
                    end
                    
                    n = ns(a,b);
                    if (n == 0)
                        continue;
                    end
                    
                    center_x = nb_x(a,b);
                    center_y = nb_y(a,b);
                    

                    
%                     [squares x y] = make_squares(n, center_x - x_width/2, center_y - y_width/2, ...
%                         center_x + x_width/2, center_y + y_width/2);

                    % Make the centers of the squares in the nearby pixel
                    % This is stolen from make_squares() on 2 March 2011
                    dim = ceil(sqrt(n));

                    x1 = center_x - x_width/2;
                    y1 = center_y - y_width/2;
                    x2 = center_x + x_width/2;
                    y2 = center_y + y_width/2;
                    
                    width1 = (x2 - x1) / dim;
                    width2 = (y2 - y1) / dim;

                    
                    x = x1+width1/2:width1:x2-width1/2;
                    y = y1+width2/2:width2:y2-width2/2;                    
                    [x y] = meshgrid(x,y);
                    
                    distances(indices(a,b)+(0:8)) = latlong_to_km(rx_y, rx_x, y(:), x(:));
%                     distances = [distances, latlong_to_km(rx_y, rx_x, y(:), x(:))];
                    
%                     if (length(distances) > 9)
%                         error('too big');
%                     end
%                     pl = apply_path_loss(1, channel, cr_haat, distances);
%                     interference(a,b) = mean(pl);
                    
%                     for k = 1:length(distances)
%                         circle([center_x, center_y], distances(k), 50, 'k');
%                     end
                    
                    
                end
            end
            
            pl = apply_path_loss(1, channel, cr_haat, distances);
            
            for a = 1:3
                for b = 1:3
                    if (a == 2 && b == 2)
                        continue;                % Our pixel
                    end
                    
                    interference(a,b) = mean(pl(indices(a,b)+(0:8)));
                    
                end
            end
                    
                    interference(2,2) = center_interference;
            
            
%             total_int1 =  get_W_to_dBm(sum(sum(int)))
%             
%             center_int1 = get_W_to_dBm(center_interference)
            
            
%             
            
            %% Store the values
%             [i j k]
%             interference
            int(i,j,k).grid = interference;
            int(i,j,k).ns = ns;
            int(i,j,k).care = ~dont_care_map(j,k);
            int(i,j,k).nb_x = nb_x;
            int(i,j,k).nb_y = nb_y;
            int(i,j,k).nb_i = nb_i;
            int(i,j,k).nb_j = nb_j;
        end
    end

end

save_data(save_filename(pl_squares_label), 'int', 'chan_list', 'dont_care_map', ...
    'tower_area_map', 'tower_per_pixel_map');

% The array of structures 'int' has the following fields:
%   num_towers = the number of towers in that pixel
%   care = 1 if num_towers > 1, 0 otherwise (also if outside US)
%   center_interference = self-interference from center pixel only (and
%       only included if care = 1)


end





function [] = make_long_range_pl_squares(pl_squares_label)

cr_haat = pl_squares_label.char_label.height;
width = pl_squares_label.width;
map_size = pl_squares_label.map_size;

[is_in_us lat_coords long_coords] = get_us_map(map_size, 1);
chan_list = get_simulation_value('chan_list');


end1 = length(chan_list);
end2 = length(lat_coords);
out(end1, end2).distances = [];
out(end1, end2).fractions = [];
out(end1, end2).idx_x = [];
out(end1, end2).idx_y = [];

% tic
for i = 1:length(chan_list)
%     toc
%     tic
    
    display(['Current channel: ' num2str(chan_list(i))]);
    if (chan_list(i) == 3 || chan_list(i) == 4)
        continue;
    end
    
    yi = floor(length(long_coords)/2);
    for j = 1:length(lat_coords)
        if (~any(is_in_us(j,:)))
            continue;
        end
        
        [dists fracts x y] = make_dists_and_pls(j, yi, lat_coords, ...
            long_coords, chan_list(i), cr_haat, width);
        
        
        out(i,j).distances = dists;
        out(i,j).fractions = fracts;
        out(i,j).idx_x = x;
        out(i,j).idx_y = y;
        
    end
end

% Save output
pl_squares = out;
save_data(save_filename(pl_squares_label), 'pl_squares', 'pl_squares_label', ...
    'chan_list', 'lat_coords', 'long_coords');

end


function [distances fractions idx_x idx_y] = make_dists_and_pls(xi, yi, lat_coords, long_coords, channel, cr_haat, width)

% [xi, yi, lat_coords, long_coords, channel, cr_haat, width] = varargin{1:7};

% Make distance matrix
% idx_x = [max(1, xi - width) : min(xi + width, length(lat_coords))];
% idx_y = [max(1, yi - width) : min(yi + width, length(long_coords))];

[idx_x idx_y] = get_indices(xi, yi, lat_coords, long_coords, width);


x = lat_coords(xi);
y = long_coords(yi);

sub_lats = lat_coords(idx_x);
sub_longs = long_coords(idx_y);

[LAT LONG] = meshgrid(sub_lats, sub_longs);
distances = latlong_to_km(LAT, LONG, x, y)';
our_cell_indices = (distances == 0);

% figure; imagesc(sub_lats, sub_longs, distances);

% Make path loss matrix
fractions = zeros(size(distances));
for i = 1:size(distances,1)
    fractions(i,:) = apply_path_loss(1, channel, cr_haat, distances(i,:));
end
fractions(our_cell_indices) = 0;
% figure; imagesc(log(fractions)); colorbar;


end
