function [] = make_tv_signal(tv_signal_label)
%   [] = make_tv_signal(tv_signal_label)
%
% Find the magnitude of the strongest TV signal at points across the US
%
% We wish to find the strength of the strongest TV signal at each location
% in the US (on each channel). To do this, we will use the following
% algorithm:
%
% * Find the distance-to-level-set for each tower for "enough" level sets
% * At each location, find n, the number of towers in the "strongest" level
% set
% * - If n = 0, try the second-strongest and so on until n > 0
% * - Compute the signal strengths for all of the towers in this set and
% keep the maximum
%
% Assumptions:
%
% * Noise = TNP
% * Cut out towers not on the current channel

map_size = tv_signal_label.map_size;
tower_data_year = tv_signal_label.tower_data_year;

[chan_data struct] = get_tower_data(tower_data_year);
struct_to_vars;

chan_list = get_simulation_value('chan_list');
TNP = get_simulation_value('TNP');

[is_in_us lat_coords long_coords] = get_us_map(map_size, 1);
maxiumum_signal_strength = zeros([length(chan_list) size(is_in_us, 1) size(is_in_us, 2)]);

for c = 1:length(chan_list)
    channel = chan_list(c);
    display(['Working on channel ' num2str(channel)]);
    clear level_sets tv towers map; % prevent crosstalk between iterations
    
    sub_idcs = chan_data(:, chan_no_idx) == channel;
    sub_chan_data = chan_data;
    sub_chan_data(~sub_idcs, :) = [];
    
    level_sets.SNR = [100 50 15 10 5 0 -5 -10 -15];    % in dB
    % SNR = 10*log10(signals ./ noise);
    level_sets.signals = 10.^(level_sets.SNR/10)*TNP;  % in W
    
    %% Make the distances-to-level-sets
    num_towers = size(chan_data,1);
    
    % The last entry for each tower will be infinity so that we can always
    % choose to capture all towers
    level_sets.towers = ones(num_towers, length(level_sets.SNR)+1) * inf;
    
    
    for i = 1:num_towers
        tv.channel = chan_data(i, chan_no_idx);
        tv.power = chan_data(i, erp_idx) * 1e3; % in W
        tv.haat = chan_data(i, haat_idx);   % in m
        
        level_sets.towers(i,1:end-1) = get_effective_radius(tv.power, tv.channel, tv.haat, level_sets.signals);
    end
    
    towers.lats = chan_data(:, lat_idx);
    towers.longs = chan_data(:, long_idx);
    towers.powers = chan_data(:, erp_idx)*1e3;
    towers.haats = chan_data(:, haat_idx);
    
    %% Find the signal strengths
    
    map.signals = is_in_us * 0;
    map.num_towers = is_in_us * 0;
    map.level_set = is_in_us * 0;
    
    for i = 1:length(lat_coords)
        if mod(i, 10) == 0
            display(['  Working on lat coord ' num2str(i) ' out of ' ...
                num2str(length(lat_coords))]);
        end
        
        for j = 1:length(long_coords)
            if (~is_in_us(i,j)) % Skip the point if not in the US
                continue;
            end
            
            dist_to_towers = latlong_to_km(lat_coords(i), long_coords(j), towers.lats, towers.longs);
            
            for l = 1:length(level_sets.signals)+1
                if any(dist_to_towers < level_sets.towers(:, l))
                    % We found at least one tower
                    
                    map.level_set(i,j) = level_sets.SNR(l);
                    
                    idcs = dist_to_towers < level_sets.towers(:, l);
                    map.num_towers(i,j) = sum(idcs);
                    
                    sub_towers.powers = towers.powers(idcs);
                    sub_towers.haats = towers.haats(idcs);
                    sub_towers.dists = dist_to_towers(idcs);
                    
                    sub_towers.signals = zeros(1, num_towers);
                    for t = 1:map.num_towers(i,j)
                        sub_towers.signals(t) = apply_path_loss(sub_towers.powers(t), ...
                            channel, sub_towers.haats(t), sub_towers.dists(t));
                    end
                    
                    map.signals(i,j) = max(sub_towers.signals);
                    break;  % No need to look further
                else
                    continue;
                end
            end
        end
    end
    
    maxiumum_signal_strength(c,:,:) = map.signals;
end

save_data(save_filename(tv_signal_label), 'maxiumum_signal_strength');
