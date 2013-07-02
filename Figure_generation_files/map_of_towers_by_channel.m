function [] = map_of_towers_by_channel(channel, varargin)
%   [] = map_of_towers_by_channel(channel, [tower_data_year], [color])
%
%   This function generates a map of the TV towers and their protected
%   regions for the specified channel.
%
%   The optional second argument is the tower data year. If none is given,
%   the default (as given by get_simulation_value('tower_data_year')) will
%   be used.
%
%   The optional third argument is the color to be used for plotting. If
%   none is given, blue ('b') will be used.
%
%   See also: get_simulation_value



%% Parameters
if nargin > 1
    tower_data_year = varargin{1};
else
    tower_data_year = get_simulation_value('tower_data_year');
end

num_points_on_circle = 30;
if nargin > 2
    circle_color = varargin{2};
else
    circle_color = 'b';
end
circle_alpha = 0.5;


%% Load the tower data
[chan_data struct] = get_tower_data(tower_data_year);
struct_to_vars; % "deal" the fieldnames of 'struct' to local variables


%% Remove towers on the wrong channel
keep = chan_data(:, chan_no_idx) == channel;
chan_data(~keep, :) = [];

num_towers = size(chan_data,1);


%% Plot the towers
plot_shapefile('us');

angles = linspace(0, 360, num_points_on_circle+1);

for t = 1:num_towers
    lat = chan_data(t, lat_idx);
    long = chan_data(t, long_idx);
    rp = chan_data(t, fcc_rp_idx);
    
    [plot_lat plot_long] = km_to_latlong(lat, long, rp, angles);
    
    patch(plot_long, plot_lat, circle_color, 'facealpha', circle_alpha, 'edgealpha', 0);
end

grid off;
axis off;

end