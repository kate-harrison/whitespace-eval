%% Test the fractions and our combination of them

clc; clear all; close all;

width = 10;
cr_haat = 30;
p = 2000;

% int_file = load(['path_loss_rectangles height=' num2str(cr_haat) ' width=' num2str(width) '.mat'], 'out');

patch_file = load(['center_interference_patch p=' num2str(p) ', height= ' num2str(cr_haat) '.mat']);

%%
close all;
[is_in_us lat_coords long_coords] = get_us_map('200x300', 1);

i = get_channel_index(21);
% j = floor(length(lat_coords)/2);
% k = floor(length(long_coords)/2);
j = 129;
k = 261;

% int_rect = int_file.out(i,j);
int_patch = patch_file.int(i,j,k)

% any([patch_file.int(:,:,:).care])

% figure; imagesc(~patch_file.dont_care_map); axis xy; colorbar
% figure; imagesc(patch_file.tower_per_pixel_map); axis xy; colorbar;
% 
% 
% mini_grid = int_patch.grid;
% % mini_grid(2,2) = mini_grid(2,2) * int_patch.num_towers;
% figure; imagesc(get_W_to_dBm(mini_grid)); colorbar;