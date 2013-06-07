function [] = make_jam_rates(jam_labels)
% function [uniform_power_map fair_rate_map avg_rate_map min_rate_map] =
% make_jam_rates(type, p)
%
% Copied and modified on 24 Feb 2011 from
% Toys/power_rule_toy/make_jam_rates.m
%
% Takes a few minutes to run for width = 5, one type

jam_label_power_map = jam_labels.power_map;
jam_label = jam_labels.rate_map;



% If we don't need to compute, exit now
if (get_compute_status(jam_label) == 0)
    return;
end

% display(['Making jam rates... ' filename]);

map_size = jam_label.noise_label.map_size;
pop_type = jam_label.population_type;

% TNP = get_simulation_value('TNP');
W = get_simulation_value('bandwidth');
[is_in_us lat_coords long_coords] = get_us_map(map_size, 1);
chan_list = get_simulation_value('chan_list');
population_density = get_pop_density(map_size, pop_type, 1);
noise_map = load_by_label(jam_label.noise_label);

dream = 0;
% Load default width
pl_squares_width = get_simulation_value('pl_squares_width');

if (jam_label.hybrid)
    p = jam_label.p2;       % If hybrid, this is when we switch
%     power_p = jam_label.p1;
else
    p = jam_label.p;
%     power_p = jam_label.p;
end

cr_haat = jam_label.char_label.height;
model_number = jam_label.model;

% temp_jam_label = jam_label;
% switch(model_number)
%     case {1,2},
%     % p hasn't factored into the jam calculation yet, so don't bother
%     % recalculating in these cases
%     temp_jam_label.p = 2000;
%     temp_jam_label.model_number = 1;
%     case {3,4},
%         temp_jam_label.model_number = 3;
%     case 5,
%         temp_jam_label.model_number = 5;
%     otherwise,
%         error('Unknown model number.');
% end
    
% Power map data
%     power_filename = get_jam_filename('power_map', temp_jam_label, bpsHz);

if (jam_label.model > 0)
%     temp_jam_label.stage = 'power_map';
%     temp_jam_label.p = power_p;
    power_filename = generate_filename(jam_label_power_map);
    display(['   Using power file ' power_filename]);
    switch(jam_label.power_type)
        case {'old_power', 'old_dream'},    load_string = 'old_power_map';
        case {'new_power', 'new_dream'},    load_string = 'new_power_map';
        case 'flat1',                       load_string = 'flat_power_map1';
        case 'flat2',                       load_string = 'flat_power_map2';
        case 'flat3',                       load_string = 'flat_power_map3';
    end
    power_file = load([power_filename '.mat'], load_string);
    % file = load(save_filename(jam_label));
    
    
    
    % Select our power map
    switch(jam_label.power_type)
        case 'old_power',        power_map = power_file.old_power_map;
        case 'new_power',        power_map = power_file.new_power_map;
        case 'flat1',            power_map = power_file.flat_power_map1; %flat = 1;
        case 'flat2',            power_map = power_file.flat_power_map2; %flat = 1;
        case 'old_dream',        power_map = power_file.old_power_map;
            dream = 1;
        case 'new_dream',        power_map = power_file.new_power_map;
            dream = 1;
        case 'flat3',            power_map = power_file.flat_power_map3; %flat = 1;
    end
    
else
%     temp_jam_label.stage = 'power_map';
    power_filename = generate_filename(jam_label_power_map);
    load([power_filename '.mat'], 'power_map');
end

    char_label = jam_label.char_label;
    char_label.power = 1;   % load with unit power
    
    switch(model_number)
        case {0,1,3,5},
            hex_type = 'cellular';
        case {2,4},
            hex_type = 'wifi';
            
                       
%             warning(['Have not yet restricted cell size appropriately for wifi case']);
%             return;
% %             hex_file = load('HEX (CHAR height=30 power=1) wifi.mat');
% %             area_array = hex_file.area_array(7:end);
% %             signals = hex_file.signals(:, 7:end, :);
% %             noises = hex_file.noises(:, 7:end, :);
            
            % Note: we will automatically round the areas correctly but we need
            % to multiply by the appropriate value later on
        otherwise,
            error('Unknown model number.');
    end
    
    hex_label = generate_label('hex', hex_type, char_label);
    [area_array signals noises] = load_by_label(hex_label);

    % In the wifi/hotspot case, we need to make sure that the cells don't
    % get smaller than the hotspot footprint so we'll remove those entries
    if (string_is(hex_type, 'wifi'))
        wifi_radius = get_simulation_value('hotspot_jam_radius');
        wifi_area = pi*wifi_radius^2;
        wifi_start_idx = find_closest(wifi_area, area_array);
        
        area_array = area_array(wifi_start_idx:end);
        signals = signals(:, wifi_start_idx:end, :);
        noises = noises(:, wifi_start_idx:end, :);
    end
    
    
    %flat = 0;
    
