function [noise] = make_noise(noise_label)
%   [noise] = make_noise(noise_label)

switch(noise_label.label_type)
    case 'noise',
    otherwise,
        error(['Unsupported mode: tried to run make_noise() with ' ...
            'label of type ' noise_label.label_type]);
end

% If we don't need to compute, exit now
if (get_compute_status(noise_label) == 0)
    return;
end

%% Parse input
cochannel = noise_label.cochannel;
map_size = noise_label.map_size;
full_channels = noise_label.channels;
[channels tower_data_year] = split_flag(full_channels);
leakage_type = noise_label.leakage_type;

% Load external data
chan_list = get_simulation_value('chan_list');
[is_in_us lat_coords long_coords] = get_us_map(map_size, 1);
TNP = get_simulation_value('TNP');



% Special case for channel 52 option
if (string_is(channels, '52'))
    noise = is_in_us * TNP;
    save_data(save_filename(noise_label), 'noise');
    return;
end




temp_noise_label = generate_label('noise', 'yes', noise_label.map_size, ...
    noise_label.channels, 'none');
temp_noise_filename = save_filename(temp_noise_label);
if (exist(temp_noise_filename, 'file') == 2)
    noise = load_by_label(temp_noise_label);
else
    %% Load external data
    
    dist = get_simulation_value('distances');
    height = get_simulation_value('heights');
    % Some values for reference
    min_dist = min(dist);
    max_dist = max(dist);
    min_haat = min(height) + 1e-8;
    max_haat = max(height);
    
    % Load the tower data
    [chan_data struct] = get_tower_data(tower_data_year);
    struct_to_vars; % "deal" the fieldnames of 'struct' to local variables
    
    %% Pre-allocate arrays
    
    % Create blank arrays (note: multiply by double so that result is double,
    % not logical).
    noise = get_us_map(map_size, length(chan_list))*TNP;    % baseline noise is thermal noise
    temp_noise_map = is_in_us*0.0;
    
    
    [longs_map lats_map] = meshgrid(long_coords, lat_coords);
    longs_vec = longs_map(:);
    lats_vec = lats_map(:);
    
    is_in_us_vec = is_in_us(:);
    
    %% Calculate noise levels
    
    for c = 1:length(chan_list)
        channel = chan_list(c);
        
        % Find the relevant transmitters
        tx_list = chan_data(chan_data(:,chan_no_idx) == channel, :);
        
        display(['Working on channel ' num2str(channel) ' (' num2str(length(tx_list)) ' transmitters on this channel)']);
        
        for t = 1:size(tx_list,1)
            if (mod(t,10) == 0)
                display(['Working on tower ' num2str(t) ' out of ' num2str(size(tx_list,1))]);
            end
            
            % Clear variables from last iteration
            clear tower temp_noise_vector
            
            % Gather the relevant information about the tower
            tower.power = get_erp_to_eirp(tx_list(t, erp_idx)) * 1e3;  % multiply by 1e3 to convert to W
            tower.lat = tx_list(t, lat_idx);
            tower.long = tx_list(t, long_idx);
            tower.haat = tx_list(t, haat_idx);
            tower.dist_th = tx_list(t, dist_th_idx);
            
            % Reshape the map into a vector to make it easier to deal with
            temp_noise_vector = temp_noise_map(:) * 0.0;
            
            % Calculate distance from this tower to all points on the map
            distances = latlong_to_km(tower.lat, tower.long, lats_vec, longs_vec);
            
            % Choose those points which are both in the US and within the
            % threshold distance. We have three ways to do this:
            %
            % Choose those within the pre-set threshold distance (preset =
            % after this point, they should be < 0.1*TNP). This goes very
            % quickly but will be slightly inaccurate.
            %         nearby_idcs = (distances <= tower.dist_th) & is_in_us_vec;
            % Choose all places within the US. This takes a long time and
            % won't be any more accurate than the next option.
            %         nearby_idcs = is_in_us_vec;
            % Choose all places closer than the maximum distance for our
            % pathloss model. Anything further than this would be assigned
            % 0 power anyway (see get_E()), so it's silly to feed it in and
            % chew up time.
            nearby_idcs = (distances < max_dist) & is_in_us_vec;
            
            if (all(nearby_idcs == 0)) % Nothing to update, so we can skip the rest
                continue;
            end

            % Select the distances for those points
            distances_sub = distances(nearby_idcs);
            
            % Calculate the noise power at each of these points
            temp_noises_sub = apply_path_loss(tower.power, channel, tower.haat, distances_sub);
            
            
            % Try to reproduce results of old file
            distances_sub_sub = distances_sub < min_dist;
            temp_noises_sub(distances_sub_sub) = tower.power;
            
            
            % Insert these points back into the noise vector
            temp_noise_vector(nearby_idcs) = temp_noises_sub;
            
            % Turn noise vector back into temp noise map
            temp_noise_map = reshape(temp_noise_vector, size(temp_noise_map));
            
            % Add the noise to the running total on this channel
            noise(c,:,:) = squeeze(noise(c,:,:)) + temp_noise_map;
        end
        
        %     save_data('noise_data_new', 'noise');
        %     return;
        
    end
    
    save_data(save_filename(temp_noise_label), 'noise');
    add_extended_info_to_file(save_filename(temp_noise_label), 'read_tower_data');
