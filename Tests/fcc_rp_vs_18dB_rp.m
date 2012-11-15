%% Plot the FCC rp vs. the 18dB rp

clc; clear all; close all;

fcc_label = generate_label('fcc_mask', 'cr', '200x300');
fcc_mask = load_by_label(fcc_label);

file = load('jam_exclusion map.mat');
rp_18dB_mask = file.excl_mask;


fcc_extra = fcc_mask - rp_18dB_mask;
rp_18dB_extra = rp_18dB_mask - fcc_mask;

fcc_extra = max(0, fcc_extra);
rp_18dB_extra = max(0, rp_18dB_extra);

map_fcc_extra = squeeze(sum(fcc_extra, 1));
map_18dB_extra = squeeze(sum(rp_18dB_extra, 1));

is_in_us = get_us_map('200x300', 1);
map_fcc_extra(~is_in_us) = inf;
map_18dB_extra(~is_in_us) = inf;

make_map(map_fcc_extra, 'map_type', 'linear', 'title', 'Places where FCC covers but 18dB does not', ...
    'colorbar_title', '# channels', 'save', 'on', 'integer_labels', 'on');

make_map(map_18dB_extra, 'map_type', 'linear', 'title', 'Places where 18dB covers but FCC does not', ...
    'colorbar_title', '# channels', 'save', 'on', 'integer_labels', 'on');