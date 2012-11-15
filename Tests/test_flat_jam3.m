

clc; clear all; close all;
power = 0;
height = 30;
char_label = generate_label('char', height, power);
is_in_us = get_us_map('200x300', 1);

model_number = [1]

p = 2000;

jam_label = generate_label('jam', p, 'real', char_label, model_number)
% make_jam(jam_label);

bpsHz = 0.5;

power_type = 'flat3'; 

    power_filename = get_jam_filename('power_map', jam_label, bpsHz)
    file = load(power_filename);



TNP = get_simulation_value('TNP');
    W = get_simulation_value('bandwidth');
    [is_in_us lat_coords long_coords] = get_us_map('200x300', 1);
    chan_list = get_simulation_value('chan_list');
    population_density = get_pop_density('200x300', 'real', 1);
    noise_map = load_by_label(generate_label('noise', 'yes', '200x300', 'tv', 'both'));
    
power_map = file.flat_power_map1;

% Hacky flat jam
            for i = 1:length(chan_list)
                layer = power_map(i,:,:);
                layer(layer == 0) = 0/0;
                layer_min = nanmin(nanmin(layer));
                get_W_to_dBm(layer_min)
                
                power_map(i,:,:) = is_in_us * layer_min;
                
                
            end