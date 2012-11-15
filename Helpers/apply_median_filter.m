function [new_map] = apply_median_filter(map, p, map_size, pop_type)
%   function [new_map] = apply_median_filter(map, p, map_size, pop_type)
%
%   Applies a spatially-variant median filter (which is dependent on the
%   number of people per tower, [p]) to [map].
%
% * Uses population distribution according to [pop_type]
% * Uses map size [map_size]




% Apply the median filter to a data rate map

% clc; clear all; close all;
% power = 0;
% height = 30;
% char_label = generate_label('char', height, power);
chan_list = get_simulation_value('chan_list');
% map_size = get_simulation_value('map_size');
[is_in_us lat_coords long_coords] = get_us_map(map_size, 1);
us_area = get_us_area(map_size);
pop_density = get_pop_density(map_size, pop_type, 1);
% p = 2000;

tower_areas = p ./ pop_density;
% towers_per_pixel =
%  (area/tower) / (area/pixel)
pixels_per_tower = tower_areas ./ us_area;

% min_pixels_per_tower = floor(sqrt(pixels_per_tower)).^2;


% model_number = 3
% 
% jam_label = generate_label('jam', p, 'real', char_label, model_number)
% make_jam(jam_label);

% bpsHz = 0.5;
% 
% type = 2
% switch(type)
%     case 1, power_type = 'old_power';
%     case 2, power_type = 'new_power';
%     case 3, power_type = 'old_dream';
%     case 4, power_type = 'new_dream';
% end
% 
% filename = ['Data/' get_jam_filename('rate_map', jam_label, bpsHz, power_type)]
% file = load(filename);

rate_map = map * 1.0;
% size(rate_map)
new_rate_map = rate_map;

xi = floor(length(lat_coords)/2);
yi = floor(length(long_coords)/2);

% For each point in the US...
for j = 1:length(lat_coords)
%     if (mod(j,10)==0)
%         display(['Current latitude index: ' num2str(j) ' of ' num2str(length(lat_coords))]);
%     end
    
    for k = 1:length(long_coords)
        if (is_in_us(j,k) == 0)
            continue;       % Skip points outside the US and points inside rp
        end
        
        if (pixels_per_tower(j,k) < 9 || isinf(pixels_per_tower(j,k)))
            continue;
        end
        
        support = floor(sqrt(pixels_per_tower(j,k)));
        [idx_x idx_y] = get_indices(j,k,lat_coords, long_coords, support);
        sub_ppt_map = pixels_per_tower(idx_x, idx_y);
%         med_idcs = false(size(sub_ppt_map));
%         for n = fliplr(1:support)
%             thresh = (2*abs(n)+1)^2;
%             med_idcs(sub_ppt_map > thresh) = 1;
%         end

        threshold = zeros(2*support+1);

        for n = fliplr(1:support)
            idcs = (-n:n) + (support+1);
            threshold(idcs, idcs) = (2*abs(n)+1)^2;
        end
                
        if (~all(size(sub_ppt_map) == size(threshold)))
            [m1 n1] = size(sub_ppt_map);
            [m2 n2] = size(threshold);
            if (n2 ~= n1)
                if k < yi
                    threshold = threshold(:, (1+(n2-n1)):end);
                else
                    threshold = threshold(:, 1:(end-(n2-n1)));
                end
            end
            if (m2 ~= m1)    % m2 ~= m1
                if j < xi
                    threshold = threshold((1+(m2-m1)):end, :);
                else
                    threshold = threshold(1:(end-(m2-m1)), :);
                end
                
            end
            
        else
            % Unchanged
%             threshold2 = threshold;
%             fractions2 = fractions;
        end
        
        
        med_idcs = sub_ppt_map >= threshold;
%         med_idcs(ceil(end/2), ceil(end/2)) = 0;


%         
        if all(all(med_idcs == 0))  % didn't find an acceptable neighbor
            continue;
        end
        
        for i = 1:length(chan_list)
            sub_rate_map = squeeze(rate_map(i, idx_x, idx_y));
%             islogical(sub_rate_map)
%             islogical(rate_map)
%             sub_rate_map
            sub_rate_map(isinf(sub_rate_map)) = 0/0;

%             sub_rate_map(med_idcs)



            % Apparently I don't have the toolbox for this anymore...
%             new_rate_map(i,j,k) = nanmean(sub_rate_map(med_idcs));

            % Workaround:
            temp = sub_rate_map(med_idcs);
            temp(isnan(temp)) = [];
            new_rate_map(i,j,k) = median(temp);
        end
        
    end
end



new_map = new_rate_map;





% 
% %%
% close all;
% scale = 1e6;
% label = 'Mbps';
% 
% map = squeeze(sum(new_rate_map,1));
% map(~is_in_us) = inf;
% 
% % fn = get_jam_filename('rate_fig', jam_label, bpsHz, power_type, fig_type)   % filename
% make_map(map/scale, 'map_type', 'log', 'colorbar_title', label, 'save', 'off', 'title', 'new');
% 
% 
% 
% 
% map = file.fair_rate_map;
% map = squeeze(sum(map,1));
% map(~is_in_us) = inf;
% 
% % fn = get_jam_filename('rate_fig', jam_label, bpsHz, power_type, fig_type)   % filename
% make_map(map/scale, 'map_type', 'log', 'colorbar_title', label, 'save', 'off', 'title', 'old');
% 
% 
% 
% 










end