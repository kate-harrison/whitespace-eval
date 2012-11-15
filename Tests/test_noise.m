%% Test noise data
% Displays the TV noise power on each channel.

clc; clear all; close all;

% Noise-specific variables
cochannel = 'yes';
leakage = 'both';
channels = 'tv-2011';

% Other variables
map_size = '200x300';


% Load data
chan_list = get_simulation_value('chan_list');
noise_label = generate_label('noise', cochannel, map_size, channels, leakage);
noise = load_by_label(noise_label);


% Display data
figure;
for ch_idx = 1:length(chan_list)
    % ch_idx = 1;
    imagesc(squeeze(get_W_to_dBm(noise(ch_idx,:,:))));
    axis xy; colorbar; title(['Noise (dBm) on channel ' num2str(chan_list(ch_idx))]);
    pause;
end