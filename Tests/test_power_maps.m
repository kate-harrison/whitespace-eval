%% Test power maps
% Actually, testing make_jam.m\make_jam_maps()



%% Test power selection across the US
clc; clear all; close all;

p = 2000;
char_label = generate_label('char', 30, 0);
jam_label = generate_label('jam', p, 'real', char_label);

filename = ['jam_chan_data (' generate_filename(jam_label.char_label) ').mat'];
load(filename);

old_powers(:, end-15:end) = [];
new_powers(:, end-15:end) = [];
r_arrays(:, end-15:end) = [];


char_label.power = 4;

% [new_power_map old_power_map flat_power_map1 flat_power_map2 beta_map] = ...
%     make_jam_maps(chan_data, chan_data_indices, betas, r_arrays, new_powers, old_powers);
% function [new_power_map old_power_map flat_power_map1 flat_power_map2 beta_map] = make_jam_maps(chan_data, chan_data_indices, betas, r_arrays, new_powers, old_powers)

display('Making jam level maps...');

chan_list = get_simulation_value('chan_list');
[is_in_us lat_coords long_coords] = get_us_map('200x300', 1);
fm_label = generate_label('fm_mask', 'cr', '200x300', 3, char_label);
default_mask = load_by_label(fm_label);


% chan_no_idx = 1;    % channel number (TV channel number) - 2:69
% asrn_idx    = 3;    % forget for now - multiple transmitters on one tower
% fac_id_idx  = 2;    % forget also
% lat_idx     = 4;    % latitude
% long_idx    = 5;    % longitude
% haat_idx    = 6;    % HAAT
% amsl_idx    = 7;    % average ___ ___ ___
% erp_idx     = 8;    % radiated power - kilowatts
% pop_density_idx = 9;    % population density near this TV tower
% rp_18dB_clean_idx = 10;  % radius at which TV SNR is 18dB in a clean channel
chan_no_idx = chan_data_indices.chan_no_idx;
lat_idx = chan_data_indices.lat_idx;
long_idx = chan_data_indices.long_idx;



beta_map = default_mask * 2;
max_distances = max(r_arrays, [], 2); % same as r_arrays(:, end)

new_power_map = default_mask * 1;
old_power_map = default_mask * 1;
flat_power_map1 = default_mask * 1;
flat_power_map2 = default_mask * 1;
tower_map = default_mask * 1;
tower_map2_new = default_mask * 1;
tower_map2_old = default_mask * 1;


for i = 1:length(chan_list)
%     for i = get_channel_index(21)

    % Can't actually skip these because it will kill our power in future
    % channels
%     if (i == get_channel_index(3) || i == get_channel_index(4))
%         continue;   % Skip these channels as we can't transmit there anyway
%     end
    


    display(['Current channel: ' num2str(chan_list(i))]);
    
    % Select only those transmitters on the current channel
    tx_indices = chan_data(:, chan_no_idx) == chan_list(i);
    tx_list = chan_data(tx_indices, :);
    beta_list = betas(tx_indices);
    max_dist_list = max_distances(tx_indices);
    new_power_list = new_powers(tx_indices, :);
    old_power_list = old_powers(tx_indices, :);
    r_list = r_arrays(tx_indices, :);

    
    
    % For each point in the US...
    for j = 1:length(lat_coords)
        for k = 1:length(long_coords)
%             if (is_in_us(j,k) == 0)
%                 continue;   % Skip points outside the US
%             end

            if (default_mask(i,j,k) == 0)
                continue;       % Skip points outside the US and points inside rp
            end
            
            
            % Check protection radii for this channel
            distance = latlong_to_km(tx_list(:, lat_idx), tx_list(:, long_idx), lat_coords(j), long_coords(k));
            
            [Y,I] = min(distance);
            beta_map(i,j,k) = beta_list(I);     % use the beta from the nearest tower
            
            
            % This is the old way which used the nearest ring as its power
            % -- this ring used to be at 14.4 so it made sense but it has
            % since moved so we need to find the ring nearest 14.4 instead
%             flat_power_map1(i,j,k) = new_power_list(I, 1);
            

            % TODO: FIX THIS HACK
            % Since we know that we are using 1km increments (start at 0.1
            % km), we can just take the 14th index
            flat_idx = 14;
            flat_power_map1(i,j,k) = new_power_list(I, flat_idx);
            
            
            % Fill in the background
            flat_power_map2(i,j,k) = flat_power_map1(i,j,k);
            
            n = find_closest(Y, r_list(I,:));
            new_power_map(i,j,k) = new_power_list(I, n);
            old_power_map(i,j,k) = old_power_list(I, n);

            
            
            % Figure out the max. power allowed when we are within range of
            % a tower
            sub_indices = distance <= max_dist_list;
            if ~isempty(sub_indices)
                flat_power_map2(i,j,k) = min(new_power_list(sub_indices, flat_idx));
                
                %                 sub_indices
                sub_distances = distance(sub_indices);
                sub_power_list = new_power_list(sub_indices, :);
                sub_old_power_list = old_power_list(sub_indices, :);    % new
                sub_r_list = r_list(sub_indices, :);
                power_allowed = inf;
                old_power_allowed = inf;    % new
                
                [blah tower_map(i,j,k)] = min(sub_distances);
                [blah tower_map2_new(i,j,k)] = min(sub_distances);
                [blah tower_map2_old(i,j,k)] = min(sub_distances);

                
                
                for m = 1:sum(sub_indices)
                    
                    pa = power_allowed;
                    opa = old_power_allowed;
                    
                    idx = find_closest(sub_distances(m), sub_r_list(m, :));
                    power_allowed = min(power_allowed, sub_power_list(m, idx));
                    old_power_allowed = min(old_power_allowed, sub_old_power_list(m, idx));
                    
                    if (pa ~= power_allowed)
                        tower_map2_new(i,j,k) = m;
                    end
                    
                    if (opa ~= old_power_allowed)
                        tower_map2_old(i,j,k) = m;
                    end
                end
                new_power_map(i,j,k) = power_allowed;
                old_power_map(i,j,k) = old_power_allowed;   % new
                %             else
                %                 power_map(i,j,k) = 0;
            end

        end
    end
    
    
    
%     map = squeeze(get_W_to_dBm(old_power_map(i,:,:)));
%     make_map(map, 'title', 'old power', 'save', 'off');
    
%     map = squeeze(get_W_to_dBm(new_power_map(i,:,:)));
%     make_map(map, 'title', 'new power', 'save', 'off');

    map = squeeze(get_W_to_dBm(flat_power_map1(i,:,:)));
    figure; imagesc(map); colorbar; axis xy; title('flat power 1');

    map = squeeze(get_W_to_dBm(flat_power_map2(i,:,:)));
    figure; imagesc(map); colorbar; axis xy; title('flat power 2');

    
%     map = squeeze((tower_map(i,:,:)));
%     make_map(map, 'title', 'tower map', 'save', 'off');
%     
%     map = squeeze((tower_map2_new(i,:,:)));
%     make_map(map, 'title', 'tower map 2 new', 'save', 'off');
    
%     map = squeeze((tower_map2_old(i,:,:)));
%     make_map(map, 'title', 'tower map 2 old', 'save', 'off');



    return;
    
end


% end

