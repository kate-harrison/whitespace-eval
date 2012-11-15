%% Collection of figures for the DySPAN 2011 paper

%% Figure 1: r_p difference
% rp drops from 108.5km to 97.4km with the addition of secondary
% transmitters. TV receivers at the speci?ed rp are safe in the presence of
% a single secondary user, but not surrounded by a sea of them.
display('Please see the file Miscellaneous/actual_rp.m to make this figure.');


%% Figure 2: TV channels lost
% Number of protected TV channels across the USA that could be lost due to
% interference from legally operating TV whitespace devices with one such
% device active for every 40 people.
display('Please see the file Miscellaneous/tv_reception_maps.m to make this fiugre.');


%% Figure 3: TV channels lost, effect of p
% The average (by population) number of protected TV channels lost because
% of aggregate interference as a function of the market-penetration of
% active ?xed whitespace devices. The upper curve represents what would
% happen if this particular fraction of devices were ordered to transmit
% and simply obeyed the order as long as the database authorized them to
% transmit. The lower curve further assumes that the devices obey a MAC
% protocol that prohibits two of them from simultaneously transmitting
% within 200 meters of each other.
display('Please run the code from Figure 2 to generate this figure.');


%% Figure 4: CCDF of US population density
% Population density varies greatly across the United States: more than 10
% percent of the population live in areas with more than 20 people per
% square kilometer and allsquare kilometer.
display('Please see the file Miscellaneous/us_pop_density.m to make this figure.');


%% Figure 5: hexagon illustration
% To translate from a continuous power density to discrete transmitters,
% each transmitter is given a footprint (here it is hexagonal). The
% transmitter?s power is then power/area ? area/transmitter. Note that we
% continue to use this hexagon model throughout. Each cell is assumed to be
% hexagonal with a transmitter at its center. In the cellular model, the
% users are placed uniformly at random within each cell. In the hotspot
% model, the users are placed uniformly at random within 100 meters of the
% access-point in the center.
display('Please see the file Miscellaneous/power_density_illustration.m to make this figure.');


%% Figure 6: cellular system, FCC rules (data rate)
% Hypothetical aggregate downlink data rates available within a
% cellular-style system operating under the FCC rules for TV whitespaces
% using ?xed devices with cells sized to contain 2000 people each. This
% assumes TVDB transmissions with 4W EIRP. Noticthe population densities
% are lower.
clc; clear all; close all;

model = 0;
bpsHz = 0.5;
p = 2000;
power_type = 'new_power';
stage = 'rate_map';
char_label = generate_label('char', 30, 0);
jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
make_jam(jam_label);
fig_rate_maps(jam_label);


%% Figure 7: cellular system, flat power density per channel (data rate)
% The downlink data rate per cell under a model of cells sized to have 2000
% people in them, and to use all available TV whitespace under almost the
% current FCC rules for ?xed devices. The difference is that instead of
% specifying a ?xed 4W for each TVBD, we have a ?at power-density for each
% channel. Big cells can therefore use more power without causing harmful
% interference.
clc; clear all; close all;

model = 1;
bpsHz = 0.5;
p = 2000;
power_type = 'flat3';
stage = 'rate_map';
char_label = generate_label('char', 30, 0);
jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
make_jam(jam_label);
fig_rate_maps(jam_label);


%% Figure 8: toy world illustration
% This is an illustration of the toy world used in the analytical section.
display('This figure was generated in Inkscape.');


%% Figure 9: gamma as a function of epsilon, d
% For the 1-dimensional toy: the approximation-factor ? as a function of
% the radius sacri?ced ?. The effect of the communication range d here is
% to require larger radii to be sacri?ced and also to reduce the
% approximation factor obtained. This is implicitly a tradeoff between the
% additive and multiplicative approximation qualities.

clc; clear all; close all;
alpha = 3.4;
epsilon_array = linspace(.1, 100, 100);
dist_array = [1 5 10 20];
gamma_array = linspace(0,1,1000);

gammas = zeros([length(epsilon_array) length(dist_array)]);
for i = 1:length(epsilon_array)
    for j = 1:length(dist_array)
        epsilon = epsilon_array(i);
        d = dist_array(j);
        
        val = 1./(1-gamma_array) .* (alpha - 1).^(-(1-gamma_array)) .* ...
            d.^(alpha * (1-gamma_array)) .* epsilon.^(-(1-gamma_array).*(alpha-1));
        
        max_gamma = max(gamma_array(val <= 1));
        if (isempty(max_gamma))
            max_gamma = 0;
        end
        gammas(i,j) = max_gamma;
    end
