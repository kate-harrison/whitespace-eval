%% Figures for MS thesis
% This file is specifically to generate figures that will be included in my
% MS thesis. It currently lacks organization and not all figures were
% included in the final draft of the thesis.

%% Run this cell before all others...
% ... to make sure that the Thesis/ subfolder exists in the folder Output/
% (otherwise all other cells will produce an error).
mkdir('Output', 'Thesis');



%%                          BASIC FIGURES

%%  NUMBER OF CHANNELS AVAILABLE THROUGHOUT THE US TO COGNITIVE RADIOS

clc; clear all; close all;

% Get default values
visible = get_simulation_value('figure_visibility');
map_size = get_simulation_value('map_size');

% Load the data
fcc_exclusions = generate_label('fcc_mask', 'cr', map_size);
exclusions = load_by_label(fcc_exclusions);
allowed = aggregate_bands(exclusions);

% Specify plotting options
options.colorbar_title = 'Number of channels';
options.visibility = visible;
options.integer_labels = 'on';
options.state_outlines = 'on';
options.scale = length(get_simulation_value('chan_list'));
options.no_background = 'on';
% options.filename = 'Thesis/Number of channels available throughout the US to cognitive radios';
options.filename = 'Thesis/NUMBER_OF_CHANNELS map';

% Plot
make_map(allowed, options);

%%  NUMBER OF CHANNELS -- CCDF

clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');

% Load the data
pop = get_population(map_size);
is_in_us = get_us_map(map_size);

fcc_exclusions = generate_label('fcc_mask', 'cr', map_size);
exclusions = load_by_label(fcc_exclusions);
allowed = aggregate_bands(exclusions);

[cdfX cdfY] = calculate_cdf_from_map(allowed, pop, is_in_us);

figure; plot(cdfX, 1-cdfY, 'linewidth', 2);
grid on
xlabel('Number of channels');
ylabel('Fraction of population');
scale_axes('x', 0:5:50, 1);
scale_axes('y', 0:.1:1, 1);


save_plot('png', 'Thesis/NUMBER_OF_CHANNELS CCDF');

%%  NUMBER OF CHANNELS -- SCATTERPLOT

clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
pop_type = get_simulation_value('pop_data_type');

% Load the data
fcc_exclusions = generate_label('fcc_mask', 'cr', map_size);
exclusions = load_by_label(fcc_exclusions);
allowed = aggregate_bands(exclusions);
pop = get_pop_density(map_size, pop_type);
is_in_us = get_us_map(map_size);

allowed_vec = allowed(is_in_us);
pop_vec = pop(is_in_us);


semilogx(pop_vec, allowed_vec, '.');
grid on; axis tight;
% axis([-inf 10^4 -inf inf]);
axis([1e-2 1e4 0 45]);

scale_axes('x', 10.^(-2:1:4));
scale_axes('y', 0:5:50);
xlabel('Population density (people/km^2)');
ylabel('Number of channels');

save_plot('png', 'Thesis/NUMBER_OF_CHANNELS scatterplot');

%%  NUMBER OF CHANNELS -- SCATTERPLOT 2

clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
pop_type = get_simulation_value('pop_data_type');

% Load the data
fcc_exclusions = generate_label('fcc_mask', 'cr', map_size);
exclusions = load_by_label(fcc_exclusions);
allowed = aggregate_bands(exclusions);
pop = get_pop_density(map_size, pop_type);
is_in_us = get_us_map(map_size);

allowed_vec = allowed(is_in_us);
pop_vec = pop(is_in_us);

close all;
figure; hold on;
NOP = 5;
THETA=linspace(0,2*pi,NOP);
for i = 1:length(allowed_vec)
    center = [log10(pop_vec(i)), allowed_vec(i)];
    radius = .1;
    RHO=ones(1,NOP)*radius;
    [X,Y] = pol2cart(THETA,RHO);
    X=X+center(1);
    Y=Y+center(2);
    patch(X,Y,'b', 'facealpha', .08, 'edgecolor', 'w');
end

grid on; axis tight;
axis([-2 4 0 45]);
replace_axes('x', -2:1:4, 10.^(-2:1:4), 1)
scale_axes('y', 0:5:50);
xlabel('Population density (people/km^2)');
ylabel('Number of channels');

save_plot('png', 'Thesis/NUMBER_OF_CHANNELS scatterplot 2');

%%  NUMBER OF CHANNELS -- 2D HISTOGRAM
% Two-dimensional histogram code from:
%   http://blogs.mathworks.com/videos/2010/01/22/ ...
%       advanced-making-a-2d-or-3d-histogram-to-visualize-data-density/

clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
pop_type = get_simulation_value('pop_data_type');

% Load the data
fcc_exclusions = generate_label('fcc_mask', 'cr', map_size);
exclusions = load_by_label(fcc_exclusions);
allowed = aggregate_bands(exclusions);
pop = get_pop_density(map_size, pop_type);
is_in_us = get_us_map(map_size);

% Format the data
allowed_vec = allowed(is_in_us);
pop_vec = pop(is_in_us);

