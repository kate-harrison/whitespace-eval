%% Effects of exclusions

%% Channels lost to... metropolitan exclusions
clc; clear all; close all;
map_size = '400x600';
mask = get_metro_area_exclusions(map_size);
excl = ~mask;
total = squeeze(sum(excl,1));

make_map(total, 'title', 'Channels lost to metropolitan exclusions', ...
    'colorbar_title', 'Channels', 'save', 'on', 'integer_labels', 'on', ...
    'state_outlines', 'on', 'no_background', 'on',  ...
    'scale_div', 10, 'state_outline_color', 'w', ...
    'filename', 'Channels lost to metropolitan areas');


%% Channels lost to... radio astronomy exclusions
clc; clear all; close all;
map_size = '400x600';
mask = get_radio_astr_exclusions(map_size, 1);
excl = ~mask;
% total = squeeze(sum(excl,1));
total = aggregate_bands(excl);

make_map(total, 'title', 'Channels lost to radio astronomy exclusions', ...
    'colorbar_title', 'Channels', 'save', 'on', 'integer_labels', 'on', ...
    'state_outlines', 'on', 'no_background', 'on',  ...
    'scale_div', 10, 'state_outline_color', 'w', ...
    'filename', 'Channels lost to radio astronomy');


%% Channels lost to... FCC exclusions
clc; clear all; close all;
fcc_mask_label = generate_label('fcc_mask', 'cr-2011', '200x300');
excl = load_by_label(fcc_mask_label);
% total = squeeze(sum(~excl,1));
total_lost = aggregate_bands(~excl);

make_map(total_lost, 'title', 'Channels lost to TV towers', ...
    'colorbar_title', 'Channels', 'save', 'on', 'integer_labels', 'on', ...
    'state_outlines', 'off', 'no_background', 'on',  ...
    'scale_div', 10, 'state_outline_color', 'k', ...
    'filename', 'Channels lost to TV towers');


close all;
total_avail = aggregate_bands(excl);
make_map(total_avail, 'title', 'Channels available after only TV towers', ...
    'colorbar_title', 'Channels', 'save', 'on', 'integer_labels', 'on', ...
    'state_outlines', 'off', 'no_background', 'on',  ...
    'scale_div', 10, 'state_outline_color', 'k', ...
    'filename', 'Channels available after only TV towers');

%% Channels lost to... FCC exclusions (digital version)
clc; clear all; close all;
% fcc_mask_label = generate_label('fcc_mask', 'cr-2011', '200x300');
% excl = load_by_label(fcc_mask_label);
load('FCC_MASK device_type=cr-2011 map_size=200x300_all_digital', 'mask');
% total = squeeze(sum(~mask,1));
total = aggregate_bands(~mask);

make_map(total, 'title', 'Channels lost to TV towers (all digital)', ...
    'colorbar_title', 'Channels', 'save', 'on', 'integer_labels', 'on', ...
    'state_outlines', 'on', 'no_background', 'on',  ...
    'scale_div', 10, 'state_outline_color', 'k', ...
    'filename', 'Channels lost to TV towers (all digital)');

% total = squeeze(sum(mask,1));
total = aggregate_bands(mask);
make_map(total, 'title', 'Channels available after only TV towers (all digital)', ...
    'colorbar_title', 'Channels', 'save', 'on', 'integer_labels', 'on', ...
    'state_outlines', 'on', 'no_background', 'on',  ...
    'scale_div', 10, 'state_outline_color', 'k', ...
    'filename', 'Channels available after only TV towers (all digital)');


%% Total channels lost/remaining
clc; clear all; close all;
map_size = '200x300';
metro_mask = get_metro_area_exclusions(map_size);
astr_mask = get_radio_astr_exclusions(map_size, 1);
fcc_mask_label = generate_label('fcc_mask', 'cr-2011', '200x300');
fcc_mask = load_by_label(fcc_mask_label);

avail = metro_mask & astr_mask & fcc_mask;
lost = ~avail;

% total_avail = squeeze(sum(avail,1));
% total_lost = squeeze(sum(lost,1));
total_avail = aggregate_bands(avail);
total_lost = aggregate_bands(lost);

make_map(total_lost, 'title', 'Channels lost to all exclusions', ...
    'colorbar_title', 'Channels', 'save', 'on', 'integer_labels', 'on', ...
    'state_outlines', 'on', 'no_background', 'on',  ...
    'scale_div', 10, 'state_outline_color', 'k', ...
    'filename', 'Channels lost to all exclusions');

make_map(total_avail, 'title', 'Channels available', ...
    'colorbar_title', 'Channels', 'save', 'on', 'integer_labels', 'on', ...
    'state_outlines', 'on', 'no_background', 'on',  ...
    'scale_div', 10, 'state_outline_color', 'k', ...
    'filename', 'Channels available');



%% Plot protected regions (not discretized)

clc; clear all; close all;

tower_data_year = '2011'

% Load the tower data
[chan_data struct] = get_tower_data(tower_data_year);
struct_to_vars; % "deal" the fieldnames of 'struct' to local variables


plot_shapefile('us');

chan_list = get_simulation_value('chan_list');
num_chans = max(chan_list);
cmap = jet(num_chans);

for i = 1:length(chan_data)
    
    % Flag those with weird r_p
    dist = chan_data(i, fcc_rp_idx);
    if (dist <= 0)
        i
        continue;
    end
    
    % Skip those that aren't on the channels we care about
    idx = find(chan_list == chan_data(i, chan_no_idx));
    if (isempty(idx))
        continue;
    end
    
    
    lat = chan_data(i, lat_idx);
    long = chan_data(i, long_idx);
    
    center = [long lat];
    [lat2 long2] = km_to_latlong(lat, long, dist, 0);
    radius = sqrt( (lat - lat2)^2 + (long - long2)^2 );
    NOP = 100;
    
    % Copied from circle.m (from fileexchange)
    THETA=linspace(0,2*pi,NOP);
    RHO=ones(1,NOP)*radius;
    [X,Y] = pol2cart(THETA,RHO);
    X=X+center(1);
    Y=Y+center(2);

    ch_idx = chan_data(i, chan_no_idx);
    patch(X, Y, cmap(ch_idx), 'facealpha', 0.1, 'edgecolor', 'none');
end


% Label the colorbar
labels = round(linspace(min(chan_list), max(chan_list), 10));    
scale = (labels-1)/num_chans;
h=colorbar('YTick', scale, 'YTickLabel', {num2str(labels')});

title('Protected regions across channels 2-51');
set(gcf, 'outerposition', [56         127        1164         730]);

save_plot('png', 'Protected areas, colorful');