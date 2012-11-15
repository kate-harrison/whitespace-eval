%% Capacity per person for different CR characteristics

clc; clear all; close all;

p = 2000
cap_type = 'per_person'
range_type = 'p'
pop_type = 'real'
map_size = get_simulation_value('map_size');
is_in_us = get_us_map(map_size, 1);
noise_label = generate_label('noise', 'yes', map_size, 'tv', 'both')

fcc_label = generate_label('fcc_mask', 'cr', map_size)
fcc_mask = load_by_label(fcc_label);

display('-------------------------------');
for i = 1:4
    switch(i)
        case 1, char_label = generate_label('char', 10.1, 100e-3)
        case 2, char_label = generate_label('char', 10.1, 40e-3)
        case 3, char_label = generate_label('char', 30, 4)
        case 4, char_label = generate_label('char', 30, 400)
    end
    
    hex_label = generate_label('hex', char_label);
    
    capacity_label = generate_label('capacity', cap_type, range_type, p, ...
        pop_type, char_label, noise_label, hex_label);
    
    capacity = load_by_label(capacity_label);
    capacity = squeeze(sum(apply_exclusions_to_capacity(capacity, fcc_mask),1));
    

    capacity(~is_in_us) = inf;
    
%     make_quick_map(capacity/1e3, 'kbps');
    make_map(capacity/1e3, 'save', 'on', ...
        'colorbar_title', ' kbps', 'map_type', 'log', ...
        'filename', generate_filename(capacity_label));
    
end


%% Economics: how does capacity change with the number of people per tower?

clc; clear all; close all;

p = [125 250 500 1000 2000 4000 8000 16000];
char_label = generate_label('char', 30, 4);
hex_label = generate_label('hex', char_label);
range_type = 'p'
pop_type = 'real'
map_size = get_simulation_value('map_size');
is_in_us = get_us_map(map_size, 1);
pop_map = get_population(map_size, pop_type, 1);
noise_label = generate_label('noise', 'yes', map_size, 'tv', 'both')

fcc_label = generate_label('fcc_mask', 'cr', map_size)
fcc_mask = load_by_label(fcc_label);

display('-------------------------------');

cap_per_area_avg = zeros(size(p));
cap_per_area_med = zeros(size(p));
cap_per_person_avg = zeros(size(p));
cap_per_person_med = zeros(size(p));
raw_cap_avg = zeros(size(p));
raw_cap_med = zeros(size(p));

for i = 1:length(p)
    for j = 1:3
        switch(j)
            case 1, cap_type = 'per_area';
            case 2, cap_type = 'per_person';
            case 3, cap_type = 'raw';
        end
    capacity_label = generate_label('capacity', cap_type, range_type, p(i), ...
        pop_type, char_label, noise_label, hex_label);
    
    capacity = load_by_label(capacity_label);
    capacity = squeeze(sum(apply_exclusions_to_capacity(capacity, fcc_mask),1));
    
    [cdfX cdfY avg med] = ...
        calculate_cdf_from_map(capacity, pop_map, is_in_us);
    
    switch(j)
        case 1,
            cap_per_area_avg(i) = avg;
            cap_per_area_med(i) = med;
        case 2,
            cap_per_person_avg(i) = avg;
            cap_per_person_med(i) = med;
        case 3,
            raw_cap_avg(i) = avg;
            raw_cap_med(i) = med;
    end
    
    end
end
%%

close all;
figure; set(gcf, 'outerposition', [440   175   567   676]);
scale = 1e6;
label = 'Mbps';


subplot(3,1,1);
loglog(p, cap_per_area_avg/scale, 'b*-');
hold on; grid on;
loglog(p, cap_per_area_med/scale, 'r*-');
title('Capacity per area as a function of people per tower');
% xlabel('People per tower');
ylabel(label);
axis tight;
a = axis;


subplot(3,1,3);
loglog(p, raw_cap_avg/scale, 'b*-');
hold on; grid on;
loglog(p, raw_cap_med/scale, 'r*-');
title('Raw capacity as a function of people per tower');
xlabel('People per tower');
ylabel(label);
s = 5;
axis([a(1:2) min(raw_cap_med/scale)-s max(raw_cap_avg/scale)+s]);




scale = 1e3;
label = 'kbps';

subplot(3,1,2);
loglog(p, cap_per_person_avg/scale, 'b*-');
hold on; grid on;
loglog(p, cap_per_person_med/scale, 'r*-');
title('Capacity per person as a function of people per tower');
% xlabel('People per tower');
ylabel(label);
axis tight;
% a = axis;

legend('Average', 'Median', 'location', 'southwest');

print('-djpeg', 'Output/hex model - effect of people per tower.jpeg');


% save_plot('jpeg', 'hex model - effect of people per tower');
