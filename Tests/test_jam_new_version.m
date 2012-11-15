%% Test new jam

clc; clear all; close all;
tv_power = 100e3;
tv_haat = 500;
channel = 21;
cr_haat = 30;

% function [output] = get_jam_level(tv_power, tv_haat, channel, cr_haat)
% output.beta = beta;
% output.r_array = r_array;
% output.new_powers = power_per_area;
% output.old_powers = old_powers;
% output.old_rate = old_rate;
% output.test_rate = test_rate;
% output.new_rate = target_rate;
% output.rp = rp;
%
% Approximately 20 min to run for all towers
% Copied from Toys/dyspan2011/jam4.m on 24 Feb 2011

%% Set up the simulation

bpsHz = 0.5;

TNP = get_simulation_value('TNP');
rp = get_protection_radius(tv_power, channel, tv_haat, 3, TNP);

spacing = 10;
n = 3;
m = 10;

min_r = rp+0.1;
% max_r = rp + 750;
max_r = rp+10;
r_array = [min_r:spacing/m:(min_r+n*spacing) (min_r+(n+1)*spacing):spacing:max_r];

r_array = sort([r_array rp+13.7 rp+15]);

cr_dist_to_tx = 0.1;


%% Make our secondaries
r_inner = [min_r (r_array(1:end-1) + (spacing/m)/2)];
r_outer = [r_inner(2:end) r_inner(end)+spacing];

r_array = unique([r_inner r_outer(end)]);

% inner_diff = r_inner - rp
% outer_diff = r_outer - rp


if (cr_haat == 0)
    output = length(r_array)-1;
    return;
end

% Give more angular points to the inner circles than to the outer circles
% but guarantee 8 per circle
dist_to_rp = r_array - rp;
dist_to_rp = floor(dist_to_rp/10);
num_theta = 256./(2.^dist_to_rp);
num_theta = max(num_theta, 8);

num_points = sum(num_theta);
r = zeros(1, num_points);
theta = zeros(1, num_points);
r_index = zeros(size(r_array));
for i = 1:length(r_array)
    if i > 1
        r_index(i) = r_index(i-1) + num_theta(i-1);
    else
        r_index(i) = 1;
    end
    
    r(r_index(i):r_index(i)+num_theta(i)-1) = r_array(i);
    theta_array = linspace(0, 2*pi, num_theta(i)+1);
    theta_array = theta_array(1:end-1);
    theta(r_index(i):r_index(i)+num_theta(i)-1) = theta_array;
end
dist_to_tv_rx = polar_distance(r, rp, theta, 0);
rp_fractions = apply_path_loss(1, channel, cr_haat, dist_to_tv_rx);

ring_areas = pi*r_outer.^2 - pi*r_inner.^2;


master.r_index = r_index;
master.theta = theta;
master.r = r;
master.rp_fractions = rp_fractions;
master.ring_areas = ring_areas;
master.num_theta = num_theta;
master.num_points = num_points;
master.r_array = r_array;
master.dist_to_tv_rx = dist_to_tv_rx;

% r_diff = mean([r_inner; r_outer], 1)-rp

%% Check to see if the positioning and areas are correct
if 1
    figure; set(gcf, 'outerposition', [288   110   577   747]);
    subplot(2,1,1); hold on;
    c = [0 0];
    circle(c, rp, 50, 'g');
    for i = 1:length(r_inner)
        circle(c, r_inner(i), 40, 'b-');
    end
    for i = 1:length(r_outer)
        circle(c, r_outer(i), 50, 'r-');
    end
    [x y] = pol2cart(theta, r);
    scatter(x,y, 50);
    axis([.9*min_r, 1.1*max_r, -50 50])
    
    subplot(2,1,2); hold on;
    plot(r_inner, '.-');
    plot(r_outer, 'r.-');
    plot(r_array(2:end), 'go', 'markersize', 10);
    plot(r_array(1), 'go', 'markersize', 10);
    legend('r inner', 'r outer', 'r array', 'location', 'southeast');
    
    
    figure; set(gcf, 'outerposition', [866   113   571   744]);
    subplot(3,2,1);
    plot(r, '.-');
    title('r');
    
    subplot(3,2,2);
    plot(theta, '.-');
    title('theta');
    
    subplot(3,2,3);
    plot(ring_areas, '.-');
    title('ring areas');
    
    %     subplot(3,2,4);
    %     plot(tower_areas, '.-');
    %     title('tower areas');
    
    subplot(3,2,5);
    plot(r_index, '.-');
    title('r index');
    grid on;
    
end
%%


for ivo = 1:2
    
    % This helps reduce errors
    clear r_index theta r rp_fractions num_theta ...
        num_points r_array dist_to_tv_rx
    
    switch(ivo)
        case 1, % outer
            short_idcs = 2:length(master.r_array);
            long_idcs = master.r_index(2):length(master.r);
            
            r_index = master.r_index(short_idcs) - master.r_index(2) + 1;
            
        case 2, % inner
            short_idcs = 1:length(master.r_array)-1;
            long_idcs = master.r_index(1):master.r_index(length(master.r_index-1))-1;
            
            r_index = master.r_index(short_idcs);
    end
    
    num_theta = master.num_theta(short_idcs);
    rp_fractions = master.rp_fractions(long_idcs);
    num_points = sum(num_theta);
    r_array = master.r_array(short_idcs);
        
    tower_areas = ring_areas ./ num_theta;
    
