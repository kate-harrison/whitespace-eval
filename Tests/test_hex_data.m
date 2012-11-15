%% Test hex data
clc; clear all; close all;


power = 10;
height = 30;
char_label = generate_label('char', height, power);
hex_label = generate_label('hex', char_label);
[area_array signals noises] = load_by_label(hex_label);

figure; imagesc((squeeze(sum(signals(:,:,:),1))));
figure; imagesc((squeeze(sum(noises(:,:,:),1))));
