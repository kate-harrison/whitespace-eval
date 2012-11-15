%% Test MAC capacity

clc; clear all; close all;

% MAC-capacity-specific variables
channels = 'tv-2011';
population_type = 'real-2010';

range_type = 'r';
range_value = 1;


% Other variables
map_size = '200x300';
cr_haat = 30;
cr_power = 4;




% Load data
chan_list = get_simulation_value('chan_list');

char_label = generate_label('char', cr_haat, cr_power);
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
mac_label = generate_label('mac_table', channels, char_label);
capacity_label = generate_label('capacity', 'per_area', range_type, ...
    range_value, population_type, char_label, noise_label, mac_label);

[capacity extras] = load_by_label(capacity_label);

ch_idx = 1;


% Display data
figure; imagesc(squeeze(extras.mac_radius(ch_idx,:,:)));
axis xy; colorbar; title(['MAC radius (km) on channel ' num2str(chan_list(ch_idx))]);

figure; imagesc(squeeze(capacity(ch_idx,:,:)));
axis xy; colorbar; title(['Capacity on channel ' num2str(chan_list(ch_idx))]);


figure; imagesc(aggregate_bands(capacity));
axis xy; colorbar; title('Total capacity');