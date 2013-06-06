%% Map of all towers
% This file will generate a map of the TV towers and their protected
% regions (on all channels).

clc; clear all; close all;

%% Parameters
tower_data_year = '2011'

num_points_on_circle = 30;
circle_color = 'b';
circle_alpha = 0.01;

%% Load the tower data
[chan_data struct] = get_tower_data(tower_data_year);
struct_to_vars; % "deal" the fieldnames of 'struct' to local variables


close all;
plot_shapefile('us');

chan_list = get_simulation_value('chan_list');

for c = 1:length(chan_list)
    channel = chan_list(c)
    keep = chan_data(:, chan_no_idx) == channel;

    sub_chan_data = chan_data(keep,:);
    
    angles = linspace(0, 360, num_points_on_circle+1);
    
    for t = 1:size(sub_chan_data,1)
        lat = sub_chan_data(t, lat_idx);
        long = sub_chan_data(t, long_idx);
        rp = sub_chan_data(t, fcc_rp_idx);
        
        [plot_lat plot_long] = km_to_latlong(lat, long, rp, angles);
        
        patch(plot_long, plot_lat, circle_color, ...
            'facealpha', circle_alpha, 'edgealpha', 0);
    end
    
end


%% Save the figure
save_plot('png', ['All towers, year=' num2str(tower_data_year)], 1);