%% Map of towers
% This file will generate a map of the TV towers and their protected
% regions for the specified channel.

clc; clear all; close all;

%% Parameters
channel = 10
tower_data_year = '2011'

num_points_on_circle = 30;
circle_color = 'b';
circle_alpha = 0.5;

%% Load the tower data
[chan_data struct] = get_tower_data(tower_data_year);
struct_to_vars; % "deal" the fieldnames of 'struct' to local variables

%% Remove towers on the wrong channel
keep = chan_data(:, chan_no_idx) == channel;
chan_data(~keep, :) = [];

num_towers = size(chan_data,1)

%% Plot the towers
close all;
plot_shapefile('us');

angles = linspace(0, 360, num_points_on_circle+1);

for t = 1:num_towers
    lat = chan_data(t, lat_idx);
    long = chan_data(t, long_idx);
    rp = chan_data(t, fcc_rp_idx);
    
    [plot_lat plot_long] = km_to_latlong(lat, long, rp, angles);
    
    patch(plot_long, plot_lat, circle_color, 'facealpha', circle_alpha, 'edgealpha', 0);
end

%% Save the figure
grid off;
axis off;
save_plot('png', ['Towers on channel ' num2str(channel)], 1);