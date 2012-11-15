%% Test chan_data

clc; clear all; close all;


for model = [1 3]
    bpsHz = 0.5;
    p = 2000;
    power_type = 'none';
    char_label = generate_label('char', 30, 0);
    jam_label = generate_label('jam', 'chan_data', model, 'none', char_label, bpsHz, p)
    filename = generate_filename(jam_label);
    load(filename);
    
    
    figure; imagesc(get_W_to_dBm(old_powers)); colorbar;
    title('Old powers');
    xlabel('Radius index (ascending)');
    ylabel('Tower index');
    ca = caxis;
    
    
    figure; imagesc(get_W_to_dBm(new_powers)); colorbar;
    title('New powers');
    xlabel('Radius index (ascending)');
    ylabel('Tower index');
    caxis(ca);
    
    if (any(any(new_powers > old_powers)))
        warning('New power exceeds old power');
    end
    
    figure; plot(betas, '.');
    xlabel('Tower index');
    ylabel('\beta');
    
end
















return;
%% Old code

% %% Find the greatest distance between two towers
% % Conclusions:
% % * There is
% 
% clc; clear all; close all;
% chan_list = get_simulation_value('chan_list');
% load('chan_data_extra');
% 
% max_dist = zeros(size(chan_list));
% min_dist = zeros(size(chan_list));
% 
% for c = 1:length(chan_list)
%     
%     display(['Current channel: ' num2str(chan_list(c))]);
%     
%     % Select only those transmitters on the current channel
%     tx_indices = chan_data(:, chan_no_idx) == chan_list(c);
%     tx_list = chan_data(tx_indices, :);
%     
%     max_d = 0;
%     min_d = inf;
%     
%     for i = 1:length(tx_list)
%         for j = 1:length(tx_list)
%             if (i == j)
%                 continue;
%             end
%             
%             dist = latlong_to_km(tx_list(i,lat_idx), tx_list(i,long_idx), tx_list(j,lat_idx), tx_list(j,long_idx));
%             
%             min_d = min(dist, min_d);
%             max_d = max(dist, max_d);
%             
%         end
%     end
%     
%     max_dist(c) = max_d;
%     min_dist(c) = min_d;
% end
% 
% figure; plot(chan_list, max_dist, '.-');
% title('Maximum distance by channel');
% 
% figure; plot(chan_list, min_dist, '.-');
% title('Minimum distance by channel');