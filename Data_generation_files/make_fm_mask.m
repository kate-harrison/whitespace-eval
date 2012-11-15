function [] = make_fm_mask(fm_mask_label)
%   [] = make_fm_mask(fm_mask_label)
%
%   Actually makes CR and TV masks at the same time (more efficient/less overhead)
% Make masks for various fading margins (1 = CR can transmit; 0 = CR may
% not transmit)
% 1 = can receive TV, 0 = cannot receive TV
% Execution time: approx. 5 min per margin


if (get_compute_status(fm_mask_label)==0)
    return;
end

[~, tower_data_year] = split_flag(fm_mask_label.device_type);


% device_type = fm_mask_label.device_type;
map_size = fm_mask_label.map_size;
m = fm_mask_label.margin_value;
char_label = fm_mask_label.char_label;
tx_haat = char_label.height;
tx_power = char_label.power;

[is_in_us lat_coords long_coords] = get_us_map(map_size, 1);
chan_list = get_simulation_value('chan_list');
TNP = get_simulation_value('TNP');
dB_leak = get_simulation_value('dB_leak');   % This is how much each channel leaks (in dB) into its adjacent channels
leak = 1/(10^(dB_leak/10)); % We will multiply the adjacent channel noise by this number


% Load the tower data
[chan_data chan_data_idcs] = load_chan_data(tower_data_year);
chan_no_idx = chan_data_idcs.chan_no_idx;
lat_idx = chan_data_idcs.lat_idx;
long_idx = chan_data_idcs.long_idx;
haat_idx = chan_data_idcs.haat_idx;
erp_idx = chan_data_idcs.erp_idx;
ad_idx = chan_data_idcs.ad_idx;

default_mask = get_us_map(map_size, length(chan_list));

cr_coch_mask = default_mask;
cr_adjc_mask = default_mask;
tv_user_mask = default_mask;
% 
% % NOTE: Mostly copied code below this point (not refactored)
% 
% Find the protection radius for each transmitter with this fade margin
% Find rn-rp (rn_minus_rp) for each transmitter with this fade margin
% Inside the rp, TV can be received
% At (rn_minus_rp + rp) cochannel transmitters cannot operate
num_tx = length(chan_data);
% prot_radii = chan_data(:, fcc_rp_idx);
prot_radii = zeros(num_tx, 1);
%     rn_minus_rp = zeros(num_tx);
for t = 1:num_tx
    % Note that ERP comes in kW and the function accepts ERP in W
    
    prot_radii(t) = get_AD_protection_radius(chan_data(t, erp_idx)*1e3, chan_data(t, chan_no_idx), chan_data(t, haat_idx), chan_data(t, ad_idx), m, TNP);
    
    % Old function -- not updated for analog vs. digital towers
%     prot_radii(t) = get_protection_radius(chan_data(t, erp_idx)*1e3, chan_data(t, chan_no_idx), chan_data(t, haat_idx), m, TNP);
end

extras.fm_protection_radii = prot_radii;


