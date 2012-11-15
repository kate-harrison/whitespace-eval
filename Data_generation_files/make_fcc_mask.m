function [] = make_fcc_mask(fcc_mask_label)
%   [] = make_fcc_mask(fcc_mask_label)
%
%   1 = CR can transmit; 0 = CR cannot transmit
%   1 = TV received; 0 = TV not received

% If we don't need to compute, exit now
if (get_compute_status(fcc_mask_label) == 0)
    return;
end

[device_type tower_data_year] = split_flag(fcc_mask_label.device_type);

map_size = fcc_mask_label.map_size;

[is_in_us lat_coords long_coords] = get_us_map(map_size, 1);
chan_list = get_simulation_value('chan_list');
TNP = get_simulation_value('TNP');
dB_leak = get_simulation_value('dB_leak');   % This is how much each channel leaks (in dB) into its adjacent channels
leak = 1/(10^(dB_leak/10)); % We will multiply the adjacent channel noise by this number



% Load the tower data
switch(tower_data_year)
    case '2011',
        load('Population_and_tower_data/Tower/2011/chan_data2011.mat');
        % Variables within
        %   chan_data	<8705x7 double>
        % 	chan_no_idx	1
        % 	lat_idx	2
        % 	long_idx	3
        % 	haat_idx	4
        % 	erp_idx	5
        % 	dist_th_idx	6
        % 	fcc_rp_idx	7
%     case '2008',
%         load 'chan_data_extra.mat'
%         % Variables within
%         % 	amsl_idx	7
%         % 	asrn_idx	3
%         % 	chan_data	<8071x10 double>
%         % 	chan_no_idx	1
%         % 	dist_th_idx	9
%         % 	erp_idx	8           % kw
%         % 	fac_id_idx	2
%         % 	fcc_rp_idx	10
%         % 	haat_idx	6       % m
%         % 	lat_idx	4
%         % 	long_idx	5
    otherwise,
        error('Bad tower data year');
end


default_mask = get_us_map(map_size, length(chan_list));


switch(device_type)
    % COGNITIVE RADIO
    case {'cr', 'cr_portable'},
        % How far beyond the FCC protection radius we'll extend our protection
        switch(device_type)
            case 'cr',            % fixed
                r_co_ext = 14.4;    % km
                r_adj_ext = 0.74;   % km
                
                start_channel_idx = get_channel_index(2);