end



%% Cochannel noise
% Channel 52 code in here is left for posterity but it should never be
% called
switch(cochannel)
    % No cochannel noise
    case 'no',
        switch(channels)
            case 'tv',
                % TNP only but 49 channels
                cochannel_noise = get_us_map(map_size, size(noise,1))*TNP;
            case '52',
                % Thermal noise only (one channel)
                cochannel_noise = get_us_map(map_size, 1)*TNP;
                error('Did not expect to reach this code.');
        end
        
    % Regular cochannel noise
    case 'yes',
        switch(channels)
            case 'tv',
                % Load TV channel noise
                cochannel_noise = noise;
            case '52',
                % Load channel 52 noise (just TNP for now)
                cochannel_noise = get_us_map(map_size, 1)*TNP;
                error('Did not expect to reach this code.');
        end
    otherwise
        error(['Unknown cochannel noise type: ' cochannel]);
end


%% Add in cross-channel noise
dB_leak = get_simulation_value('dB_leak');   % This is how much each channel leaks (in dB) into its adjacent channels
leak = 1/(10^(dB_leak/10)); % We will multiply the adjacent channel noise by this number

adj_channel_noise = zeros(size(cochannel_noise));

% Channel 52 has no adjacent channels (for our purposes) - deal only with
% the TV case (particularly where leakage_type ~= 'none'

% Add upper leakage
if (strcmp(leakage_type, 'both') == 1 || strcmp(leakage_type, 'up') == 1)
    for i = 1:length(chan_list)
        if (~has_frequency_neighbor(i, 'up'))
            continue;
        end
        up_ch_idx = i+1;
        adj_channel_noise(i, :, :) = adj_channel_noise(i, :, :) + ...
            noise(up_ch_idx, :, :);   % Add noise from the upper neighbor
    end
end

% Add lower leakage
if (strcmp(leakage_type, 'both') == 1 || strcmp(leakage_type, 'down') == 1)
    for i = 1:length(chan_list)
        if (~has_frequency_neighbor(i, 'down'))
            continue;
        end
        dn_ch_idx = i-1;
        adj_channel_noise(i, :, :) = adj_channel_noise(i, :, :) + ...
            noise(dn_ch_idx, :, :);   % Add noise from the lower neighbor
    end
end
    
% The variable 'noise' will change values/meanings in the following line so
% clearing it first makes this process more obvious
clear noise
noise = cochannel_noise + adj_channel_noise*leak;
save_data(save_filename(noise_label), 'noise');
add_extended_info_to_file(save_filename(noise_label), 'read_tower_data');
end
