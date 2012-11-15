clc; clear all; close all;

power = 0;
p = 2000;
height = 30;
char_label = generate_label('char', height, power);

jam_label = generate_label('jam', p, 'real', char_label);


filename = ['jam_chan_data (' generate_filename(jam_label.char_label) ').mat'];
load(filename);


figure; imagesc(new_powers);

% any(new_powers(1,:) > 0)

for i = 1:10
sum(new_powers(:,i) > 0)
end