%% Check to see if the positioning and areas are correct
%     if 0
%         figure; set(gcf, 'outerposition', [288   110   577   747]);
%         subplot(2,1,1); hold on;
%         c = [0 0];
%         circle(c, rp, 50, 'g');
%         for i = 1:length(r_inner)
%             circle(c, r_inner(i), 40, 'b-');
%         end
%         for i = 1:length(r_outer)
%             circle(c, r_outer(i), 50, 'r-');
%         end
%         [x y] = pol2cart(theta, r);
%         scatter(x,y, 50);
%         axis([.9*min_r, 1.1*max_r, -50 50])
%         
%         subplot(2,1,2); hold on;
%         plot(r_inner, '.-');
%         plot(r_outer, 'r.-');
%         plot(r_array(2:end), 'go', 'markersize', 10);
%         plot(r_array(1), 'go', 'markersize', 10);
%         legend('r inner', 'r outer', 'r array', 'location', 'southeast');
%         
%         
%         figure; set(gcf, 'outerposition', [866   113   571   744]);
%         subplot(3,2,1);
%         plot(r, '.-');
%         title('r');
%         
%         subplot(3,2,2);
%         plot(theta, '.-');
%         title('theta');
%         
%         subplot(3,2,3);
%         plot(ring_areas, '.-');
%         title('ring areas');
%         
%         subplot(3,2,4);
%         plot(tower_areas, '.-');
%         title('tower areas');
%         
%         %     subplot(3,2,5);
%         %     plot(r_index, '.-');
%         %     title('r index');
%         %     grid on;
%         
%         subplot(3,2,5);
%         plot(rp_fractions, '.-');
%         title('rp fractions');
%         grid on;
%         
%         
%         subplot(3,2,6);
%         plot(r_array, '.-');
%         title('r array');
%         grid on;
%         
%     end
%%
    
    %% Find old powers
    
    max_noise = TNP;
    
    tower_areas2 = short_to_long(tower_areas, r_index, num_points);
    new_fractions = tower_areas2 .* rp_fractions';
    total_int = fliplr(cumsum(fliplr(new_fractions)));
    total_int = total_int(r_index);
    max_power = max_noise ./ total_int; % this is power per area!
    
    old(ivo).power = max_power;
    
    switch(ivo)
        case 1, output.old_power1 = max_power;
        case 2, output.old_power2 = max_power;
    end
    clear max_power
    
end

% Keep rp_fractions the same since now it is in the inner case (=>
% conservative calculation of new power)
% num_points, r_index, etc. also fall into this category

% We saw that old_power in dBm should be the average of the inner and
% outer old powers in dBm
% 1 = outer, 2 = inner
outer = get_W_to_dBm(old(1).power);
inner = get_W_to_dBm(old(2).power);
old_powers = get_dBm_to_W(mean([outer; inner], 1)); % don't forget, we have to go back to W at the end


%% Find old rates
% What's the old rate they're getting?

cr_signal = apply_path_loss(1, channel, cr_haat, cr_dist_to_tx);

% total power = (power/area) * area
wifi_power = old_powers .* (pi*cr_dist_to_tx^2); % scale power based on the amount of jam you scoop up


% Make old rate 1 - clean, range = 100m
noise = TNP;
old_rate = log2(1 + cr_signal.* wifi_power ./ noise);


% Make old rate 2 - TV noise, range = 100m
dist_to_tv_tx = r_array;
noise = TNP + apply_path_loss(tv_power, channel, tv_haat, dist_to_tv_tx)';
test_rate = log2(1 + cr_signal.*wifi_power ./ noise);

idcs = test_rate <= bpsHz;
% old_powers(idcs) = 0;  % zero out those who haven't met the requirement -- we can do this later if necessary
old_rate(idcs) = 0;



%% Find new powers, new rates
beta_min = 0;
beta_max = 1;

tv_signal = tv_apply_path_loss(tv_power, channel, tv_haat, rp);
target_snr = 15;

beta_stop = 0;
iterations = 0;
max_iterations = 20;
while (~beta_stop && iterations < max_iterations)
    beta = mean([beta_min, beta_max]);
    
    target_rate = beta*old_rate - bpsHz;
    target_rate(idcs) = 0;
    
    
    % power/(wifi tower)
    wifi_power = ((2.^(target_rate) - 1) .* (TNP) ) / cr_signal;
    
    % power/area = (power/tower) / (area/tower)
    power_per_area = wifi_power ./ (pi*cr_dist_to_tx^2);
    
    % set the last three to be equal
    power_per_area(end-1:end) = ones(1,2) * power_per_area(end-2);
    
    % now scale back to power/tower
    % power/tower = power/area * area/tower
    jam_tower_power = power_per_area .* tower_areas;
    
    
    % Check TV SNR condition
    new_powers_long = short_to_long(jam_tower_power, r_index, num_points);
    total_tv_interference = sum(new_powers_long'.*rp_fractions);
    tv_snr_at_rp = 10*log10( tv_signal / (total_tv_interference + TNP) );
    
    if (tv_snr_at_rp > target_snr)
        beta_min = beta;
    else
        beta_max = beta;
    end
    beta_stop = ( (tv_snr_at_rp - target_snr) < 0.05) && (tv_snr_at_rp - target_snr) > 0;
    
    iterations = iterations + 1;
end

if (iterations == max_iterations && abs(beta-1)>2^-max_iterations && abs(beta)>2^-max_iterations)
    display('Warning: hit the maximum number of iterations before converging');
end


output.beta = beta;
% output.r_array = r_array;
output.r_array = mean([r_inner; r_outer], 1);
output.new_powers = power_per_area;
output.old_powers = old_powers;
output.old_rate = old_rate;
output.test_rate = test_rate;
output.new_rate = target_rate;
output.rp = rp;



% end
