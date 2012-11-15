function [] = make_mac_table(mac_table_label)
%   [] = make_mac_table(mac_table_label)


% If we don't need to compute, exit now
if (get_compute_status(mac_table_label) == 0)
    return;
end

channels = mac_table_label.channels;
char_label = mac_table_label.char_label;


num_tx = [6 12 18 24];    % 6 TX at dist. r, 12 at dist. 2*r, etc.
radii = [0.05:0.05:29 30:1:49 50:5:240];  % km
% [tx_haat tx_power] = load_char_by_label(char_label);
[tx_haat tx_power] = load_by_label(char_label);

switch(channels)
    case 'tv',
        chan_list = get_simulation_value('chan_list');
    case '52',
        chan_list = 52;
    otherwise,
        error(['Unknown channl type: ' channels]);
end
    
% Rows are the radius, columns are the channels
% radius_idx = 1; chan_idx = 2;
noise = zeros(length(radii), length(chan_list));

for circles = 1:4   % From 1 to 4 concentric circles
    
%     display(['Using ' num2str(circles) ' concentric circles.']);
    for ch = 1:length(chan_list)
%         display(['Working on channel ' num2str(chan_list(ch))]);
            % Each time we layer on the noise added by the next concentric
            % circle
            noise(:, ch) = noise(:, ch) + ...
                num_tx(circles)*apply_path_loss(tx_power, chan_list(ch), tx_haat, circles*radii);
    end
    
end


interference = noise;
mac_radii = radii;

save(save_filename(mac_table_label), 'interference', 'mac_radii');