x_data = log10(pop_vec');
omit = isinf(x_data);
y_data = allowed_vec';
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

save_plot('png', 'Thesis/NUMBER_OF_CHANNELS histogram');

%%  POPULATION DENSITY MAP

clc; clear all; close all;

% Get default values
visible = get_simulation_value('figure_visibility');
map_size = get_simulation_value('map_size');
pop_type = get_simulation_value('pop_data_type');

% Load the data
pop = get_pop_density(map_size, pop_type);

% Specify plotting options
options.map_type = 'log';
% options.colorbar_title = 'People/km^2';
options.visibility = visible;
options.integer_labels = 'on';
options.state_outlines = 'on';
options.scale = 10e3;
options.no_background = 'on';
options.filename = 'Thesis/POPULATION_DENSITY map';

% Plot
make_map(pop, options);

%%  POPULATION DENSITY CCDFS

clc; clear all; close all;
warning off all;

map_size = '200x300';
pop_type = get_simulation_value('pop_data_type');

population_density = get_pop_density(map_size, pop_type, 1);
is_in_us = get_us_map(map_size, 1);
us_area = get_us_area(map_size);
population = get_population(map_size, pop_type, 1);

pop_density = population_density(is_in_us);


[cdfx_by_pop cdfy_by_pop avg_by_pop med_by_pop] = calculate_cdf_from_map(population_density, population, is_in_us);
[cdfx_by_area cdfy_by_area avg_by_area med_by_area] = calculate_cdf_from_map(population_density, us_area, is_in_us);


load('plot_parameters');
close all;
figure;
lw = 3;
% fs = 18;
fs = font_size;
semilogx(cdfx_by_pop, 1-cdfy_by_pop, 'b', 'linewidth', lw);
hold on; grid on;
semilogx(cdfx_by_area(1:end-1), 1-cdfy_by_area(1:end-1), 'r', 'linewidth', lw);

for p = 1-[.1 .25 .5 .75 .9]
    line([10^-4 10^5], [p p], 'color', 'k');
    text(1.7e-1, p, [num2str(p*100) '%'], 'verticalalignment', 'bottom', 'fontweight', 'bold', 'fontsize', fs);
    
    [idx] = find_closest(p, 1-cdfy_by_pop);
    line(cdfx_by_pop(idx) * [1 1], [0 1], 'color', 'b');
    text(cdfx_by_pop(idx), 0.035, [' ' num2str(cdfx_by_pop(idx),4)], 'fontweight', 'bold', 'fontsize', fs);

    [idx] = find_closest(p, 1-cdfy_by_area);
    line(cdfx_by_area(idx) * [1 1], [0 1], 'color', 'r');
    text(cdfx_by_area(idx), 0.95, [' ' num2str(cdfx_by_area(idx),4)], 'fontweight', 'bold', 'fontsize', fs);

    
end
set(gcf, 'outerposition', [1         -17        1440         874]);

text(1.5, .7, 'By area', 'color', 'r', 'fontsize', font_size, 'fontweight', 'bold');
text(150, .7, 'By population', 'color', 'b', 'fontsize', font_size, 'fontweight', 'bold');

xlabel('Population density (people/km ^2)      ', 'fontsize', fs);
ylabel('Probability', 'fontsize', fs);

axis([1e-2 1e4 0 1.1])
set(gca, 'fontsize', fs);
xlhand = get(gca,'xlabel');
set(xlhand, 'fontsize',fs);
ylhand = get(gca,'ylabel');
set(ylhand, 'fontsize',fs);

save_plot('png', 'Thesis/POPULATION DENSITY ccdfs', 1);

%%  PROPAGATION CURVES
clc; clear all; close all;

channel = 21;
dists = [.1:.1:1 1:100 110:30:990 1000];
heights = [10.1 30 100];

figure; set(gcf, 'outerposition', [159         427        1095         425]);

for h = 1:length(heights)
    loglog(dists, apply_path_loss(1, channel, heights(h), dists), ...
        'linewidth', 2);
    hold all;
    grid on;
end

axis tight;
axis([1e-1 1e3 -inf inf]);
legend(num2str(heights'), 'location', 'southwest');
label_legend('Height (m)');
xlabel('Distance to transmitter (km)');
ylabel('Fraction of transmitted power');
scale_axes('x', 10.^(-1:3));
scale_axes('y', 10.^(-50:5:-5));

save_plot('png', 'Thesis/PROPAGATION_CURVES', 1);

%%  MAP SAMPLING
clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');

% Load data
[is_in_us, lat_coords, long_coords] = get_us_map(map_size);

lats = repmat(lat_coords', [1 length(long_coords)]);
lats_vec = lats(is_in_us);
longs = repmat(long_coords', [1 length(lat_coords)])';
longs_vec = longs(is_in_us);


% Plot the data
plot_shapefile('us', '', 3); hold on;
set(gcf, 'outerposition', [485     4   873   823]);
axis([-94 -85 42 48]);
plot(longs_vec, lats_vec, 'r.', 'markersize', 10);
xlabel('Longitude (degrees)');
ylabel('Latitude (degrees)');
save_plot('png', 'Thesis/CODE map of grid', 1);

%%  POPULATION COMPUTATION

clc; clear all; close all;
% Note: code stolen from try_polygon_clipping.m

year = 2010
state = 23
map_size = '200x300';

[~, lat_coords, long_coords] = get_us_map(map_size);
lat_half_width = (lat_coords(2) - lat_coords(1))/2;
long_half_width = (long_coords(2) - long_coords(1))/2;

center_lat = 44;
center_long = -70;

P2.y = center_lat + [-1 1 1 -1]*lat_half_width;
P2.x = center_long + [-1 -1 1 1]*long_half_width;
P2.hole = 0;



% Note that we will make sure that the year is noted in two places (namely,
% the containing folder and the filename) so that there are no accidents.
switch(year)
    case 2000,  file_num = '500';   field_num = '00';
    case 2010,  file_num = '510';   field_num = '10';
    otherwise,
        error(['Invalid census year: ' num2str(year) ...
            '. Valid inputs are 2000 and 2010.']);
end

state_num = num2str(state, '%02d');
poly_filename = [get_population_data_dir(year) ...
    '/Geography/tl_2010_' state_num ...
    '_tract' field_num '/tl_2010_' state_num '_tract' field_num '.shp'];

[S,A] = shaperead(poly_filename, 'usegeocoords', true);


figure; hold on;
for i = 1:length(S)
    
    idcs = [0 find(isnan(S(i).Lon))];
    
    for j = 1:length(idcs)-1
        idcs2 = idcs(j)+1:idcs(j+1)-1;
        P1.y = S(i).Lat(idcs2);
        P1.x = S(i).Lon(idcs2);
        P1.hole = 0;
        
        P3 = PolygonClip(P1, P2, 1);
        if (isempty(P3))
            continue;
        end
        
        poly_area = 0;
        patch(P1.x, P1.y, [1 1 1]*.95);
        for j = 1:length(P3)
            patch(P3(j).x, P3(j).y, 'b', 'facealpha', .4);
        end
        
    end
end

plot(center_long, center_lat, 'k.', 'markersize', 40);

axis tight;
grid on;
xlabel('Longitude (degrees)');
ylabel('Latitude (degrees)');
set(gcf, 'outerposition', [440   314   447   537]);
save_plot('png', 'Thesis/CODE population computation', 1);

%%  CENSUS TRACTS

clc; clear all; close all;
% Note: code stolen from try_polygon_clipping.m

year = 2010
state = 55  % Wisconsin

switch(year)
    case 2000,  file_num = '500';   field_num = '00';
    case 2010,  file_num = '510';   field_num = '10';
    otherwise,
        error(['Invalid census year: ' num2str(year) ...
            '. Valid inputs are 2000 and 2010.']);
end

state_num = num2str(state, '%02d');
poly_filename = [get_population_data_dir(year) ...
    '/Geography/tl_2010_' state_num ...
    '_tract' field_num '/tl_2010_' state_num '_tract' field_num '.shp'];

plot_shapefile(poly_filename);
 
axis tight;
grid on;
xlabel('Longitude (degrees)');
ylabel('Latitude (degrees)');
set(gcf, 'outerposition', [440   240   589   611]);
save_plot('png', 'Thesis/CODE census tracts', 1);



%%  SINGLE-LINK COMPARISONS
% (a) No pollution, no exclusions (b) Pollution, no exclusions 
% (c) No pollution, exclusions (d) Pollution, exclusions 

clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
visible = get_simulation_value('figure_visibility');
channels = ['tv-' get_simulation_value('tower_data_year')];
device_type = ['cr-' get_simulation_value('tower_data_year')];
pop_type = get_simulation_value('pop_data_type');


% Parameters
capacity_type = 'single_user';
range_type = 'r';
range_value = 1;
population_type = 'none';
cr_haat = 30;
cr_power = 4;
with_noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
without_noise_label = generate_label('noise', 'no', map_size, channels, 'none');
fcc_exclusions_label = generate_label('fcc_mask', device_type, map_size);

% Specify plotting options
plot_scale = 1e9;
options.colorbar_title = 'Gbps';
options.visibility = visible;
options.integer_labels = 'on';
options.state_outlines = 'on';
options.no_background = 'on';
options.map_type = 'log';
% options.autolabel = 'on';
options.scale = 5e9/plot_scale;



char_label = generate_label('char', cr_haat, cr_power);
cell_model_label = 'none';
pop_map = get_population(map_size, pop_type);
is_in_us = get_us_map(map_size);

for i = 1:4
    
    % Exclusions
    switch(i)
        case {1,3},     % no exclusions
            excl_label = 'none';
            excl_str = 'none';
        case {2,4},     % FCC exclusions
            excl_label = fcc_exclusions_label;
            excl_str = 'FCC';
    end
    
    % Noise
    switch(i)
        case {1,2},     % no noise
            noise_label = without_noise_label;
            noise_str = 'noiseless';
        case {3,4},     % TV tower noise
            noise_label = with_noise_label;
            noise_str = 'noise';
    end
    
    options.filename = ['Thesis/SINGLE_USER_COMPARISON ' noise_str ' excl=' excl_str];
    
    
    capacity_label = generate_label('capacity', capacity_type, range_type, ...
        range_value, population_type, char_label, noise_label, cell_model_label);
    
    total_capacity = get_total_capacity(capacity_label, excl_label);
    [cdfX{i} cdfY{i}] = calculate_cdf_from_map(total_capacity, pop_map, is_in_us);

    make_map(total_capacity/plot_scale, options);
end


% Make CCDF
close all;
scale = 1e9;
scale_text = 'Gbps';
figure; set(gcf, 'outerposition', [313         454        1002         403]);
for i = [4 2 3 1]
    semilogx(cdfX{i}/scale, 1-cdfY{i}, 'linewidth', 2);
    hold all;
end

ax = axis;
axis([.05 5 0 1.05]); grid on;
scale_axes('x', [.1 .2 .4 .8 1 2 cdfX{1}(1)/scale]);
labels = {'No excl, no noise', 'Excl, no noise', 'No excl, noise', 'Excl, noise'};
legend(labels{[4 2 3 1]}, 'location', 'southwest');
xlabel(['Data rate (' scale_text ')']);
ylabel('Fraction of population');

set(gcf,'PaperPositionMode','auto')
save_plot('png', 'Thesis/SINGLE_USER_COMPARISON CCDF');

%%  MAC MODEL RATE MAP, P = 2000
clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
visible = get_simulation_value('figure_visibility');
channels = ['tv-' get_simulation_value('tower_data_year')];
device_type = ['cr-' get_simulation_value('tower_data_year')];
pop_type = get_simulation_value('pop_data_type');


% Parameters
capacity_type = 'per_person';
range_type = 'p';
p = 2000;
population_type = pop_type;
cr_haat = 30;
cr_power = 4;
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
fcc_exclusions_label = generate_label('fcc_mask', device_type, map_size);

% Specify plotting options
options.visibility = visible;
options.integer_labels = 'on';
options.state_outlines = 'on';
options.no_background = 'on';
options.map_type = 'log';
plot_scale = 1e3;
options.colorbar_title = 'kbps/person';
options.scale = 75e3/plot_scale;
options.filename = ['Thesis/MAC RATE_MAP per_person p=' num2str(p)];


char_label = generate_label('char', cr_haat, cr_power);
cell_model_label = generate_label('mac_table', channels, char_label);

population = get_population(map_size, pop_type);
is_in_us = get_us_map(map_size);


capacity_label = generate_label('capacity', capacity_type, range_type, ...
    p, population_type, char_label, noise_label, cell_model_label);

total_capacity = get_total_capacity(capacity_label, fcc_exclusions_label);
% total_capacity_capped = cap_to_val(total_capacity/plot_scale, .95*options.scale);
make_map(total_capacity/plot_scale, options);

%%  HEXAGON MODEL RATE MAP, P = 2000

clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
channels = ['tv-' get_simulation_value('tower_data_year')];
device_type = ['cr-' get_simulation_value('tower_data_year')];
population_type = get_simulation_value('pop_data_type');
visible = get_simulation_value('figure_visibility');


% Parameters
capacity_type = 'per_person';
range_type = 'p';
range_value = 2000;
cr_haat = 30;
cr_power = 4;
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
fcc_exclusions_label = generate_label('fcc_mask', device_type, map_size);


% Specify plotting options
plot_scale = 1e3;
options.colorbar_title = 'kbps';
options.visibility = visible;
options.integer_labels = 'on';
options.state_outlines = 'on';
options.no_background = 'on';
options.map_type = 'log';
options.autolabel = 'off';
options.scale = 300e3/plot_scale;
options.filename = 'Thesis/HEX RATE_MAP p=2000';


char_label = generate_label('char', cr_haat, cr_power);
cell_model_label = generate_label('hex', 'cellular', char_label);

capacity_label = generate_label('capacity', capacity_type, range_type, ...
    range_value, population_type, char_label, noise_label, cell_model_label);

total_capacity = get_total_capacity(capacity_label, fcc_exclusions_label);

make_map(total_capacity/plot_scale, options);




%%  RADIO ASTRONOMY EXCLUSIONS
clc; clear all; close all;

map_size = get_simulation_value('map_size');
get_radio_astr_exclusions(map_size, 1, 1);
axis off;
save_plot('png', 'Thesis/EXCLUSIONS radio_astronomy', 1);

%%  METROPOLITAN EXCLUSIONS -- FIX UP
clc; clear all; close all;

map_size = '800x1200';
excl_map = ~get_metro_area_exclusions(map_size);
excl_map = aggregate_bands(excl_map);
is_in_us = get_us_map(map_size);
excl_map(~is_in_us) = inf;

% Plotting options
options.map_type = 'linear';
options.colorbar_title = 'Channels';
options.filename = 'Thesis/EXCLUSIONS metro areas';
options.integer_labels = 'on';
options.state_outlines = 'on';
options.state_outline_color = 'w';
options.no_background = 'on';
options.scale = 0:get_max_val(excl_map);

make_map(excl_map, options);

% What do we lose on top of FCC exclusions?
fcc_label = generate_label('fcc_mask', 'cr', map_size, false);
fcc_mask = load_by_label(fcc_label);
new_excl = (fcc_mask == 1) & (get_metro_area_exclusions(map_size) == 0);
total_new_excl = aggregate_bands(new_excl);
options.filename = 'Thesis/EXCLUSIONS metro areas additional';
make_map(total_new_excl, options);

% % Change black background -- watch out, this changes the colorbar axis (not
% % fixed yet)
% cmap = colormap;
% cmap(1,:) = [1 1 1]*.6;
% colormap(cmap);
% 
% save_plot('png', options.filename, 1);

%%  POPULATION SAMPLING
% Mostly stolen from Toys/population_and_tower_replacement/make_true_pop_cdf.m
% True CCDF of population by area

clc; clear all; close all;

load([get_population_data_dir(2010) '/tract_info2010.mat']);


areas = zeros(1,length(tract_info));
pops = zeros(1,length(tract_info));

skipped = 0;
for i = 1:length(tract_info)
    if (mod(i, 100) == 0)
        i
    end
    % If more than 90% of the area is water, skip it
    if (tract_info(i).land_area <= 0.1*tract_info(i).total_area)
        skipped = skipped + 1;
        continue;
    end
    areas(i) = tract_info(i).total_area;
    pops(i) = tract_info(i).pop_density;
end
beep
skipped

close all;

% [cdfX_area cdfY_area] = calculate_cdf_from_map(pops, areas, areas > 0);
[cdfX_pop cdfY_pop] = calculate_cdf_from_map(pops, pops.*areas, areas > 0);

map_size_array = {'200x300', '400x600', '800x1200'};

lw = 2;
figure; set(gcf, 'outerposition', [159         427        1095         425]);
loglog(cdfX_pop, 1-cdfY_pop, 'linewidth', lw);
hold all;

for i = 1:length(map_size_array)
    map_size = map_size_array{i};
    pop_density = get_pop_density(map_size);
    population = get_population(map_size);
    is_in_us = get_us_map(map_size);

    [cdfX cdfY] = calculate_cdf_from_map(pop_density, population, is_in_us);
    loglog(cdfX, 1-cdfY, 'linewidth', lw);
end
    

grid on;
axis([1e0 1e5 1e-3 1e0]);
xlabel('Population density (people/km^2)');
ylabel('Fraction of population');
legend('Ground truth', '200x300 samples', '400x600 samples', '800x1200 samples', ...
    'location', 'southwest');

save_plot('png', 'Thesis/POPULATION_DENSITY limitations', 1);


%% TV lost-reception maps
% See tv_maps.m (eventually copy into here)



%% Toy example lost channels single tower
% See Miscellaneous/actual_rp.m



%%  JAM RATES VS FCC RATES

% Need to contrast model 3 (jam) with model 0 (fcc power density)

clc; clear all; close all;

% Model parameters
model_number_array = [0 3];   % Matched hotspot, cellular rules
p = 2000;
bpsHz = 0.5;
power_type = 'flat3';
stage = 'rate_map';


% Secondary characteristics
power = 4;  % Not used in the jam model BUT USED FOR FCC MODEL
height = 30;


% Default values
map_size = get_simulation_value('map_size');
tower_data_year = get_simulation_value('tower_data_year');
channels = ['tv-' tower_data_year];
population_type = get_simulation_value('pop_data_type');
visible = get_simulation_value('figure_visibility');
is_in_us = get_us_map(map_size);
% population = get_population(map_size, population_type);


% Specify plotting options
options.map_type = 'log';
options.visibility = visible;
options.state_outlines = 'on';
options.integer_labels = 'on';
options.auto_cap = 'on';




% Create labels
char_label = generate_label('char', height, power);
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');



for model_number = model_number_array
    
    jam_label = generate_label('jam', stage, model_number, power_type, ...
        population_type, tower_data_year, char_label, bpsHz, p, noise_label);
    
    
    switch(model_number)
        case 0, model_name = 'fcc_rules';
%             scale = 1e6;
%             label = 'Mbps';
%             %                 options.scale = 12;
            
            
        case 3, model_name = 'cellular';
        otherwise, error('Unplanned model number.');
    end
                scale = 1e6;
            label = 'Mbps';
            options.scale = 750;

    options.filename = ['Thesis/JAM_COMPARISON ' model_name];
    options.colorbar_title = label;
    
    
    
    [fair_rate_map] = load_by_label(jam_label);
    map = aggregate_bands(fair_rate_map);
    
    map(~is_in_us) = inf;
    map(is_in_us & isinf(map)) = options.scale * scale * .98;
    
    make_map(map/scale, options);
    
end









%%  HEIGHT COMPARISON
clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
visible = get_simulation_value('figure_visibility');
channels = ['tv-' get_simulation_value('tower_data_year')];
device_type = ['cr-' get_simulation_value('tower_data_year')];


% Parameters
capacity_type = 'single_user';
range_type = 'r';
range_value = 10;
population_type = 'none';
cr_haats = [30 100];
cr_power = 4;
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
fcc_exclusions_label = generate_label('fcc_mask', device_type, map_size);

% Specify plotting options
plot_scale = 1e9;
options.colorbar_title = 'Gbps';
options.visibility = visible;
options.integer_labels = 'on';
options.state_outlines = 'on';
options.no_background = 'on';
options.map_type = 'log';
% options.autolabel = 'on';
% options.scale = (0:.5:2.5)*1e9/plot_scale;
options.scale = 5e9/plot_scale;

cell_model_label = 'none';

for h = 1:2
    char_label = generate_label('char', cr_haats(h), cr_power);
    options.filename = ['Thesis/HEIGHT_COMPARISON ' generate_filename(char_label)];
    
    capacity_label = generate_label('capacity', capacity_type, range_type, ...
        range_value, population_type, char_label, noise_label, cell_model_label);
    
    total_capacity = get_total_capacity(capacity_label, fcc_exclusions_label);

    make_map(total_capacity/plot_scale, options);
end

%%  HEIGHT-RANGE COMPARISON
clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
pop_type = get_simulation_value('pop_data_type');
channels = ['tv-' get_simulation_value('tower_data_year')];
device_type = ['cr-' get_simulation_value('tower_data_year')];


% Set basic parameters
capacity_type = 'single_user';
range_type = 'r';
range_array = [.1 .5 1 5 10 50 100 500 1000];
% height_array = [10.1 20:20:100];
height_array = [10.1 30 100];
power = 4;  % Watts

% Noise type
cochannel = 'yes';
leakage_type = 'both';
noise_label = generate_label('noise', cochannel, map_size, channels, ...
    leakage_type);

cell_model_label = 'none';


avgs = zeros(length(height_array), length(range_array));
meds = zeros(length(height_array), length(range_array));


% Height
for h = 1:length(height_array)
    height = height_array(h);
    char_label = generate_label('char', height, power);
    
    % Range value
    for r = 1:length(range_array)
        range_value = range_array(r);
        
        capacity_label = generate_label('capacity', capacity_type, range_type, ...
            range_value, pop_type, char_label, noise_label, cell_model_label);
        
        ccdf_label = generate_label('ccdf_points', 'fade_margin', 'fcc', capacity_label);

        [avg med] = load_by_label(ccdf_label);
        avgs(h,r) = avg.cr;
        meds(h,r) = med.cr;
    end
end

close all;
scale = 1e6;
scale_text = 'Mbps';
figure; set(gcf, 'outerposition', [159         427        1095         425]);
loglog(range_array, avgs'/scale, 'linewidth', 2);
grid on; axis tight;
scale_axes('x', 10.^(-1:3), 1);
scale_axes('y', 10.^(-12:2:10), 1);
axis([-inf inf -inf 1e4]);
legend({num2str(height_array')}, 'location', 'southwest');
label_legend('Height (m)');
xlabel('Range (km)');
ylabel(['Average rate (' scale_text ')']);

save_plot('png', 'Thesis/HEIGHT_AND_RANGE_COMPARISON avg plot', 1);

%%                          RANGE COMPARISONS

%%  SINGLE-LINK RANGE COMPARISON

clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
visible = get_simulation_value('figure_visibility');
channels = ['tv-' get_simulation_value('tower_data_year')];
device_type = ['cr-' get_simulation_value('tower_data_year')];


% Parameters
capacity_type = 'single_user';
range_type = 'r';
range_values = [1 10];
population_type = 'none';
cr_haat = 30;
cr_power = 4;
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
fcc_exclusions_label = generate_label('fcc_mask', device_type, map_size);

% Specify plotting options
plot_scale = 1e9;
options.colorbar_title = 'Gbps';
options.visibility = visible;
options.integer_labels = 'on';
options.state_outlines = 'on';
options.no_background = 'on';
options.map_type = 'log';
% options.autolabel = 'on';
options.scale = 5e9/plot_scale;


cell_model_label = 'none';
char_label = generate_label('char', cr_haat, cr_power);

for r = 1:length(range_values)
    options.filename = ['Thesis/RANGE_COMPARISON range=' num2str(range_values(r)) ' km'];
    
    capacity_label = generate_label('capacity', capacity_type, range_type, ...
        range_values(r), population_type, char_label, noise_label, cell_model_label);
    
    total_capacity = get_total_capacity(capacity_label, fcc_exclusions_label);

    
    figure; 
    make_map(total_capacity/plot_scale, options);
end

%%  MAC RANGE COMPARISON - PER AREA

clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
visible = get_simulation_value('figure_visibility');
channels = ['tv-' get_simulation_value('tower_data_year')];
device_type = ['cr-' get_simulation_value('tower_data_year')];


% Parameters
capacity_type = 'per_area';
range_type = 'r';
range_values = [1 10];
population_type = 'none';
cr_haat = 30;
cr_power = 4;
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
fcc_exclusions_label = generate_label('fcc_mask', device_type, map_size);

% Specify plotting options
options.visibility = visible;
options.integer_labels = 'on';
options.state_outlines = 'on';
options.no_background = 'on';
options.map_type = 'log';

char_label = generate_label('char', cr_haat, cr_power);
cell_model_label = generate_label('mac_table', channels, char_label);

for r = 1:length(range_values)
    
    switch(range_values(r))
        case 1,
            plot_scale = 1e6;
            options.colorbar_title = 'Mbps/km^2';
            options.scale = 30e6/plot_scale;
        case 10,
            plot_scale = 1e3;
            options.colorbar_title = 'kbps/km^2';
            options.scale = 500e3/plot_scale;
    end            
    
    options.filename = ['Thesis/MAC_RANGE_COMPARISON per_area range=' num2str(range_values(r)) ' km'];
    
    capacity_label = generate_label('capacity', capacity_type, range_type, ...
        range_values(r), population_type, char_label, noise_label, cell_model_label);
    
    total_capacity = get_total_capacity(capacity_label, fcc_exclusions_label);

    make_map(total_capacity/plot_scale, options);
end

%%  MAC RANGE COMPARISON - PER PERSON

clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
visible = get_simulation_value('figure_visibility');
channels = ['tv-' get_simulation_value('tower_data_year')];
device_type = ['cr-' get_simulation_value('tower_data_year')];
pop_type = get_simulation_value('pop_data_type');


% Parameters
capacity_type = 'per_person';
range_type = 'r';
range_values = [1 10];
population_type = pop_type;
cr_haat = 30;
cr_power = 4;
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
fcc_exclusions_label = generate_label('fcc_mask', device_type, map_size);

% Specify plotting options
options.visibility = visible;
options.integer_labels = 'on';
options.state_outlines = 'on';
options.no_background = 'on';
options.map_type = 'log';

char_label = generate_label('char', cr_haat, cr_power);
cell_model_label = generate_label('mac_table', channels, char_label);

population = get_population(map_size, pop_type);
is_in_us = get_us_map(map_size);


for r = 1:length(range_values)
    switch(range_values(r))
        case 1,
            plot_scale = 1e6;
            options.colorbar_title = 'Mbps/person';
            options.scale = 200e6/plot_scale;
        case 10,
            plot_scale = 1e3;
            options.colorbar_title = 'kbps/person';
            options.scale = 900e3/plot_scale;
    end            
    
    options.filename = ['Thesis/MAC_RANGE_COMPARISON per_person range=' num2str(range_values(r)) ' km'];
    
    capacity_label = generate_label('capacity', capacity_type, range_type, ...
        range_values(r), population_type, char_label, noise_label, cell_model_label);
    
    total_capacity = get_total_capacity(capacity_label, fcc_exclusions_label);

    [cdf(r).X cdf(r).Y cdf(r).avg cdf(r).med] = ...
        calculate_cdf_from_map(total_capacity, population, is_in_us);
    
    total_capacity_capped = cap_to_val(total_capacity/plot_scale, .95*options.scale);
    make_map(total_capacity_capped, options);
end


close all;
lw = 2;
scale = 1e3;
scale_text = 'kbps';
figure; set(gcf, 'outerposition', [159         427        1095         425]);
for r = 1:length(range_values)
    loglog(cdf(r).X/scale, 1-cdf(r).Y, 'linewidth', lw);
    hold all;
end

axis tight; grid on;
legend(num2str(range_values'), 'location', 'southwest');
label_legend('    Range (km)');
xlabel(['Rate (' scale_text ')']);
ylabel('Fraction of population');

ax = axis;
axis([10 ax(2) 1e-9 1.5]);

scale_axes('x', 10.^(-4:10), 1);
scale_axes('y', 10.^(-14:2:0), 1);

save_plot('png', ['Thesis/MAC_RANGE_COMPARISON per_person ccdf'], 1);


% Zoomed version
axis([-inf inf 1e-4 1.5]);
% Add in lines measuring the curves
% for i = 1:3
%     switch(i)
%         case 1, mult = 1e4/2.5; expon = -.82;
%             text_x = 5*1e8;     text_y = 1e-3/2;
%         case 2, mult = 1e13*5;  expon = -2.17;
%             text_x = 1e7/1.5;     text_y = 1e0/5;
%         case 3, mult = 1e1*1.2; expon = -.34;
%             text_x = 1e9/7;     text_y = 1e-2*5;
%     end
%     ln(i) = loglog(cdf(1).X, mult*(cdf(1).X).^(expon));
%     text(text_x, text_y, ['t^{' num2str(expon) '}'], ...
%         'color', get(ln(i), 'color'), ...
%         'fontweight', 'bold', ...
%         'fontsize', 18);
% end
    

legend(num2str(range_values'), 'location', 'southwest');
label_legend('    Range (km)');

save_plot('png', ['Thesis/MAC_RANGE_COMPARISON per_person ccdf (zoom)'], 1);

%%  SINGLE-LINK RANGE COMPARISON P
clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
channels = ['tv-' get_simulation_value('tower_data_year')];
device_type = ['cr-' get_simulation_value('tower_data_year')];
population_type = get_simulation_value('pop_data_type');


% Parameters
capacity_type = 'single_user';
range_type = 'p';
range_values = [125 250 500 1000 2000 4000 8000 16000];
cr_haat = 30;
cr_power = 4;
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
fcc_exclusions_label = generate_label('fcc_mask', device_type, map_size);


% Load necessary data
population = get_population(map_size, population_type);
is_in_us = get_us_map(map_size);

cell_model_label = 'none';
char_label = generate_label('char', cr_haat, cr_power);


avg = zeros(size(range_values));
med = zeros(size(range_values));

for r = 1:length(range_values)    
    capacity_label = generate_label('capacity', capacity_type, range_type, ...
        range_values(r), population_type, char_label, noise_label, cell_model_label);
    
    total_capacity = get_total_capacity(capacity_label, fcc_exclusions_label);

    [cdfX cdfY avg(r) med(r)] = calculate_cdf_from_map(total_capacity, population, is_in_us);
end


close all;
lw = 2;
scale = 1e9;
scale_text = 'Gbps';
figure; set(gcf, 'outerposition', [159         427        1095         425]);
semilogx(range_values, avg/scale, 'linewidth', lw);
hold all;
semilogx(range_values, med/scale, 'linewidth', lw);
axis tight; grid on;
axis([-inf inf 0 inf]);
legend('Mean', 'Median', 'location', 'best');
xlabel('p');
ylabel(['Rate (' scale_text ')']);

scale_axes('x', range_values, 1);
scale_axes('y', 0:.2:5, 1);

% set(gcf,'PaperPositionMode','auto');
save_plot('png', ['Thesis/RANGE_COMPARISON_P'], 1);

%%  MAC RANGE COMPARISON P
clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
channels = ['tv-' get_simulation_value('tower_data_year')];
device_type = ['cr-' get_simulation_value('tower_data_year')];
population_type = get_simulation_value('pop_data_type');


% Parameters
capacity_type = 'per_person';
range_type = 'p';
range_values = [125 250 500 1000 2000 4000 8000 16000];
cr_haat = 30;
cr_power = 4;
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
fcc_exclusions_label = generate_label('fcc_mask', device_type, map_size);


% Load necessary data
population = get_population(map_size, population_type);
is_in_us = get_us_map(map_size);
colors = load('Data/colors.mat');

char_label = generate_label('char', cr_haat, cr_power);
cell_model_label = generate_label('mac_table', channels, char_label);


avg = zeros(size(range_values));
med = zeros(size(range_values));

for r = 1:length(range_values)
    capacity_label = generate_label('capacity', capacity_type, range_type, ...
        range_values(r), population_type, char_label, noise_label, cell_model_label);
    
    total_capacity = get_total_capacity(capacity_label, fcc_exclusions_label);

    [cdfX cdfY avg(r) med(r)] = calculate_cdf_from_map(total_capacity, population, is_in_us);
end


close all;
lw = 2;
scale = 1e3;
scale_text = 'kbps';
figure; set(gcf, 'outerposition', [159         427        1095         425]);
loglog(range_values, avg/scale, 'linewidth', lw);
hold all;
loglog(range_values, med/scale, 'linewidth', lw);
axis tight; grid on;
legend('Mean', 'Median', 'location', 'best');
xlabel('p');
ylabel(['Rate (' scale_text ')']);

scale_axes('x', range_values, 1);
scale_axes('y', [2 10 100], 1);

save_plot('png', ['Thesis/MAC_RANGE_COMPARISON_P'], 1);

%%  HEX RANGE COMPARISON P
clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
channels = ['tv-' get_simulation_value('tower_data_year')];
device_type = ['cr-' get_simulation_value('tower_data_year')];
population_type = get_simulation_value('pop_data_type');


% Parameters
capacity_type = 'per_person';
range_type = 'p';
range_values = [125 250 500 1000 2000 4000 8000 16000];
cr_haat = 30;
cr_power = 4;
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
fcc_exclusions_label = generate_label('fcc_mask', device_type, map_size);


% Load necessary data
population = get_population(map_size, population_type);
is_in_us = get_us_map(map_size);
colors = load('Data/colors.mat');

char_label = generate_label('char', cr_haat, cr_power);
cell_model_label = generate_label('hex', 'cellular', char_label);


avg = zeros(size(range_values));
med = zeros(size(range_values));

for r = 1:length(range_values)
    capacity_label = generate_label('capacity', capacity_type, range_type, ...
        range_values(r), population_type, char_label, noise_label, cell_model_label);
    
    total_capacity = get_total_capacity(capacity_label, fcc_exclusions_label);

    [cdfX cdfY avg(r) med(r)] = calculate_cdf_from_map(total_capacity, population, is_in_us);
end


close all;
lw = 2;
scale = 1e3;
scale_text = 'kbps';
figure; set(gcf, 'outerposition', [159         427        1095         425]);
loglog(range_values, avg/scale, 'linewidth', lw);
hold all;
loglog(range_values, med/scale, 'linewidth', lw);
axis tight; grid on;
legend('Mean', 'Median', 'location', 'best');
xlabel('People per tower');
ylabel(['Rate (' scale_text ')']);

scale_axes('x', range_values, 1);
scale_axes('y', [2 10 100 500], 1);

save_plot('png', ['Thesis/HEX_RANGE_COMPARISON_P'], 1);












%%                          ERODED FADE MARGINS

%%  SINGLE-USER ERODED FADE MARGIN

clc; clear all; close all;

% Model parameters
type = 'single_user';
range_type = 'r';
cr_haat = 30;
cr_power = 4;

% Get default values
map_size = get_simulation_value('map_size');
fade_margins = get_simulation_value('fade_margins');
population_type = get_simulation_value('pop_data_type');
tower_data_year = get_simulation_value('tower_data_year');

% Process model parameters
char_label = generate_label('char', cr_haat, cr_power);
noise_label = generate_label('noise', 'yes', map_size, ['tv-' tower_data_year], 'both');
cell_model_label = 'none';


% Load necessary data
colors = load('Data/colors.mat');


for range = [1 10]
% for range = 1
    
    capacity_label = generate_label('capacity', type, range_type, range, ...
        population_type, char_label, noise_label, cell_model_label);
    
    
    [~, med] = get_fade_margin_stacked_graph_data(capacity_label);
    
    scale = 1e9;
    scale_text = 'Gbps';
    make_area_graph( '', ...
        {fade_margins, med.yes_noise_all_excl.cr/scale, 'Lost to pollution'}, ...
        {fade_margins, med.yes_noise_coch_excl.cr/scale, 'Lost to cochannel exclusions'}, ...
        {fade_margins, med.yes_noise_no_excl*ones(size(fade_margins))/scale, 'Lost to adjacent channel exclusions'}, ...
        {fade_margins, med.no_noise_no_excl*ones(size(fade_margins))/scale, 'Remaining for secondaries', colors.light_gray} ...
        );
    
    xlabel('Eroded fade margin (dB)');
    ylabel([scale_text]);
    axis tight;
    ax = axis;
    axis([ax(1:3) ceil(ax(4)*1.05*2)/2]);
    
    save_plot('png', ['Thesis/FADE_MARGIN_SINGLE_LINK r=' num2str(range)]);
end

%%  MAC ERODED FADE MARGIN
clc; clear all; close all;

% Model parameters
type = 'per_person';
range_type = 'r';
cr_haat = 30;
cr_power = 4;

% Get default values
map_size = get_simulation_value('map_size');
fade_margins = get_simulation_value('fade_margins');
population_type = get_simulation_value('pop_data_type');
tower_data_year = get_simulation_value('tower_data_year');

% Process model parameters
char_label = generate_label('char', cr_haat, cr_power);
noise_label = generate_label('noise', 'yes', map_size, ['tv-' tower_data_year], 'both');
cell_model_label = generate_label('mac_table', 'tv', char_label);


% Load necessary data
colors = load('Data/colors.mat');


for range = [1 10]
    
    capacity_label = generate_label('capacity', type, range_type, range, ...
        population_type, char_label, noise_label, cell_model_label);
    
    [~, med] = get_fade_margin_stacked_graph_data(capacity_label);
    
            scale = 1e3;
            scale_text = 'kbps';
    make_area_graph( '', ...
        {fade_margins, med.yes_noise_all_excl.cr/scale, 'Lost to pollution'}, ...
        {fade_margins, med.yes_noise_coch_excl.cr/scale, 'Lost to cochannel exclusions'}, ...
        {fade_margins, med.yes_noise_no_excl*ones(size(fade_margins))/scale, 'Lost to adjacent channel exclusions'}, ...
        {fade_margins, med.no_noise_no_excl*ones(size(fade_margins))/scale, 'Remaining for secondaries', colors.light_gray} ...
        );
    
    xlabel('Eroded fade margin (dB)');
    ylabel([scale_text '/person']);
    
    legend('location', 'north');
    save_plot('png', ['Thesis/FADE_MARGIN_MAC r=' num2str(range)]);
end

%%  MAC, HEX ERODED FADE MARGIN P
clc; clear all; close all;

% Model parameters
type = 'per_person';
range_type = 'p';
range_value = 2000;
cr_haat = 30;
cr_power = 4;

% Get default values
map_size = get_simulation_value('map_size');
fade_margins = get_simulation_value('fade_margins');
population_type = get_simulation_value('pop_data_type');
tower_data_year = get_simulation_value('tower_data_year');

% Process model parameters
char_label = generate_label('char', cr_haat, cr_power);
noise_label = generate_label('noise', 'yes', map_size, ['tv-' tower_data_year], 'both');
% cell_model_label = generate_label('hex', 'cellular', char_label);


% Load necessary data
colors = load('Data/colors.mat');


for t = 1:2
    switch(t)
        case 1, type_text = 'MAC'; max_val = 70;
            cell_model_label = generate_label('mac_table', 'tv', char_label);
        case 2, type_text = 'HEX'; max_val = 300;
            cell_model_label = generate_label('hex', 'cellular', char_label);
    end
    
    
    capacity_label = generate_label('capacity', type, range_type, range_value, ...
        population_type, char_label, noise_label, cell_model_label);
    
    [~, med] = get_fade_margin_stacked_graph_data(capacity_label);
    
    scale = 1e3;
    scale_text = 'kbps';
    make_area_graph( '', ...
        {fade_margins, med.yes_noise_all_excl.cr/scale, 'Lost to pollution'}, ...
        {fade_margins, med.yes_noise_coch_excl.cr/scale, 'Lost to cochannel exclusions'}, ...
        {fade_margins, med.yes_noise_no_excl*ones(size(fade_margins))/scale, 'Lost to adjacent channel exclusions'}, ...
        {fade_margins, med.no_noise_no_excl*ones(size(fade_margins))/scale, 'Remaining for secondaries', colors.light_gray} ...
        );
    
    xlabel('Eroded fade margin (dB)');
    ylabel([scale_text '/person']);
        
    axis([-inf inf 0 max_val])
    legend('location', 'north')
    
    save_plot('png', ['Thesis/FADE_MARGIN_' type_text ' p=' num2str(range_value)]);
end



%%                          CHANNEL REMOVAL

%%  MAC CHANNEL REMOVAL
clc; clear all; close all;

% Model parameters
type = 'per_person';
range_type = 'r';
cr_haat = 30;
cr_power = 4;

% Get default values
map_size = get_simulation_value('map_size');
population_type = get_simulation_value('pop_data_type');
tower_data_year = get_simulation_value('tower_data_year');

% Process model parameters
char_label = generate_label('char', cr_haat, cr_power);
noise_label = generate_label('noise', 'yes', map_size, ['tv-' tower_data_year], 'both');
cell_model_label = generate_label('mac_table', 'tv', char_label);

for range = [1 10]
    scale = 1e3;
    scale_text = 'kbps';
    
    figure; hold all;
    for t = 1:2
        
        capacity_label = generate_label('capacity', type, range_type, range, ...
            population_type, char_label, noise_label, cell_model_label);
        
        ccdf_label = generate_label('ccdf_points', ['tv_removal-' num2str(t)], 'none', capacity_label);
        
        [avg, ~] = load_by_label(ccdf_label);
        
        plot(avg.cr/scale, avg.tv, '.-', 'linewidth', 2, 'markersize', 20);
        
    end
    grid on; grid minor;
    axis tight; ax = axis; axis([ax(1:3) ax(4)+1]);
    legend('No sharing', 'Sharing', 'location', 'southwest');
    xlabel(['Average rate to secondaries (' scale_text ')']);
    ylabel('Average # of channels available to TV viewers');
    
    % Add FCC point
    ccdf_label = generate_label('ccdf_points', 'fade_margin', 'fcc', capacity_label);
    [avg, ~] = load_by_label(ccdf_label);
    make_crosshair(avg.cr/scale, avg.tv, 'k', 2);
    
    save_plot('png', ['Thesis/TV_REMOVAL_MAC r=' num2str(range)]);
end

%%  MAC, HEX CHANNEL REMOVAL P
clc; clear all; close all;

% Model parameters
type = 'per_person';
range_type = 'p';
p = 2000;
cr_haat = 30;
cr_power = 4;

% Get default values
map_size = get_simulation_value('map_size');
population_type = get_simulation_value('pop_data_type');
tower_data_year = get_simulation_value('tower_data_year');

% Process model parameters
char_label = generate_label('char', cr_haat, cr_power);
noise_label = generate_label('noise', 'yes', map_size, ['tv-' tower_data_year], 'both');


% Load necessary data
colors = load('Data/colors.mat');

for t = 1:2
switch(t)
    case 1, type_text = 'MAC';
        cell_model_label = generate_label('mac_table', 'tv', char_label);
    case 2, type_text = 'HEX';
        cell_model_label = generate_label('hex', 'cellular', char_label);
end

    
    scale = 1e3;
    scale_text = 'kbps';
    
    figure; hold all;
    for t = 1:2
        
        capacity_label = generate_label('capacity', type, range_type, p, ...
            population_type, char_label, noise_label, cell_model_label);
        
        ccdf_label = generate_label('ccdf_points', ['tv_removal-' num2str(t)], 'none', capacity_label);
        
        [avg med] = load_by_label(ccdf_label);
        
        plot(avg.cr/scale, avg.tv, '.-', 'linewidth', 2, 'markersize', 20);
        
    end
    grid on; grid minor;
    axis tight; ax = axis; axis([ax(1:3) ax(4)+1]);
    legend('No sharing', 'Sharing', 'location', 'southwest');
    xlabel(['Average rate to secondaries (' scale_text ')']);
    ylabel('Average # of channels available to TV viewers');
    
    % Add FCC point
    ccdf_label = generate_label('ccdf_points', 'fade_margin', 'fcc', capacity_label);
    [avg, ~] = load_by_label(ccdf_label);
    make_crosshair(avg.cr/scale, avg.tv, 'k', 2);

    
%     save_plot('png', ['Thesis/TV_REMOVAL_' type_text ' p=' num2str(p)]);
%     pause;
end



%%                          CHANNEL REMOVAL AND FADE MARGINS

%%  SINGLE-LINK CHANNEL REMOVAL AND FADE MARGINS -- DEPRECATED
clc; clear all; close all;

% Model parameters
type = 'single_user';
range_type = 'r';
cr_haat = 30;
cr_power = 4;

lw = 2; % line width for plotting

% Get default values
map_size = get_simulation_value('map_size');
population_type = get_simulation_value('pop_data_type');
tower_data_year = get_simulation_value('tower_data_year');


% Process model parameters
char_label = generate_label('char', cr_haat, cr_power);
noise_label = generate_label('noise', 'yes', map_size, ['tv-' tower_data_year], 'both');
cell_model_label = 'none';


scale = 1e9;
scale_text = 'Gbps';


for range = [1 10]
    switch(range)
        case 1, legend_loc = 'southwest';
        case 10, legend_loc = 'northeast';
    end
    
    
    figure; hold all;
    
    
    % Add the TV removal case
    for t = 1:2
        
        capacity_label = generate_label('capacity', type, range_type, range, ...
            population_type, char_label, noise_label, cell_model_label);
        
        ccdf_label = generate_label('ccdf_points', ['tv_removal-' num2str(t)], 'none', capacity_label);
        
        [avg, ~] = load_by_label(ccdf_label);
        
        plot(avg.cr/scale, avg.tv, '.-', 'linewidth', lw, 'markersize', 20);
        
    end
    
    
    capacity_label = generate_label('capacity', type, range_type, range, ...
        population_type, char_label, noise_label, cell_model_label);
    
    [avg, ~] = get_fade_margin_stacked_graph_data(capacity_label);
    
    
    plot(avg.yes_noise_all_excl.cr/scale, avg.yes_noise_all_excl.tv, ...
        'linewidth', lw);
    plot(avg.yes_noise_coch_excl.cr/scale, avg.yes_noise_coch_excl.tv, ...
        'linewidth', lw);
%     plot(avg.yes_noise_no_excl.cr/scale, avg.yes_noise_no_excl.tv);
%     plot(avg.no_noise_no_excl.cr/scale, avg.no_noise_no_excl.tv);
    
    
    grid on; grid minor;
    min_y = floor(min(avg.yes_noise_coch_excl.tv));
    max_x = ceil(max(avg.yes_noise_coch_excl.cr/scale));
    axis tight; ax = axis; axis([ax(1) max_x min_y ax(4)+.5]);
    legend('TV removal, no sharing', 'TV removal, sharing', ...
        'FM, all excl.', 'FM, coch. excl. only', ...
        'location', legend_loc);
    xlabel(['Rate to secondaries (' scale_text ')']);
    ylabel('Channels available to TV viewers');
    
    % Add FCC point
    ccdf_label = generate_label('ccdf_points', 'fade_margin', 'fcc', capacity_label);
    [avg, ~] = load_by_label(ccdf_label);
    make_crosshair(avg.cr/scale, avg.tv, 'k', lw);

    
    save_plot('png', ['Thesis/TV_REMOVAL_AND_FADE_MARGINS_SINGLE_LINK r=' num2str(range)]);
    
end

%%  MAC CHANNEL REMOVAL AND FADE MARGINS
clc; clear all; close all;

% Model parameters
type = 'per_person';
range_type = 'r';
cr_haat = 30;
cr_power = 4;

lw = 2; % line width for plotting

% Get default values
map_size = get_simulation_value('map_size');
population_type = get_simulation_value('pop_data_type');
tower_data_year = get_simulation_value('tower_data_year');


% Process model parameters
char_label = generate_label('char', cr_haat, cr_power);
noise_label = generate_label('noise', 'yes', map_size, ['tv-' tower_data_year], 'both');
cell_model_label = generate_label('mac_table', 'tv', char_label);


scale = 1e3;
scale_text = 'kbps';


for range = [1 10]
    figure; hold all;
    
    
    % Add the TV removal case
    for t = 1:2
        
        capacity_label = generate_label('capacity', type, range_type, range, ...
            population_type, char_label, noise_label, cell_model_label);
        
        ccdf_label = generate_label('ccdf_points', ['tv_removal-' num2str(t)], 'none', capacity_label);
        
        [avg, med] = load_by_label(ccdf_label);
        
        plot(med.cr/scale, avg.tv, '.-', 'linewidth', lw, 'markersize', 20);
        
    end
    
    
    capacity_label = generate_label('capacity', type, range_type, range, ...
        population_type, char_label, noise_label, cell_model_label);
    
    [avg, med] = get_fade_margin_stacked_graph_data(capacity_label);
    
    
    plot(med.yes_noise_all_excl.cr/scale, avg.yes_noise_all_excl.tv, ...
        'linewidth', lw);
    plot(med.yes_noise_coch_excl.cr/scale, avg.yes_noise_coch_excl.tv, ...
        'linewidth', lw);
%     plot(avg.yes_noise_no_excl.cr/scale, avg.yes_noise_no_excl.tv);
%     plot(avg.no_noise_no_excl.cr/scale, avg.no_noise_no_excl.tv);
    
    
    grid on; grid minor;
    min_y = floor(min(avg.yes_noise_coch_excl.tv));
    max_x = max(med.yes_noise_coch_excl.cr/scale)+0.3;
    axis tight; ax = axis; axis([ax(1) max_x min_y ax(4)+.5]);
    legend('TV removal, no sharing', 'TV removal, sharing', ...
        'EFM, all excl.', 'EFM, coch. excl. only', ...
        'location', 'southwest');
    xlabel(['Median rate to secondaries (' scale_text ')']);
    ylabel('Average # of channels available to TV viewers');
    
    % Add FCC point
    ccdf_label = generate_label('ccdf_points', 'fade_margin', 'fcc', capacity_label);
    [avg, med] = load_by_label(ccdf_label);
    make_crosshair(med.cr/scale, avg.tv, 'k', lw);

    
    save_plot('png', ['Thesis/TV_REMOVAL_AND_FADE_MARGINS_MAC r=' num2str(range)]);
    
end

%%  MAC, HEX CHANNEL REMOVAL AND FADE MARGINS P
clc; clear all; close all;

% Model parameters
type = 'per_person';
range_type = 'p';
p = 2000;
cr_haat = 30;
cr_power = 4;

lw = 2; % line width for plotting

% Get default values
map_size = get_simulation_value('map_size');
fade_margins = get_simulation_value('fade_margins');
population_type = get_simulation_value('pop_data_type');
tower_data_year = get_simulation_value('tower_data_year');


% Process model parameters
char_label = generate_label('char', cr_haat, cr_power);
noise_label = generate_label('noise', 'yes', map_size, ['tv-' tower_data_year], 'both');


% Load necessary data
colors = load('Data/colors.mat');

for t = 1:2
switch(t)
    case 1, type_text = 'MAC';
        cell_model_label = generate_label('mac_table', 'tv', char_label);
    case 2, type_text = 'HEX';
        cell_model_label = generate_label('hex', 'cellular', char_label);
end

    
    scale = 1e3;
    scale_text = 'kbps';
    
    figure; hold all;
    
    
    
    % Add the TV removal case
    for t = 1:2
        
        capacity_label = generate_label('capacity', type, range_type, p, ...
            population_type, char_label, noise_label, cell_model_label);
        
        ccdf_label = generate_label('ccdf_points', ['tv_removal-' num2str(t)], 'none', capacity_label);
        
        [avg, med] = load_by_label(ccdf_label);
        
        plot(med.cr/scale, avg.tv, '.-', 'linewidth', lw, 'markersize', 20);
        
    end
    
    
    capacity_label = generate_label('capacity', type, range_type, p, ...
        population_type, char_label, noise_label, cell_model_label);
    
    [avg, med] = get_fade_margin_stacked_graph_data(capacity_label);
    
    
    plot(med.yes_noise_all_excl.cr/scale, avg.yes_noise_all_excl.tv, ...
        'linewidth', lw);
    plot(med.yes_noise_coch_excl.cr/scale, avg.yes_noise_coch_excl.tv, ...
        'linewidth', lw);
%     plot(avg.yes_noise_no_excl.cr/scale, avg.yes_noise_no_excl.tv);
%     plot(avg.no_noise_no_excl.cr/scale, avg.no_noise_no_excl.tv);
    

    
    
    
    grid on; grid minor;
    min_y = floor(min(avg.yes_noise_coch_excl.tv));
    max_x = ceil(max(med.yes_noise_coch_excl.cr/scale));
    axis tight; ax = axis; axis([ax(1) max_x min_y ax(4)+.5]);
    legend('TV removal, no sharing', 'TV removal, sharing', ...
        'EFM, all excl.', 'EFM, coch. excl. only', ...
        'location', 'southwest');
    xlabel(['Median rate to secondaries (' scale_text ')']);
    ylabel('Average # of channels available to TV viewers');
    
    % Add FCC point
    ccdf_label = generate_label('ccdf_points', 'fade_margin', 'fcc', capacity_label);
    [avg, med] = load_by_label(ccdf_label);
    make_crosshair(med.cr/scale, avg.tv, 'k', lw);

    
    save_plot('png', ['Thesis/TV_REMOVAL_AND_FADE_MARGINS_' type_text ' p=' num2str(p)]);
    
end













%%                          JAM FIGURES

%%  NEED MORE POWER THAN AREA CAN PROVIDE -- UNUSED
% Copied mostly from Toys/dyspan2012/cell_size_and_power.m

% Assumptions
clc; clear all; close all;

cr_haat = 30;
char_label = generate_label('char', cr_haat, 1);
hex_label = generate_label('hex', 'cellular', char_label);
[area_array] = load_by_label(hex_label);

target_rate = 1;
channel = 21;

noise = get_simulation_value('TNP');

% User at middle of cell, no max. range
cr_dist_to_tx = sqrt(area_array/pi)/2;
cr_signal = apply_path_loss(1, channel, cr_haat, cr_dist_to_tx)';
needed_powers = ((2.^(target_rate) - 1) .* (noise) ) ./ cr_signal;

loglog(area_array, needed_powers)
% %%
% 
% figure; plot(area_array, get_W_to_dBm(needed_powers));
% xlabel('Cell area (km^2)');
% ylabel('Power (dBm)');
% title('Necessary power');
% 
% figure; loglog(area_array, needed_powers./area_array);
% xlabel('Cell area (km^2)');
% ylabel('Power/area (W/km^2)');
% title('Necessary power per area');


%%  AVERAGE DREAM POWER
% Partially copied from
%   Toys/dyspan2011_final_buildup/fig_average_old_power.m

clc; clear all; close all;

% Model parameters
model_number = 1;   % Hotspot rules (but it doesn't matter for "dream power"
p = 2000;
bpsHz = 0.5;


% Secondary characteristics
power = 0;  % Not used in the jam model
height = 30;


% Default values
map_size = get_simulation_value('map_size');
tower_data_year = get_simulation_value('tower_data_year');
channels = ['tv-' tower_data_year];
population_type = get_simulation_value('pop_data_type');
visible = get_simulation_value('figure_visibility');


% % make_map(map, 'map_type', 'linear', 'colorbar_title', 'dBm/km^2', 'filename', filename, 'scale', 65);


% Specify plotting options
options.map_type = 'linear';
options.colorbar_title = 'dBm/km^2';
options.filename = 'Thesis/JAM DREAM_POWER average';
options.scale = 65;
options.visibility = visible;
options.state_outlines = 'on';




% Create labels
char_label = generate_label('char', height, power);
noise_label = generate_label('noise', 'yes', map_size, channels, 'both'); 

jam_label = generate_label('jam', 'power_map', model_number, 'none', ...
    population_type, tower_data_year, char_label, bpsHz, p, noise_label)

% Load data
[~, old_power_map] = load_by_label(jam_label);
is_in_us = get_us_map('200x300', 1);
old_power_map(~is_in_us) = 0/0;
old_power_map(old_power_map == 0) = 0/0;

map = squeeze(nanmean(old_power_map, 1));
map = get_W_to_dBm(map);
map(~is_in_us) = inf;

% Plot
make_map(map, options);

%%  REAL AND DREAM RATE MAPS + RATIOS + CCDFs: CELLULAR AND HOTSPOT (matched)
clc; clear all; close all;

% Model parameters
model_number_array = [2 3];   % Matched hotspot, cellular rules
p = 2000;
bpsHz = 0.5;
power_type_array = {'old_dream', 'new_power'};
    % Warning: if you change the order of the power_type_array, please also
    % change the code for the ratio map below.
stage = 'rate_map';


% Secondary characteristics
power = 0;  % Not used in the jam model
height = 30;


% Default values
map_size = get_simulation_value('map_size');
tower_data_year = get_simulation_value('tower_data_year');
channels = ['tv-' tower_data_year];
population_type = get_simulation_value('pop_data_type');
visible = get_simulation_value('figure_visibility');
is_in_us = get_us_map(map_size);
population = get_population(map_size, population_type);


% Specify plotting options
options.map_type = 'log';
options.visibility = visible;
options.state_outlines = 'on';
options.integer_labels = 'on';
options.auto_cap = 'on';




% Create labels
char_label = generate_label('char', height, power);
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');

for model_number = model_number_array
    for p_type = 1:length(power_type_array)
        power_type = power_type_array{p_type};
        switch(power_type)
            case 'old_dream',
                prefix = 'DREAM';
            case 'new_power',
                prefix = 'REAL';
        end
        
        jam_label = generate_label('jam', stage, model_number, power_type, ...
            population_type, tower_data_year, char_label, bpsHz, p, noise_label);
        
        
        
        switch(model_number)
            case 2, model_name = 'hotspot';
                scale = 1e9;
                label = 'Gbps';
                options.scale = 12;
                
                
            case 3, model_name = 'cellular';
                scale = 1e6;
                label = 'Mbps';
                options.scale = 700;
            otherwise, error('Unplanned model number.');
        end
        options.filename = ['Thesis/JAM ' prefix '_RATES ' model_name];
        options.colorbar_title = label;
        
        
        
        [fair_rate_map] = load_by_label(jam_label);
        map = aggregate_bands(fair_rate_map);
        maps{p_type} = map; % Save for ratio map later
        
        map(~is_in_us) = inf;
        map(is_in_us & isinf(map)) = options.scale * scale * .98;
        
        make_map(map/scale, options);
    end
    
    
    % Make CCDF of rates
    figure; set(gcf, 'outerposition', [159         427        1095         425]);
    
    for i = 1:2
        [cdfX cdfY] = calculate_cdf_from_map(maps{i}/scale, population, is_in_us);
        semilogx(cdfX, 1-cdfY, 'linewidth', 2);
        hold all;
    end

    grid minor;
    axis tight;
    axis([-inf inf 0 1.01]);
    legend('Dream rate', 'Real rate', 'location', 'best');
    xlabel(['Rate (' label ')']);
    ylabel('Fraction of population');
    save_plot('png', ['Thesis/JAM RATE_CCDF ' model_name], 1);
    
    
    % Make ratio map
    options.map_type = 'linear';
    options.filename = ['Thesis/JAM RATIO ' model_name];
    options.colorbar_title = 'Actual rate/dream rate';
    options.scale = [0:.2:1.3];
    options.integer_labels = 'off';
    
    
    ratio_map = maps{2}./maps{1};    
    ratio_map(~is_in_us) = inf;
    make_map(ratio_map, options);

    ratio_maps{model_number} = ratio_map;
    
end


% Make CCDF of ratios
figure; set(gcf, 'outerposition', [159         427        1095         425]);
for model_number = model_number_array
    [cdfX cdfY] = calculate_cdf_from_map(ratio_maps{model_number}, population, is_in_us);
    plot(cdfX, 1-cdfY, 'linewidth', 2);
    hold all;
end
grid minor;
axis([0.4 1.01 0 1.01]);
legend('Hotspot', 'Cellular', 'location', 'southwest');
xlabel(['Ratio']);
ylabel('Fraction of population');
save_plot('png', ['Thesis/JAM RATIO_CCDF'], 1);

%%  JAM OVER P (in progress)
clc; clear all; close all;

% Get default values
map_size = get_simulation_value('map_size');
tower_data_year = get_simulation_value('tower_data_year');
channels = ['tv-' tower_data_year];
device_type = ['cr-' get_simulation_value('tower_data_year')];
population_type = get_simulation_value('pop_data_type');


% Parameters
stage = 'rate_map';
power_type_array = {'old_dream', 'new_power'};
    % Warning: if you change the order of the power_type_array, please also
    % change the code for the ratio map below.
model_number_array = [2 3];   % Matched hotspot, cellular rules
p_values = [125 250 500 1000 2000 4000 8000 16000];
bpsHz = 0.5;
cr_haat = 30;
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
fcc_exclusions_label = generate_label('fcc_mask', device_type, map_size);


% Load necessary data
population = get_population(map_size, population_type);
is_in_us = get_us_map(map_size);
colors = load('Data/colors.mat');

char_label = generate_label('char', cr_haat, 0);
cell_model_label = generate_label('hex', 'cellular', char_label);



for model_number = model_number_array
    
    fig_per_cell = figure; set(gcf, 'outerposition', [159         427        1095         425]);
    fig_per_person = figure; set(gcf, 'outerposition', [159         427        1095         425]);

    
    for p_type = 1:length(power_type_array)
        power_type = power_type_array{p_type};
        switch(power_type)
            case 'old_dream',
                prefix = 'DREAM';
            case 'new_power',
                prefix = 'REAL';
        end
        
        avg = zeros(size(p_values));
        med = zeros(size(p_values));

        
        for r = 1:length(p_values)
            
            jam_label = generate_label('jam', stage, model_number, power_type, ...
                population_type, tower_data_year, char_label, bpsHz, p_values(r), noise_label);
            
            [fair_rate_map] = load_by_label(jam_label);
            total_capacity = aggregate_bands(fair_rate_map);

            [cdfX cdfY avg(r) med(r)] = calculate_cdf_from_map(total_capacity, population, is_in_us);
        end
        
        switch(model_number)
            case 2, model_name = 'hotspot';
                scale_1 = 1e9;
                label_1 = 'Gbps';
                scale_2 = 1e6;
                label_2 = 'Mbps';
            case 3, model_name = 'cellular';
                scale_1 = 1e6;
                label_1 = 'Mbps';
                scale_2 = 1e3;
                label_2 = 'kbps';
            otherwise, error('Unknown model number!');
        end
        
        
        figure(fig_per_cell);
        semilogx(p_values, avg/scale_1, 'linewidth', 2);
        hold all; grid on; axis tight;
        xlabel('People per cell');
        ylabel([label_1 '/cell']);
        legend('Dream rate', 'Real rate', 'location', 'best');
        scale_axes('x', p_values, 1);
        save_plot('png', ['Thesis/JAM RATE_OVER_P per_cell ' model_name], 1);
        
        
        figure(fig_per_person);
        semilogx(p_values, (avg./p_values)/scale_2, 'linewidth', 2);
        hold all; grid on; axis tight;
        xlabel('People per cell');
        ylabel([label_2 '/person']);
        legend('Dream rate', 'Real rate', 'location', 'best');
        scale_axes('x', p_values, 1);
        save_plot('png', ['Thesis/JAM RATE_OVER_P per_person ' model_name], 1);

    end
end