%     if (flat == 0)
%         % Apply exclusions
%         [power_map] = apply_power_map_exclusions(power_map, cr_haat);
%         restrictions = (power_map == 0);
%     else
%         fcc_label = generate_label('fcc_mask', 'cr', '200x300');
%         fcc_mask = load_by_label(fcc_label);
%         power_map = power_map .* fcc_mask;
%         restrictions = ~fcc_mask;
%     end
    
    
    
    
    
    if (~dream)
        display('Loading self-interference data...');
%         display(['   Loading path_loss_rectangles height=' num2str(cr_haat) ' width=' num2str(width) '.mat']);
%         load(['path_loss_rectangles height=' num2str(cr_haat) ' width=' num2str(width) '.mat'], 'out');
        pl_l = generate_label('pl_squares', 'long_range', pl_squares_width, p, pop_type, map_size, jam_label.char_label);
        [out] = load_by_label(pl_l);
%                 fix_filename = ['center_interference_patch_short p=' num2str(p) ', height= ' num2str(cr_haat) '.mat'];
        pl_l2 = generate_label('pl_squares', 'local', 0, p, pop_type, map_size, jam_label.char_label);
        [fix_array] = load_by_label(pl_l2);
%         display(['   Loading ' fix_filename]);
%         fix_file = load(fix_filename, 'int');
%         fix_array = fix_file.int;

        % Save the label used (saved in .mat file) so we can differentiate
        % later since it's not part of the actual jam label
        pl_squares_label = pl_l;
    else
        pl_squares_label = 'none';
    end
    
    
    
    % NOTE: we need a special area that isn't zero outside the US borders,
    % hence the second argument to get_us_area()
    us_area = get_us_area(map_size, 1);
    
    
    
    
    
    
    
    uniform_power_map = zeros(size(power_map)); % per pixel
    fair_rate_map = zeros(size(power_map));
    avg_rate_map = zeros(size(power_map));
    min_rate_map = zeros(size(power_map));
    
    yi = floor(length(long_coords)/2);
    
    
    % For each channel
    for i = 1:length(chan_list)
%         tic
        display(['Current channel: ' num2str(chan_list(i))]);
        if (chan_list(i) == 3 || chan_list(i) == 4)
            continue;
        end
        
        sub_signals = squeeze(signals(i,:,:));
        sub_noises = squeeze(noises(i,:,:));
        
        
        for j = 1:length(lat_coords)
            if (~any(is_in_us(j,:)))
                continue;
            end
            
            
            if(~dream)
                fractions = out(i,j).fractions;
                [frac_x_idx frac_y_idx] = get_center_index(fractions);
            end
            
            for k = 1:length(long_coords)
                if (~is_in_us(j,k) || power_map(i,j,k) == 0)
                    continue;
                end
                
                % area/tower = people/tower / people/area
                tower_area = p / population_density(j,k);
                if (isinf(tower_area))
                    % zero pop areas have inf rate (for now at least)
                    fair_rate_map(i,j,k) = inf;
                    avg_rate_map(i,j,k) = inf;
                    min_rate_map(i,j,k) = inf;
                    continue;
                end
                
                
                
                if ~dream
                    % Fill in the weight on the center pixel... if we care
                    care = fix_array(i,j,k).care;
                    if (isempty(care))
                        care = 0;
                    end
                    
                    if (care)
                        val = fix_array(i,j,k).center_interference;
                    else
                        val = 0;
                    end
                    fractions(frac_x_idx, frac_y_idx) = val;
                    
                    
                    [idx_x idx_y] = get_indices(j, k, lat_coords, long_coords, pl_squares_width);
                    areas2 = us_area(idx_x, idx_y);
                    sub_power_map = squeeze(power_map(i, idx_x, idx_y));
                    if (~all(size(sub_power_map) == size(fractions)))
                        [m1 n1] = size(sub_power_map);
                        [m2 n2] = size(fractions);
                        if k < yi
                            fractions2 = fractions(:, (1+(n2-n1)):end);
                        else
                            fractions2 = fractions(:, 1:(end-(n2-n1)));
                        end
                    else
                        fractions2 = fractions;
                    end
                    uniform_power_map(i,j,k) = get_uniform_power(sub_power_map, fractions2, areas2);
                else
                    uniform_power_map(i,j,k) = power_map(i,j,k);
                end
                
                
                
                % Convert from power per area to power per tower
                uniform_power = uniform_power_map(i,j,k) * tower_area;
                own_power = power_map(i,j,k) * tower_area;
                