%             case 'cr_portable',   % portable
%                 r_co_ext = 6;       % km
%                 r_adj_ext = 0.1;    % km
%                 
%                 % Portable devices can't operate on channels 2-20
%                 start_channel_idx = get_channel_index(21);
%                 default_mask(1:start_channel_idx - 1,:,:) = 0;
            otherwise,
                error(['Unrecognized device type: ' device_type]);
        end
        
        
        % Create a "blank" array, one layer for each channel
        %         fcc_exclusion_mask = default_mask;
        cochannel_mask = default_mask;
        adjacent_channel_mask = default_mask;
        
        % For each channel
        for i = start_channel_idx:length(chan_list)
            display(['Current channel: ' num2str(chan_list(i))]);
            
            
            
            tx_list = chan_data(chan_data(:, chan_no_idx) == chan_list(i),:);   % Select only those transmitters on the current channel
            
            % Do we have adjacent channels?
            up = has_frequency_neighbor(i, 'up');
            down = has_frequency_neighbor(i, 'down');

            if (up)
                tx_list_up = chan_data(chan_data(:, chan_no_idx) == chan_list(i+1),:);
                display(['     Adjacent channel: ' num2str(chan_list(i+1))]);
            end
            if(down)
                tx_list_down = chan_data(chan_data(:, chan_no_idx) == chan_list(i-1),:);
                display(['     Adjacent channel: ' num2str(chan_list(i-1))]);
            end
            
            
            % For each point in the US...
            for j = 1:length(lat_coords)
                %display(['Current latitude index: ' num2str(j) ' of ' num2str(length(lat_coords))]);
                for k = 1:length(long_coords)
                    
                    % Skip if outside the US
                    if (~is_in_us(j,k))
                        continue;
                    end
                    
                    % Check protection radii for this channel
                    distance = latlong_to_km(tx_list(:, lat_idx), tx_list(:, long_idx), lat_coords(j), long_coords(k));
                    distance = distance - tx_list(:, fcc_rp_idx)-r_co_ext;  % Add 14.4 km to each protection radius
                    if (~isempty(distance(distance < 0)))     % If there are any negative entries, we must be within the protection radius for some tower
                        cochannel_mask(i,j,k) = 0;
                    end
                    
                    % Check protection radii for adjacent channels
                    % Check lower adjacent channel
                    if (down)
                        distance = latlong_to_km(tx_list_down(:, lat_idx), tx_list_down(:, long_idx), lat_coords(j), long_coords(k));
                        distance = distance - tx_list_down(:, fcc_rp_idx)-r_adj_ext;  % Add 0.74 km to each protection radius
                        if (~isempty(distance(distance < 0)))     % If there are any negative entries, we must be within the protection radius for some tower
                            adjacent_channel_mask(i,j,k) = 0;
                        end
                    end
                    
                    % Check the upper adjacent channel
                    if (up)
                        distance = latlong_to_km(tx_list_up(:, lat_idx), tx_list_up(:, long_idx), lat_coords(j), long_coords(k));
                        distance = distance - tx_list_up(:, fcc_rp_idx)-r_adj_ext;  % Add 0.74 km to each protection radius
                        if (~isempty(distance(distance < 0)))     % If there are any negative entries, we must be within the protection radius for some tower
                            adjacent_channel_mask(i,j,k) = 0;
                        end
                    end
                    
                    
                    
                end
            end
            
            % Reality check
            %figure; imagesc(squeeze(fcc_exclusion_mask(i,:,:))); title(['Noise on channel ' num2str(chan_list(i))]);
        end
        
        
%         [cochannel_mask extras.wireless_mic_channels] = take_out_wireless_mic_channels(cochannel_mask);
        
        mask = cochannel_mask & adjacent_channel_mask;
        extras.cochannel_mask = cochannel_mask;
        extras.adjacent_channel_mask = adjacent_channel_mask;
        
        
    % TELEVISION
    case 'tv',
        
        
        % Create a "blank" array, one layer for each channel
        fcc_tv_user_mask = default_mask*0;
        
        
        % For each channel
        for i = 1:length(chan_list)
            display(['Current channel: ' num2str(chan_list(i))]);
                        
            
            tx_list = chan_data(chan_data(:, chan_no_idx) == chan_list(i),:);   % Select only those transmitters on the current channel
            
            
            
            % For each point in the US...
            for j = 1:length(lat_coords)
                %display(['Current latitude index: ' num2str(j) ' of ' num2str(length(lat_coords))]);
                for k = 1:length(long_coords)
                    if (is_in_us(j,k) == 0)
                        continue;   % Skip points outside the US
                    end
                    
                    
                    % Check protection radii for this channel
                    distance = latlong_to_km(tx_list(:, lat_idx), tx_list(:, long_idx), lat_coords(j), long_coords(k));
                    distance = distance - tx_list(:, fcc_rp_idx);
                    if (~isempty(distance(distance < 0)))     % If there are any negative entries, we must be within the protection radius for some tower
                        fcc_tv_user_mask(i,j,k) = 1;
                    end
                    
                    
                end
            end
            
            % Reality check
            %     figure; imagesc(squeeze(fcc_tv_user_mask(i,:,:))); title(['TV on channel ' num2str(chan_list(i))]); axis xy; colorbar;
            
        end
        
        mask = fcc_tv_user_mask;
        extras.contents = 'none';
        
    otherwise,
        error(['Unrecognized device type: ' device_type]);

end



save(save_filename(fcc_mask_label), 'mask', 'extras');

end
