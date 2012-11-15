%% Test get_hexagon_grid_points.m

clc; clear all; close all;

[x y] = get_hexagon_grid_points([0,0], 1, 5, 5);

x = x(:);
y = y(:);

figure; hold on;
scatter(x,y);

center_idx = ceil(length(x)/2); % this is how we get the center cell
scatter(x(center_idx), y(center_idx), 'r');

% 