end

load('plot_parameters');
load('colors');
figure; set(gcf, 'outerposition', [903   364   560   493]);
plot(epsilon_array, gammas, 'linewidth', 3);
grid on;
axis xy;
xlabel('\epsilon');
ylabel('\gamma');

colors = get(gca, 'ColorOrder');
text(10, .83, 'd = 1', 'color', colors(1,:), 'fontsize', font_size, 'fontweight', 'bold')
text(23, .72, 'd = 5', 'color', colors(2,:), 'fontsize', font_size, 'fontweight', 'bold')
text(22, .53, 'd = 10', 'color', colors(3,:), 'fontsize', font_size, 'fontweight', 'bold')
text(48, .3, 'd = 20', 'color', colors(4,:), 'fontsize', font_size, 'fontweight', 'bold')

save_plot('png', 'analytical results');


%% Figure 10: average power density across the US
% The average (across whitespace channels) power density that every
% location is dreaming about if that location could choose a geographic-
% separation on a per-channel basis and a power-density on a per-channel
% basis so as to maximize the power available to it. Points far from TV
% towers dream about being able to use more power and telling those that
% are closer than them to be quiet. If everyone were to follow their dream,
% there would be a collapse of TV availability since the aggregate
% interference would overwhelm the system.
clc; clear all; close all;

map_size = get_simulation_value('map_size');
is_in_us = get_us_map(map_size, 1);

model_number = 1
p = 2000;
bpsHz = 0.5;
char_label = generate_label('char', 30, 0);
jam_label = generate_label('jam', 'power_map', model_number, 'none', char_label, bpsHz, p);

filename = generate_filename(jam_label);
file = load(filename);
power_type = 'old_power';
power_map = file.old_power_map;
power_map(~is_in_us) = 0/0;
power_map(power_map == 0) = 0/0;

map = squeeze(nanmean(power_map, 1));
map = get_W_to_dBm(map);

fig_type = 'power';
map(~is_in_us) = inf;

jam_label.power_type = 'old_power_map';     % If we just use generate_filename here, this won't show up in the filename
char_filename = generate_filename(jam_label.char_label);
switch(jam_label.hybrid)
    case true,
        p_string = jam_label.p_string;
    case false,
        p_string = num2str(jam_label.p);
end
fn = ['JAM ' jam_label.stage ' model=' num2str(jam_label.model) ' power=' jam_label.power_type ...
    ' (' char_filename ') tax=' num2str(jam_label.tax) ' p=' p_string]

make_map(map, 'map_type', 'linear', 'colorbar_title', 'dBm/km^2', 'filename', fn, 'scale', 65);


%% Figure 11: celluluar system, dreamed-of rates
% The impossible cellular data rates that results from the dreamed power
% map with dreamed-up interference assuming that everyone around them is
% exactly like them. This assumes one cell for every 2000 people.

clc; clear all; close all;

model = 1;
bpsHz = 0.5;
p = 2000;
power_type = 'old_dream';
stage = 'rate_map';
char_label = generate_label('char', 30, 0);
jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
make_jam(jam_label);
fig_rate_maps(jam_label);


%% Figure 12: dreamed-of average spectral efficiency
% The dreamed about average spectral ef?ciencies within the cellular model
% of Figure 11.
clc; clear all; close all;

% Get the rate map
p = 2000;
model = 1;
bpsHz = 0.5;
power_type = 'old_dream';
char_label = generate_label('char', 30, 0);
jam_label = generate_label('jam', 'rate_map', model, power_type, char_label, bpsHz, p);
filename = generate_filename(jam_label);
file = load(filename, 'fair_rate_map_nomedfilt');
rate = aggregate_bands(file.fair_rate_map_nomedfilt);


jam_label = generate_label('jam', 'power_map', model, power_type, char_label, bpsHz, p);
filename = generate_filename(jam_label);
file = load(filename);

excl = file.old_power_map ~= 0;

total_bw = aggregate_bands(excl) * get_simulation_value('bandwidth');

eff = rate ./ total_bw;

map_size = get_simulation_value('map_size');
is_in_us = get_us_map(map_size, 1);
eff(~is_in_us) = inf;

fn = 'model 1 old_dream spectral efficiency map';
make_map(eff, 'colorbar_title', 'bps/Hz', 'filename', fn, 'scale', 2.5);


%% Figure 13: hotspot rates with hotspot-oriented rules
% The hotspot downlink data-rates that result from a candidate
% approximately optimal power control rule that is implicitly aimed at ?xed
% interference-free links of 100 meters range. There is one access point
% for every 2000 people and the receivers do face interference from the
% other access points.
clc; clear all; close all;

