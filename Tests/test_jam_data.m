%% Test jam data

%% Test channel data
% Conclusions:
% * The powers aren't obviously wrong
% * No NaN powers or betas
clc; clear all; close all;

power = 0;
height = 30;
char_label = generate_label('char', height, power);
jam_label = generate_label('jam', 2000, 'real', char_label);
filename = ['jam_chan_data (' generate_filename(jam_label.char_label) ').mat'];
file = load(filename);


% Are there any NaNs inside?
for i = 1:4
    switch(i)
        case 1, vars = file.r_arrays;
        case 2, vars = file.new_powers;
        case 3, vars = file.old_powers;
        case 4, vars = file.betas;
    end
    
    if (any(any(isnan(vars))))
        i
    else
        display('ok');
    end
end


% Does it look reasonable?
figure; imagesc(get_W_to_dBm(file.old_powers(:,1:50))); colorbar; title('old powers');
figure; imagesc(get_W_to_dBm(file.new_powers(:,1:50))); colorbar; title('new powers');


%% Test power map data
% Conclusions:
% * Powers seem reasonable
% * We have nonzero powers inside of r_p (wtf?) but only in old_power
clc; clear all; close all;

channel = 21;
ch_idx = get_channel_index(channel);
p = 2000;
power = 0;
height = 30;
char_label = generate_label('char', height, power);
jam_label = generate_label('jam', p, 'real', char_label);
pop_d = get_pop_density('200x300', 'real', 1);

file = load(save_filename(jam_label));

% area/tower = people/tower / people/area
tower_areas = p ./ pop_d;


map = get_W_to_dBm(squeeze(file.old_power_map(ch_idx,:,:)) .* tower_areas);
map(155,55)
make_map(map, 'save', 'off', 'title', 'old power per wifi tower', 'colorbar_title', 'dBm'); % 'scale', 4

pause;
close all;


map = get_W_to_dBm(squeeze(file.new_power_map(ch_idx,:,:)).*tower_areas);
map(155,55)
make_map(map, 'save', 'off', 'title', 'new power per wifi tower', 'colorbar_title', 'dBm');

pause;
close all;

map = get_W_to_dBm(squeeze(file.flat_power_map1(ch_idx,:,:)).*tower_areas);
map(155,55)
make_map(map, 'save', 'off', 'title', 'flat power 1 per wifi tower', 'colorbar_title', 'dBm');

pause;
close all;

map = get_W_to_dBm(squeeze(file.flat_power_map1(ch_idx,:,:)).*tower_areas);
map(155,55)
make_map(map, 'save', 'off', 'title', 'flat power 1 per wifi tower', 'colorbar_title', 'dBm');

pause;
close all;


map = squeeze(file.beta_map(ch_idx,:,:));
make_map(map, 'save', 'off', 'scale', 1, 'title', 'beta map');


%% Test rate map data
clc; clear all; close all;

p = 2000;
power = 0;
height = 30;
power_type = 'old_power';
char_label = generate_label('char', height, power);
jam_label = generate_label('jam', p, 'real', char_label);

% make_jam_rates(jam_label, power_type);  % regenerate

file = load(['Data/' generate_filename(jam_label) ' (' power_type ').mat']);

% map = squeeze(sum(isnan(file.fair_rate_map),1));
% make_map(map, 'map_type', 'log', 'save', 'off', 'colorbar_title', '# of NaNs');

close all;
map = squeeze(sum(file.fair_rate_map, 1));
make_map((map/1e3)/p, 'map_type', 'log', 'save', 'off', 'colorbar_title', 'kbps per person');

% close all;
% map = squeeze(sum(file.fair_rate_map, 1));
% W = get_simulation_value('bandwidth');
% make_map(map/W, 'map_type', 'log', 'save', 'off', 'colorbar_title', 'bps/Hz');



% map = squeeze(sum(file.adj_restrictions>0,1));
% % imagesc(map); axis xy; colorbar;
% make_map(map, 'save', 'off', 'title', '# adj. restrictions');


%% Power ratios

clc; clear all; close all;

p = 2000;
power = 0;
height = 30;
power_type = 'new_power';
char_label = generate_label('char', height, power);
jam_label = generate_label('jam', p, 'real', char_label);

% make_jam_rates(jam_label, power_type);  % regenerate

% data rate file
file = load(['Data/' generate_filename(jam_label) ' (' power_type ').mat']);
% power map file
file2 = load(save_filename(jam_label));


ch_idx = get_channel_index(21);

map1 = squeeze(file.uniform_power_map(ch_idx,:,:));
map2 = squeeze(file2.new_power_map(ch_idx,:,:));
%%
close all;
figure; imagesc((map1)); colorbar; axis xy; title('uniform power');
figure; imagesc((map2)); colorbar; axis xy; title('new power');


figure; imagesc(log(map2./map1)); colorbar; axis xy; title('new power / uniform power');