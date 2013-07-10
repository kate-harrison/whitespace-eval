%% Number of TV channels vs. population density (2D histogram)
% This file makes a 2-D histogram of the number of TV channels received vs.
% the population density across the United States. It then makes maps of
% the raw data (number of TV channels received, population density).
%
% The code below is inspired by that in
% Figure_generation_files/thesis_figures.m (in particular, the "NUMBER OF
% CHANNELS -- 2D HISTOGRAM" cell).
%
% Additionally, code for creating two-dimensional histograms comes from:
%   http://blogs.mathworks.com/videos/2010/01/22/ ...
%       advanced-making-a-2d-or-3d-histogram-to-visualize-data-density/

clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
pop_type = get_simulation_value('pop_data_type');

% Load the data
label = generate_label('fcc_mask', 'tv', map_size);
tv_coverage_mask = load_by_label(label);
total_channels = sum(tv_coverage_mask);
pop = get_pop_density(map_size, pop_type);
is_in_us = get_us_map(map_size);

% Format the data
total_channels_vec = total_channels(is_in_us);
pop_vec = pop(is_in_us);

x_data = log10(pop_vec');
omit = isinf(x_data);
y_data = total_channels_vec';
x_data(omit) = [];
y_data(omit) = [];

% Create bin centers
x_edges = linspace(min(x_data(:)), max(x_data(:)), 100);
y_edges = 0:max(y_data(:));

% Snap the values to the corresponding bin centers
xr = interp1(x_edges, 1:numel(x_edges), x_data, 'nearest')';
yr = interp1(y_edges, 1:numel(y_edges), y_data, 'nearest')';
% Bin the values
Z = accumarray([xr yr], 1, [length(x_edges) length(y_edges)]);


% Plot the histogram
figure;
imagesc(log(Z'));
axis xy;
% Make zero white
cmap = jet(1024);
cmap(1, :) = [1 1 1];           % zero is white
colormap(cmap);

% Label the axes
idcs = [];
exp_vals = -2:4;
for i = exp_vals
    idcs = [idcs find_closest(i, x_edges)];
end
replace_axes('x', idcs, 10.^(exp_vals));
replace_axes('y', 1:5:length(y_edges), 0:5:length(y_edges)-1);

xlabel('Population density (people/km^2)');
ylabel('Number of channels');

save_plot('png', 'NUMBER_OF_TV_CHANNELS histogram');



%% Make a map of the number of TV channels
close all;
make_map(squeeze(total_channels), 'colorbar_title', 'Number of TV channels', ...
    'state_outlines', 'on', 'no_background', 'on', 'integer_labels', 'on', ...
    'scale', 0:5:40, 'filename', 'Number of TV channels map');

%% Make a logarithmic-scale map of the population
close all;
make_map(pop, 'map_type', 'log', 'colorbar_title', 'Population density (people/km^2)', ...
    'state_outlines', 'on', 'no_background', 'on', 'integer_labels', 'on', ...
    'filename', 'Population map (400x600)');
 
%% Make an arctangent-scale map of the population
close all;
make_map(pop, 'map_type', 'atan', 'colorbar_title', 'Population density (people/km^2)', ...
    'state_outlines', 'on', 'no_background', 'on', 'integer_labels', 'on', ...
     'filename', 'Population map (400x600) (atan)');