model = 2;
bpsHz = 0.5;
p = 2000;
power_type = 'new_power';
stage = 'rate_map';
char_label = generate_label('char', 30, 0);
jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
make_jam(jam_label);
fig_rate_maps(jam_label);


%% Figure 14: cellular rates with hotspot-oriented rules
% The aggregate cell downlink data-rates that result from a candidate
% approximately optimal power control rule that is implicitly aimed at ?xed
% interference-free links of 100 meters range. Each cell contains 2000
% users and faces the actual interference that comes from everyone else.
clc; clear all; close all;

model = 1;
bpsHz = 0.5;
p = 2000;
power_type = 'new_power';
stage = 'rate_map';
char_label = generate_label('char', 30, 0);
jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
make_jam(jam_label);
fig_rate_maps(jam_label);


%% Figure 15: rate ratio for Figure 13
% The ratio of the rates actually delivered by the universal rule
% represented in Figure 13 to those legitimately dreamed about by each
% location.
display('Please run the code from Figure 13 to generate this figure.');


%% Figure 16: rate ratio for Figure 14
% The ratio of the cellular rates actually delivered by the universal rule
% represented in Figure 14 to those dreamed about.
display('Please run the code from Figure 14 to generate this figure.');


%% Figure 17: rate ratio - cellular rates with cellular-oriented rules
% The ratio to the dream of the cellular rates delivered by a second
% candidate approximately universal rule that ties the assumed
% communication range to the local population density.
clc; clear all; close all;

model = 3;
bpsHz = 0.5;
p = 2000;
power_type = 'new_power';
stage = 'rate_map';
char_label = generate_label('char', 30, 0);
jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
make_jam(jam_label);
fig_rate_maps(jam_label);


%% Figure 18: rate ratio - hotspot rates with cellular-oriented rules
% The ratio to the dream of the hotspot rates delivered by the second
% candidate universal rule that ties the assumed communication range to the
% local population density.
clc; clear all; close all;

model = 4;
bpsHz = 0.5;
p = 2000;
power_type = 'new_power';
stage = 'rate_map';
char_label = generate_label('char', 30, 0);
jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
make_jam(jam_label);
fig_rate_maps(jam_label);


%% Figure 19: rate ratio - cellular rates with cellular-oriented rules, smaller cells than anticipated
% What happens when we increase the penetration of cell towers to be one
% for every 125 people to the ratio to the dream of the cellular rates
% delivered by the second candidate approximately universal rule that ties
% the assumed communication range to the population density.
clc; clear all; close all;

model = 3;
bpsHz = 0.5;
p = '2000,125';
power_type = 'new_power';
stage = 'rate_map';
char_label = generate_label('char', 30, 0);
jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
make_jam(jam_label);
fig_rate_maps(jam_label);


%% Figure 20: CCDF of ratios
% CCDF of the ratios of achieved rates to dreamed-of rates, viewed from
% both the perspectives of population (solid lines) and area (dashed
% lines). Universal 1 is the universal rule that implicitly targets a ?xed
% range of 100 meters while Universal 2 is the rule that lets the targeted
% range vary with the local population density. The ?xed power density rule
% is the one from Figure 7, and the ?higher pop. density? curve is the one
% from Figure 19.

clc; clear all; close all;
figure; set(gcf, 'outerposition', [228   116   908   741]); 
hold on; grid on;
colors = 'rgbcmk';
lw = 3;


% POPULATION
type = 'population';
p = 2000;
bpsHz = 0.5;
stage = 'rate_map';
power_type = 'new_power';
char_label = generate_label('char', 30, 0);
for model = [2 4 3 1]
    jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
    [cdfX cdfY] = get_ratio_ccdf(jam_label, type);
    plot(cdfX, 1-cdfY, colors(model), 'linewidth', lw);
end

model = 3;
p = '2000,125';
jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
[cdfX cdfY] = get_ratio_ccdf(jam_label, type);
plot(cdfX, 1-cdfY, colors(5), 'linewidth', lw);

% AREA
type = 'area';
p = 2000;
model = 3;
power_type = 'flat3';
jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
[cdfX cdfY] = get_ratio_ccdf(jam_label, type);
plot(cdfX, 1-cdfY, [colors(6) '--'], 'linewidth', lw);

power_type = 'new_power';
for model = [1 3]
    jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
    [cdfX cdfY] = get_ratio_ccdf(jam_label, type);
    plot(cdfX, 1-cdfY, [colors(model) '--'], 'linewidth', lw);
