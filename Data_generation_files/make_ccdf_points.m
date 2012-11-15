function [] = make_ccdf_points(ccdf_points_label)
%   [] = make_ccdf_points(ccdf_points_label)
%
%
%   Note: We ignore the wireless microphone exclusions.
%
%   Notes for later:
%    * tv_removal-2 (sharing) assumes cochannel + adjacent channel
%    exclusions even though this won't always be necessary (some TV
%    channels will have all their TV towers removed) -- should fix this but
%    haven't yet
%


% If we don't need to compute, exit now
if (get_compute_status(ccdf_points_label) == 0)
    return;
end

variable = ccdf_points_label.variable;
capacity_label = ccdf_points_label.capacity_label;
    capacity_type = capacity_label.capacity_type;
    range_type = capacity_label.range_type;
    range_value = capacity_label.range_value;
%     mac_table_label = capacity_label.mac_table_label;
mac_table_label = capacity_label.cell_model_label;


[~, tower_data_year] = split_flag(ccdf_points_label.capacity_label.noise_label.channels);
mask_device_type = ['cr-' tower_data_year];
tv_device_type = ['tv-' tower_data_year];


map_size = capacity_label.noise_label.map_size;
population_type = capacity_label.population_type;
if (string_is(population_type, 'none'))
    population_type = get_simulation_value('pop_data_type');
    soft_warning(['Assuming population type ' population_type ' in make_ccdf_points()']);
end
char_label = capacity_label.char_label;

population = get_population(map_size, population_type, 1);
is_in_us = get_us_map(map_size, 1);
chan_list = get_simulation_value('chan_list');