%                 isnan(uniform_power)
                
                
                signal = sub_signals;
                noise = sub_noises;
                ambient_noise = noise_map(i,j,k);
                
                low_idx = find(tower_area > area_array, 1, 'last');
                if (low_idx == length(area_array))
                    noise_power = noise(end,:);
                    signal_power = signal(end,:);
                else if (isempty(low_idx))
                        noise_power = noise(1,:);
                        signal_power = signal(1,:);
                    else    % Interpolate
                        high_idx = low_idx + 1;
                        noise_power = log_interp(area_array(low_idx), noise(low_idx,:), ...
                            tower_area, area_array(high_idx), noise(high_idx,:));
                        signal_power = log_interp(area_array(low_idx), signal(low_idx,:), ...
                            tower_area, area_array(high_idx), signal(high_idx,:));
                        
                    end
                end
                
                signal_power = signal_power * own_power;
                noise_power = noise_power * uniform_power;
                
                % Note that ambient noise already has TNP added so we need not
                % add it again
                potential_capacity = W*log2(1 + signal_power./(noise_power + ambient_noise));
                if (any(isnan(potential_capacity)))
%                     signal_power
%                     noise_power
%                     tower_area
                    error('NaN potential capacity');
                end
                
                
                if (model_number == 2 || model_number == 4) % hotspot model -- need to scale
                    rate_factor = tower_area / area_array(1);
                    if (rate_factor < 1)  % tower_area < smallest area
                        potential_capacity = potential_capacity * rate_factor;
                    end
                end
                
                
                
                fair_capacity_per_person = 1/sum(1./potential_capacity);
                fair_capacity = fair_capacity_per_person * size(signals,3);  % point dimension
                %             if (size(signals, 3) < 99)
                %                 error('Not counting the number of users correctly.');
                %             end
                
                avg_capacity = mean(potential_capacity);
                min_capacity = min(potential_capacity);
                
                
                fair_rate_map(i,j,k) = fair_capacity;
                avg_rate_map(i,j,k) = avg_capacity;
                min_rate_map(i,j,k) = min_capacity;
                
                if (isnan(fair_capacity))
                    error('NaN fair capacity');
                end

                
                
                
                
            end
        end
        
        %     figure; imagesc(squeeze(fair_rate_map(i,:,:)));
        %     if (any(any(isnan(squeeze(fair_rate_map(i,:,:))))))
        %         warning('NaN map');
        %     end
        
%         toc
        
        
        
        
    end
    
    

    fair_rate_map_nomedfilt = fair_rate_map;
    fair_rate_map = apply_median_filter(fair_rate_map, p, map_size, pop_type);
    
    
    save_data(save_filename(jam_label), ...
        'jam_label', 'pl_squares_width', 'fair_rate_map', 'avg_rate_map', 'min_rate_map', ...
        'uniform_power_map', 'fair_rate_map_nomedfilt', 'pl_squares_label');
    add_extended_info_to_file(save_filename(jam_label), 'make_jam', 'make_pl_squares');
end





    function [uniform_power] = get_uniform_power(power_map, fractions, areas)
        % Returns uniform *power per area*
        %
        % size(power_map)
        % size(fractions)
        
        weighted_fractions = fractions .* areas;
        
        total_power = sum(sum(power_map .* weighted_fractions));
        % uniform * fractions = total
        uniform_power = total_power / sum(sum(weighted_fractions));
        
        
%         if (isnan(uniform_power))
%             total_power
%             sum(sum(weighted_fractions))
%             weighted_fractions
%             areas
%         end
        
    end
    
    
    
    