% For each channel...
for i = 1:length(chan_list)
    display(['   Current channel: ' num2str(chan_list(i))]);
    
    % Find rn_minus_rp for cochannel situations
    rn_minus_rp = get_rn_minus_rp(tx_power/1e3, chan_list(i), tx_haat, m, TNP);
    
    tx_indices = chan_data(:, chan_no_idx) == chan_list(i);
    tx_list = chan_data(tx_indices,:);   % Select only those transmitters on the current channel
    rp_list = prot_radii(tx_indices);    % Grab their corresponding protection radii
    %         rn_list = rn_minus_rp(tx_indices);   % ...and the corresponding rn_minus_rp
    
    
    % Do we have adjacent channels?
    %         up = (i < length(chan_list)) && (abs(get_freq(chan_list(i+1)) - get_freq(chan_list(i))) == 6);
    %         down = (i > 1) && (abs(get_freq(chan_list(i-1)) - get_freq(chan_list(i))) == 6);
    up = has_frequency_neighbor(i, 'up');
    down = has_frequency_neighbor(i, 'down');
    
    if (up)
        tx_indices_up = chan_data(:, chan_no_idx) == chan_list(i+1);
        tx_list_up = chan_data(tx_indices_up,:);
        rp_list_up = prot_radii(tx_indices_up);
        rn_minus_rp_up = get_rn_minus_rp(tx_power*leak/1e3, chan_list(i+1), tx_haat, m, TNP);
        %             display(['     Adjacent channel: ' num2str(chan_list(i+1))]);
    end
    if(down)
        tx_indices_down = chan_data(:, chan_no_idx) == chan_list(i-1);
        tx_list_down = chan_data(tx_indices_down,:);
        rp_list_down = prot_radii(tx_indices_down);
        rn_minus_rp_down = get_rn_minus_rp(tx_power*leak/1e3, chan_list(i-1), tx_haat, m, TNP);
        %             display(['     Adjacent channel: ' num2str(chan_list(i-1))]);
    end
    
    
    % For each point in the US...
    for j = 1:length(lat_coords)
        %display(['Current latitude index: ' num2str(j) ' of ' num2str(length(lat_coords))]);
        for k = 1:length(long_coords)
            
            
            if (is_in_us(j,k) == 0) % If it's outside the US...
                continue;           % ... skip this point.
            end
            
            % Find distances to each transmitter on this channel, the
            % upper channel, and the lower channel (if they exist)
            distance = latlong_to_km(tx_list(:, lat_idx), tx_list(:, long_idx), lat_coords(j), long_coords(k));
            if(up); distance_up = latlong_to_km(tx_list_up(:, lat_idx), tx_list_up(:, long_idx), lat_coords(j), long_coords(k)); end;
            if(down); distance_down = latlong_to_km(tx_list_down(:, lat_idx), tx_list_down(:, long_idx), lat_coords(j), long_coords(k)); end;
            
            % Check to see if this point receives TV on the current
            % channel
            tv_distances = distance - rp_list;  % A nonpositive value indicates that rp >= distance -> can get TV
            if (isempty(tv_distances(tv_distances <= 0)))  % Cannot get TV (there are no nonpositive values)
                tv_user_mask(i,j,k) = 0;
            end
            
            % Check to see if this point is available for CRs based
            % purely on cochannel exclusions
            % Allowed radius = rn = rn_minus_rp + rp (cochannel rn-rp)
            % TODO: If we can receive TV, we definitely can't
            % transmit...
            
            cr_distances = distance - (rn_minus_rp + rp_list);  % Nonnegative values -> we are far enough away. Negative values -> we are too close to the tower to transmit.
            if (any(cr_distances(cr_distances < 0)))   % = we have some negative values = we are too close
                cr_coch_mask(i,j,k) = 0;
            end
            
            
            % Check to see if this point is available for CRs based
            % purly on adjacent channel exclusions
            % Allowed radius = rn = rn_minus_rp_adjc + rp
            if (up) % If we have an upper channel...
                cr_distances_up = distance_up - (rn_minus_rp_up + rp_list_up);          % Any negative values -> we are too close to transmit
            else    % If not, modify here to simplify upcoming code
                cr_distances_up = [];
            end
            
            if (down)   % If we have a lower channel...
                cr_distances_down = distance_down - (rn_minus_rp_down + rp_list_down);  % Any negative values -> we are too close to transmit
            else        % If not, modify here to simplify upcoming code
                cr_distances_down = [];
            end
            
            % Now look at what these distances are...
            if (any(cr_distances_up(cr_distances_up < 0)) || any(cr_distances_down(cr_distances_down < 0)))   % = we have some negative values = we are too close
                cr_adjc_mask(i,j,k) = 0;
            end
            
            
        end
    end
    
end





% Save CR version
cr_fm_label = fm_mask_label;
cr_fm_label.device_type = ['cr-' num2str(tower_data_year)];
% [cr_coch_mask extras.wireless_mic_channels] = take_out_wireless_mic_channels(cr_coch_mask);
mask = cr_coch_mask & cr_adjc_mask;
extras.adjacent_channel_mask = cr_adjc_mask;
extras.cochannel_mask = cr_coch_mask;
save(save_filename(cr_fm_label), 'mask', 'extras');




% Save TV version
tv_fm_label = fm_mask_label;
tv_fm_label.device_type = ['tv-' num2str(tower_data_year)];
tv_fm_label.char_label = 'none';
mask = tv_user_mask;
extras.contents = 'none';   % Make sure extras exists
save(save_filename(tv_fm_label), 'mask', 'extras');
end

