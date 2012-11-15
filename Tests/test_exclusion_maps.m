%% Test exclusion maps

%% FCC r_p vs 18dB r_p
clc; clear all; close all;

map_size = '200x300';
char_label = generate_label('char', 30, 4);
fcc_label = generate_label('fcc_mask', 'cr', '200x300');
fm_label = generate_label('fm_mask', 'cr', map_size, 3, char_label);

fcc_mask = load_by_label(fcc_label);
fm_mask = load_by_label(fm_label);

fcc_map = squeeze(sum(fcc_mask,1));
fm_map = squeeze(sum(fm_mask,1));

% make_quick_map(fcc_map, '# channels, FCC');
% make_quick_map(fm_map, '# channels, FM=3');

make_quick_map(abs(fcc_map - fm_map), '# diff. channels');