end

model = 3;
p = '2000,125';

jam_label = generate_label('jam', stage, model, power_type, char_label, bpsHz, p);
[cdfX cdfY] = get_ratio_ccdf(jam_label, type);
plot(cdfX, 1-cdfY, [colors(5) '--'], 'linewidth', lw);


legend('Hotspot, universal 1', 'Hotspot, universal 2', 'Cellular, universal 2', 'Cellular, universal 1', ...
    'Cellular, universal 2, higher pop. density', 'Cellular, fixed power density', ...
    'location', 'best');
legend(gca, 'boxoff')
axis([0 1 0 1]);
xlabel('Ratio of achieved rate to dreamed of rate');
ylabel('Fraction of population [area]');
save_plot('png', 'CCDF of ratios');


%% Figure 21: effect of p on data rates
% Effect of p on rates per person and per cell
clc; clear all; close all;
char_label = generate_label('char', 30, 0);

percentiles = [.99 .9 .75 .5 .25 .10 .01];


% model = 1;
% jam_label = generate_label('jam', 'rate_map', model, 'new_power', char_label, 0.5, 0);
% [tower1 tower1_med tower1_perc p_array] = rate_over_p(jam_label, percentiles);
% 
% 
% model = 3;
% jam_label = generate_label('jam', 'rate_map', model, 'new_power', char_label, 0.5, 0);
% [tower3 tower3_med tower3_perc] = rate_over_p(jam_label, percentiles);


model = 3;
jam_label = generate_label('jam', 'rate_map', model, 'old_dream', char_label, 0.5, 0);
[tower3_dream tower3_dream_med tower3_dream_perc p_array] = rate_over_p(jam_label, percentiles);

% model = 3;
% jam_label = generate_label('jam', 'rate_map', model, 'flat3', char_label, 0.5, 0);
% [tower3_flat3 tower3_flat3_med tower3_flat3_perc] = rate_over_p(jam_label, percentiles);

model = 3;
jam_label = generate_label('jam', 'rate_map', model, 'new_power', char_label, 0.5, '2000,0');
[tower3_hybrid tower3_hybrid_med tower3_hybrid_perc] = rate_over_p(jam_label, percentiles);


figure; set(gcf, 'outerposition', [627   -11   817   868]);
load('plot_parameters');
lw = 3;

display_perc_idx = 4;

% Plot the values
colors = 'gmbcryk';
for i = [3 5]
    switch(i)
        case 1, map = tower1;
        case 2, map = tower3;
        case 3, map = tower3_dream;
        case 4, map = tower3_flat3;
        case 5, map = tower3_hybrid;
    end
    subplot(2,1,1); loglog(p_array, map/1e6, colors(i), 'linewidth', lw); hold on;
    subplot(2,1,2); loglog(p_array, (map./p_array)/1e3, colors(i), 'linewidth', 3); hold on;
end




% Top plot
subplot(2,1,1); grid on;
ylabel('Mbps/cell');
set(gca, 'fontsize', font_size);
xlhand = get(gca,'xlabel');
set(xlhand, 'fontsize',font_size);
ylhand = get(gca,'ylabel');
set(ylhand, 'fontsize',font_size);

yt = [40:5:100];
set(gca, 'ytick', yt, 'yticklabel', {num2str(yt')});
xt = p_array;
set(gca, 'xtick', xt, 'xticklabel', {num2str(xt')});
axis tight

text(1000, 79, 'Dreamed-of rate ', 'color', 'b', 'fontsize', font_size, 'fontweight', 'bold');
text(1500, 72, 'Universal rule 2 ', 'color', 'r', 'fontsize', font_size, 'fontweight', 'bold');

% Bottom plot
subplot(2,1,2); grid on;
xlabel('People per tower');
ylabel('kbps/person');
set(gca, 'fontsize', font_size);
xlhand = get(gca,'xlabel');
set(xlhand, 'fontsize',font_size);
ylhand = get(gca,'ylabel');
set(ylhand, 'fontsize',font_size);

yt = [1 10 100 500 1000];
set(gca, 'ytick', yt, 'yticklabel', {num2str(yt')});
xt = p_array;
set(gca, 'xtick', xt, 'xticklabel', {num2str(xt')});
axis tight

text(1100, 100, 'Dreamed-of rate ', 'color', 'b', 'fontsize', font_size, 'fontweight', 'bold');
text(610, 30, 'Universal rule 2 ', 'color', 'r', 'fontsize', font_size, 'fontweight', 'bold');


save_plot('png', 'Effect of p');