switch(variable)
    % TV REMOVAL
    case {'tv_removal-1', 'tv_removal-2'},
        [~, type] = split_flag(variable);
        switch(type)
            case '1',   share = 0; %cochannel_noise = 'no';
                tv_user_label = generate_label('fm_mask', tv_device_type, map_size, 0, char_label);   % note char_label doesn't matter here
                % Each channel either has TV or CRs, NOT both
            case '2',   share = 1; %cochannel_noise = 'yes';
                tv_user_label = generate_label('fcc_mask', tv_device_type, map_size);
                % Each channel is either CR only or CR+TV (latter has
                % exclusions)
                % May not have optimal channel removal order!
        end
        
        tv_users = load_by_label(tv_user_label);
        
        % FIND ORDER
        % Establish removal order by looking at potential (thermal noise
        % only)
        potential_noise_label = generate_label('noise', 'no', map_size, 'tv', 'none');
        potential_capacity_label = generate_label('capacity', capacity_type, range_type, ...
            range_value, population_type, char_label, potential_noise_label, ...
            mac_table_label);
        
        % Get capacity and zero values outside the US
        potential_capacity = load_by_label(potential_capacity_label) ...
            .* get_us_map(map_size, length(chan_list));
        % We are not allowed to transmit on channels 3 and 4, so we set their
        % capacity to zero
        zero_channels = [get_channel_index(3), get_channel_index(4)];
        potential_capacity(zero_channels,:,:) = 0;
        
        
        avg_cap = zeros(1, length(chan_list));
        med_cap = zeros(1, length(chan_list));
        num_tv_people = zeros(1, length(chan_list));
        
        % For each channel
        for c = 1:length(chan_list)
            [~, ~, avg_cap(c), med_cap(c)] = calculate_cdf_from_map( squeeze(potential_capacity(c,:,:)), population, is_in_us );
            % Figure out how many people we have watching this channel
            num_tv_people(c) = sum(sum( squeeze(tv_users(c,:,:)) .* population ));
        end
        
        chan_value = med_cap./num_tv_people;
        chan_value(zero_channels) = 0;      % Make sure that channels 3 and 4 have no value
        tradeoff = [chan_value; chan_list];
        tradeoff = sortrows(tradeoff')';
        tradeoff = fliplr(tradeoff);
        order = tradeoff(2,:);
        
        
        % Create a list of adjacent channels
        adj_up = zeros(size(chan_list));
        adj_down = zeros(size(chan_list));
        for i = 1:length(chan_list)
            up = has_frequency_neighbor(i, 'up');
            if (up) adj_up(i) = chan_list(i+1); end;
            down = has_frequency_neighbor(i, 'down');
            if (down) adj_down(i) = chan_list(i-1); end;
        end
        
        
        % REMOVE CHANNELS
        
        % Get various capacities
        for i = 1:2
            switch(i)
                case 1,
                    cochannel_noise = 'no';
                    mask = ones(size(potential_capacity));
                case 2,
                    cochannel_noise = 'yes';
                    fcc_mask_label = generate_label('fcc_mask', mask_device_type, map_size);
                    [~, extras] = load_by_label(fcc_mask_label);
                    mask = extras.cochannel_mask;
%                     error('NEED TO BE USING COCHANNEL MASK ONLY HERE -- FIX ASAP');
            end
            
            % Don't need to compute if we're not given the option of
            % sharing
            if (~share && i == 2)
                continue;
            end
            
            % Clean cochannel, clean adjacent channels
            temp_noise_label = generate_label('noise', cochannel_noise, map_size, 'tv', 'none');
            temp_cap_label = generate_label('capacity', capacity_type, range_type, range_value, ...
                population_type, char_label, temp_noise_label, mac_table_label);
            cap_none{i} = load_by_label(temp_cap_label) .* mask;
            % Clean cochannel, upper channel leaks
            temp_noise_label = generate_label('noise', cochannel_noise, map_size, 'tv', 'up');
            temp_cap_label = generate_label('capacity', capacity_type, range_type, range_value, ...
                population_type, char_label, temp_noise_label, mac_table_label);
            cap_up{i} = load_by_label(temp_cap_label) .* mask;
            % Clean cochannel, lower channel leaks
            temp_noise_label = generate_label('noise', cochannel_noise, map_size, 'tv', 'down');
            temp_cap_label = generate_label('capacity', capacity_type, range_type, range_value, ...
                population_type, char_label, temp_noise_label, mac_table_label);
            cap_down{i} = load_by_label(temp_cap_label) .* mask;
            % Clean cochannel, both channels leak
            temp_noise_label = generate_label('noise', cochannel_noise, map_size, 'tv', 'both');
            temp_cap_label = generate_label('capacity', capacity_type, range_type, range_value, ...
                population_type, char_label, temp_noise_label, mac_table_label);
            cap_both{i} = load_by_label(temp_cap_label) .* mask;
        end
        
        % Set up blank arrays
        med_cr = zeros(1, length(order)+1);
        avg_cr = zeros(1, length(order)+1);
%         per_cr = zeros(1, length(order)+1);
        med_tv = zeros(1, length(order)+1);
        avg_tv = zeros(1, length(order)+1);
%         per_tv = zeros(1, length(order)+1);
        cap = zeros(size(cap_none{1}));
        
        % Reset these variables to their defaults
        tv_user_mask = tv_users;    % Availability limited by TV towers only
%         cr_user_mask = zeros(size(tv_users));   % Allowed nowhere
        
        tv_allowed = chan_list;
        
        % For each channel...
        for c2 = 0:length(order)
            c = c2+1;
            % Create the capacity map, part 1
%             cap_per_area = zeros(size(cap_none));
            
            if (c2 ~= 0 || share)
            
                if (c2 ~= 0)
                    display(['  Removing channel ' num2str(order(c2))]);
                    idx = get_channel_index(order(c2));
                    % Remove TV usage (available nowhere)
                    tv_user_mask(idx,:,:) = 0;
                    tv_allowed(idx) = 0;
                else
                    display('  Computing baseline');
                end

                % Create the capacity map, part 2
                for ch = 1:length(chan_list)
                    if (tv_allowed(ch)~=0 && ~share)
                        continue;   % TV's allowed so CR is not, keep default capacity of zero
                    elseif (tv_allowed(ch)~=0 && share)  % TV allowed
                        noise_idx = 2;  % cochannel noise
                    else
                        noise_idx = 1;  % no cochannel noise
                    end

                    % If we can find its upper adj. channel in the list of
                    % allowed TV channels, it has an upper adj. channel
                    has_up = adj_up(ch)~=0 && ~isempty(find(tv_allowed==adj_up(ch),1));
                    has_down = adj_down(ch)~=0 && ~isempty(find(tv_allowed==adj_down(ch),1));

                    if (has_up && has_down)
                        % Has upper and lower neighbors
                        cap(ch,:,:) = cap_both{noise_idx}(ch,:,:);
                        continue;
                    end

                    if (has_up)
                        % Has upper neighbors only
                        cap(ch,:,:) = cap_up{noise_idx}(ch,:,:);
                        continue;
                    end

                    if (has_down)
                        % Has lower neighbors only
                        cap(ch,:,:) = cap_down{noise_idx}(ch,:,:);
                        continue;
                    end

                    % If we've reached this point, we have no neighbors
                    cap(ch,:,:) = cap_none{noise_idx}(ch,:,:);

                end

            end

            % We are not allowed to transmit on channels 3 and 4, so we set their
            % capacity to zero
            cap(get_channel_index(3),:,:) = 0;
            cap(get_channel_index(4),:,:) = 0;

            
            
            % CR values
            [total_cap] = aggregate_bands(cap);
            [cdfX cdfY avg_cr(c) med_cr(c)] = calculate_cdf_from_map(total_cap, population, is_in_us);
            
            % TV user values
            num_tv_chans = squeeze(sum(tv_user_mask,1));
            [cdfX cdfY avg_tv(c) med_tv(c)] = calculate_cdf_from_map(num_tv_chans, population, is_in_us);
        end
        
        % Final variables to save
        average.cr = avg_cr;
        average.tv = avg_tv;
        median.cr = med_cr;
        median.tv = med_tv;        
        extras.order = order;
        
        
        % FADE MARGIN
    case 'fade_margin',
        
        % Ignore wireless mic exclusions (warning: does not cover the
        % cochannel-only case)
        ignore_wireless_mic_exclusions = 1;
        mask_type = ccdf_points_label.mask_type;
        
        switch(mask_type)
            case 'fade_margin',
                
                fade_margins = get_simulation_value('fade_margins');
                average.cr = zeros(size(fade_margins));
                median.cr = zeros(size(fade_margins));
                average.tv = zeros(size(fade_margins));
                median.tv = zeros(size(fade_margins));
                
                % For each fade margin
                for i = 1:length(fade_margins);
                    % CR version
                    fm_label = generate_label('fm_mask', mask_device_type, map_size, fade_margins(i), char_label);
                    capacity_total = get_total_capacity(capacity_label, fm_label, ignore_wireless_mic_exclusions);
                    
                    [~, ~, average.cr(i), median.cr(i)] = calculate_cdf_from_map(capacity_total, ...
                        population, is_in_us);
                    
                    % TV version
                    fm_tv_label = generate_label('fm_mask', tv_device_type, map_size, fade_margins(i), char_label);
                    [tv_users] = load_by_label(fm_tv_label);
                    
                    [~, ~, average.tv(i), median.tv(i)] = ...
                        calculate_cdf_from_map(squeeze(sum(tv_users,1)), ...
                            population, is_in_us);

                    
                end
                
                extras.content = 'none';
                
                
            case 'fm-cochan',
                
                cap = load_by_label(capacity_label);
                
                fade_margins = get_simulation_value('fade_margins');
                average.cr = zeros(size(fade_margins));
                median.cr = zeros(size(fade_margins));
                average.tv = zeros(size(fade_margins));
                median.tv = zeros(size(fade_margins));
                
                % For each fade margin
                for i = 1:length(fade_margins);
                    % CR version
                    fm_label = generate_label('fm_mask', mask_device_type, map_size, fade_margins(i), char_label);
                    [~, mask_extras] = load_by_label(fm_label);
                    % Assumes no wireless mic exclusions
                    cochannel_only_mask = mask_extras.cochannel_mask;
                    
                    capacity_total = aggregate_bands(cap .* cochannel_only_mask);
                    
                    [~, ~, average.cr(i), median.cr(i)] = ...
                        calculate_cdf_from_map(capacity_total, ...
                            population, is_in_us);
                        
                    % TV version 
                    fm_tv_label = generate_label('fm_mask', tv_device_type, map_size, fade_margins(i), char_label);
                    [tv_users] = load_by_label(fm_tv_label);

                    [~, ~, average.tv(i), median.tv(i)] = ...
                        calculate_cdf_from_map(squeeze(sum(tv_users,1)), ...
                        population, is_in_us);

                end
                
                extras.content = 'none';
                
                
            case 'fcc',
                % CR version
                fcc_label = generate_label('fcc_mask', mask_device_type, map_size);
                capacity_total = get_total_capacity(capacity_label, fcc_label, ignore_wireless_mic_exclusions);
                
                [cdfX cdfY average.cr median.cr] = calculate_cdf_from_map(capacity_total, ...
                    population, is_in_us);
                
                
                % TV version
                fcc_tv_label = generate_label('fcc_mask', tv_device_type, map_size);
                [tv_users] = load_by_label(fcc_tv_label);
                
                [~, ~, average.tv, median.tv] = ...
                    calculate_cdf_from_map(squeeze(sum(tv_users,1)), ...
                        population, is_in_us);


                extras.cdfX = cdfX;
                extras.cdfY = cdfY;
                
                
            case 'none',
                capacity_total = get_total_capacity(capacity_label, 'none');
                
                [cdfX cdfY average median] = calculate_cdf_from_map(capacity_total, ...
                    population, is_in_us);
                
                extras.cdfX = cdfX;
                extras.cdfY = cdfY;

                
        end
        
end


save(save_filename(ccdf_points_label), 'average', 'median', 'extras', 'population_type');