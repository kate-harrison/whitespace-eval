function [] = make_jam(jam_label)
%   [] = make_jam(jam_label)

switch(jam_label.label_type)
    case 'jam',
    otherwise,
        error(['Unsupported mode: tried to run make_jam() with ' ...
            'label of type ' jam_label.label_type]);
end

% If we don't need to compute, exit now
if (get_compute_status(jam_label) == 0)
    return;
end


% Copy to a shorter variable name for readability
jl = jam_label;

% Add an exception for the hybrid case
if (jl.hybrid)
    p_val = jl.p1;    % Use p1 for the hybrid case
else
    p_val = jl.p;
end


%% Create chan_data jam label (uses first p for hybrid case)
if (any(string_is(jl.stage, {'chan_data', 'power_map', 'rate_map'})) && jl.model ~= 0)
    jam_labels.chan_data = generate_label('jam', 'chan_data', jl.model, ...
        jl.power_type, jl.population_type, jl.tower_data_year, ...
        jl.char_label, jl.tax, p_val, jl.noise_label);

    fprintf(['\n  CHAN_DATA stage:  ' generate_filename(jam_labels.chan_data) '\n']);
    
    make_jam_chan_data(jam_labels.chan_data);

end


%% Create power_map jam label (also uses first p for hybrid case)
if any(string_is(jl.stage, {'power_map', 'rate_map'}))
    jam_labels.power_map = generate_label('jam', 'power_map', jl.model, ...
        jl.power_type, jl.population_type, jl.tower_data_year, ...
        jl.char_label, jl.tax, p_val, jl.noise_label);
    
    fprintf(['\n\n  POWER_MAP stage:  ' generate_filename(jam_labels.power_map) '\n']);
    
    make_jam_power_maps(jam_labels);
    
end


%% Create rate_map jam label (requires both p values for hybrid case)
if any(string_is(jl.stage, {'rate_map'}))
    jam_labels.rate_map = generate_label('jam', 'rate_map', jl.model, ...
        jl.power_type, jl.population_type, jl.tower_data_year, ...
        jl.char_label, jl.tax, jl.p, jl.noise_label);

    fprintf(['\n\n  RATE_MAP stage:  ' generate_filename(jam_labels.rate_map) '\n']);
    
    make_jam_rates(jam_labels);
end




end


function [] = make_jam_power_maps(jam_labels)

jam_label = jam_labels.power_map;




map_size = jam_label.noise_label;
tower_data_year = jam_label.tower_data_year;


%% Model 0 case
if (jam_label.model == 0)   % Make the model 0 data
    
    pop_type = jam_label.population_type;
    
    
    p = jam_label.p;
    power_per_tower = jam_label.char_label.power
    
    % Load necessary data
    chan_list = get_simulation_value('chan_list');
    population_density = get_pop_density(map_size, pop_type, 1);
    us_area = get_us_area(map_size);
    is_in_us = get_us_map(map_size, length(chan_list));
    
    
    
    tower_area = p ./ population_density;
    towers_per_pixel = us_area ./ tower_area;
    power_map = towers_per_pixel * power_per_tower;
    power_map = power_map ./ us_area;   % need to return to power per area since that's what the code below expects
    power_map = shiftdim(repmat(power_map, [1 1 length(chan_list)]),2);
    
    
    
    % Apply exclusions
    fcc_label = generate_label('fcc_mask', ['cr-' jam_label.tower_data_year], map_size);
    fcc_mask = load_by_label(fcc_label);
    power_map = power_map .* fcc_mask;
    power_map(~is_in_us) = 0;
    
    
    save_data(save_filename(jam_label));
    return;
end





%% Regular case
jam_label_chan_data = jam_labels.chan_data;

[old_powers new_powers r_arrays betas chan_data chan_data_indices] = ...
    load_by_label(jam_label_chan_data);




% We don't trust the last 150 km (15 entries) of old_powers, etc. so we
% remove them
old_powers(:, end-15:end) = [];
new_powers(:, end-15:end) = [];
r_arrays(:, end-15:end) = [];


% In future code, we interpolate between power densities allowed at
% different radii. Here, we add a 0-power-density entry at r_p for each
% tower so that interpolation works properly *and* power is zeroed out
% inside of r_p (for extra certainty, we also use the exclusion mask we
% just created).
rp_list = chan_data(:, chan_data_indices.fcc_rp_idx);
r_arrays = ([rp_list'; r_arrays'])';    % Add an entry at rp for each tower
new_powers = ([zeros(size(rp_list))'; new_powers'])';   % Put zero power here
old_powers = ([zeros(size(rp_list))'; old_powers'])';   % Put zero power here


% Make the regular jam (varies based on distance to TV towers)
[new_power_map old_power_map flat_power_map1 flat_power_map2 beta_map] = ...
    make_jam_maps(chan_data, chan_data_indices, betas, r_arrays, new_powers, old_powers, map_size);

%         save_data(filename);

% Make flat jam 3 which is the minimum of all allowed powers outside of
% r_p across the US (on a per-channel basis)


% Create a mask of cochannel-only locations inside of r_p
chan_list = get_simulation_value('chan_list');
fccl = generate_label('fcc_mask', ['tv-' tower_data_year], map_size);
is_in_us = get_us_map(map_size, length(chan_list));
excl_mask = load_by_label(fccl);
fcc_cochannel_only_excl_mask = ~excl_mask & is_in_us;

% Apply to new_power_map and old_power_map
new_power_map = new_power_map .* fcc_cochannel_only_excl_mask;
old_power_map = old_power_map .* fcc_cochannel_only_excl_mask;



flat_power_map3 = flat_power_map1;  % Voronoi version
flat_power3 = zeros(size(chan_list));
for i = 1:length(chan_list)
    layer = flat_power_map3(i,:,:);
    layer(layer == 0) = 0/0;
    flat_power3(i) = nanmin(nanmin(layer));
    
    flat_power_map3(i,:,:) = fcc_cochannel_only_excl_mask(i,:,:) * flat_power3(i);
end

% Now we have a list of the powers used across the channel and a map
% with FCC rp (not rn) exclusions only
dB_boost = get_simulation_value('dB_leak');
flat_power3_boost = flat_power3 * 10^(dB_boost/10);    % 40dB boost
if (any(flat_power3 > flat_power3_boost))
    warning('Flat power 3 exclusions are not enough.');
end

% Save unexcluded versions
cochannel_exclusions_only.new_power_map = new_power_map;
cochannel_exclusions_only.old_power_map = old_power_map;
cochannel_exclusions_only.flat_power_map1 = flat_power_map1;
cochannel_exclusions_only.flat_power_map2 = flat_power_map2;
cochannel_exclusions_only.flat_power_map3 = flat_power_map3;

[new_power_map adj_restrictions.new_power_map] = apply_power_map_exclusions(new_power_map);
[old_power_map adj_restrictions.old_power_map] = apply_power_map_exclusions(old_power_map);
%     [flat_power_map1 adj_restrictions.flat_power_map1] = apply_power_map_exclusions(flat_power_map1);
%     [flat_power_map2 adj_restrictions.flat_power_map2] = apply_power_map_exclusions(flat_power_map2);
%     [flat_power_map3 adj_restrictions.flat_power_map3] = apply_power_map_exclusions(flat_power_map3);


% Apply FCC exclusions because that's what flat jam assumes
fcc_label = generate_label('fcc_mask', ['cr-' tower_data_year], map_size);
fcc_mask = load_by_label(fcc_label);

flat_power_map1 = flat_power_map1 .* fcc_mask;
flat_power_map2 = flat_power_map2 .* fcc_mask;
flat_power_map3 = flat_power_map3 .* fcc_mask;



save_data(save_filename(jam_label));




end



function [new_power_map old_power_map flat_power_map1 flat_power_map2 beta_map] = make_jam_maps(chan_data, chan_data_indices, betas, r_arrays, new_powers, old_powers, map_size)



chan_list = get_simulation_value('chan_list');
cochannel_separation_dist = get_simulation_value('cochannel_separation_distance');
[is_in_us lat_coords long_coords] = get_us_map(map_size, length(chan_list));
default_mask = is_in_us;



chan_no_idx = chan_data_indices.chan_no_idx;
lat_idx = chan_data_indices.lat_idx;
long_idx = chan_data_indices.long_idx;
fcc_rp_idx = chan_data_indices.fcc_rp_idx;


beta_map = default_mask * 2;
max_distances = max(r_arrays, [], 2); % same as r_arrays(:, end)

new_power_map = default_mask * 0;
old_power_map = default_mask * 0;
flat_power_map1 = default_mask * 0;
flat_power_map2 = default_mask * 0;

% tic
for i = 1:length(chan_list)
%     tic
    
    % Note: we can't actually skip channels 3 and 4 because it will kill
    % our power in future channels due to the way that power map exclusions
    % are calculated
    
    display(['Current channel: ' num2str(chan_list(i))]);
    
    % Select only those transmitters on the current channel
    tx_indices = chan_data(:, chan_no_idx) == chan_list(i);
    tx_list = chan_data(tx_indices, :);
    beta_list = betas(tx_indices);
    max_dist_list = max_distances(tx_indices);
    new_power_list = new_powers(tx_indices, :);
    old_power_list = old_powers(tx_indices, :);
    r_list = r_arrays(tx_indices, :);
    rp_list = chan_data(tx_indices, fcc_rp_idx);
    
    
    % For each point in the US...
    for j = 1:length(lat_coords)
        for k = 1:length(long_coords)
            
            if (default_mask(i,j,k) == 0)
                continue;       % Skip points outside the US
            end
            
            
            
            % Check protection radii for this channel
            distance = latlong_to_km(tx_list(:, lat_idx), tx_list(:, long_idx), lat_coords(j), long_coords(k));
            
            dist_diff = distance - rp_list;
%             if (any(dist_diff<0))
%                 warning('Somehow we are inside rp -- check beta calculations');
%             end
            [Y,I] = min(abs(dist_diff));
            beta_map(i,j,k) = beta_list(I);     % use the beta from the nearest tower
            
            
            
            
            [Y,I] = min(distance);
            
            
            [flat_idx Y] = find_closest(cochannel_separation_dist, r_list(I,:) - rp_list(I));
            if (abs(Y - cochannel_separation_dist) > 0.01)
                warning('Did not find exact match for rp+(coch. sep. dist.)');
            end
            flat_power_map1(i,j,k) = old_power_list(I, flat_idx);
            
            
            % Fill in the background
            flat_power_map2(i,j,k) = flat_power_map1(i,j,k);
            
            
            [Y,I] = min(distance);
            n = find_closest(Y, r_list(I,:));
            new_power_map(i,j,k) = new_power_list(I, n);
            old_power_map(i,j,k) = old_power_list(I, n);
            
            
            
            % Figure out the max. power allowed when we are within range of
            % a tower
            sub_indices = distance <= max_dist_list;
            if sum(sub_indices) > 0
                flat_power_map2(i,j,k) = min(old_power_list(sub_indices, flat_idx));
                
                sub_distances = distance(sub_indices);
                sub_power_list = new_power_list(sub_indices, :);
                sub_old_power_list = old_power_list(sub_indices, :);    % new
                sub_r_list = r_list(sub_indices, :);
                power_allowed = inf;
                old_power_allowed = inf;    % new
                for m = 1:sum(sub_indices)
                    % Note that we have altered the original data so that
                    % we have an r_array entry at rp with 0 power so that
                    % the interpolation will work well
                    
                    
                    % Now, we linearly interpolate for each option
                    [low_idx high_idx low_val high_val] = find_surrounding(sub_distances(m), sub_r_list(m,:));
                    new_pow = lin_interp(low_val, sub_power_list(m, low_idx), sub_distances(m), high_val, sub_power_list(m, high_idx));
                    power_allowed = min(power_allowed, new_pow);
                    old_pow = lin_interp(low_val, sub_old_power_list(m, low_idx), sub_distances(m), high_val, sub_old_power_list(m, high_idx));
                    old_power_allowed = min(old_power_allowed, old_pow);
                    
                    % Example of how we used log interp (inputs are in the
                    % same format for lin interp) in the data rate
                    % calculations -- unfortunately, documentation is
                    % currently lacking for this function
                    %  log_interp(area_array(low_idx), noise(low_idx,:), tower_area, area_array(high_idx), noise(high_idx,:));
                    
                    
                    %                     % This is the old way where we snapped to the nearest
                    %                     % power available
                    %                     idx = find_closest(sub_distances(m), sub_r_list(m, :));
                    %                     power_allowed = min(power_allowed, sub_power_list(m, idx));
                    %                     old_power_allowed = min(old_power_allowed, sub_old_power_list(m, idx));
                end
                new_power_map(i,j,k) = power_allowed;
                old_power_map(i,j,k) = old_power_allowed;   % new
                %             else
                %                 power_map(i,j,k) = 0;
            end
            
        end
    end
    
    
%     toc
end


end




function [] = make_jam_chan_data(jam_label)

% If we don't need to compute, exit now
if (get_compute_status(jam_label) == 0)
    return;
end



% map_size = jam_label.noise_label;
% pop_type = jam_label.population_type;
pop_year = jam_label.population_year;
tower_year = jam_label.tower_data_year;
% pop_density_map = get_pop_density(map_size, pop_type, 1);
% [is_in_us lat_coords long_coords] = get_us_map(map_size, 1);
[~, pop_densities] = get_tower_nearby_pops(pop_year, tower_year);


% Load the chan_data
[chan_data chan_data_indices] = get_tower_data(tower_year);
chan_data_indices.pop_density_idx = max(cell2mat(struct2cell(chan_data_indices))) + 1;

num_points = get_jam_level(jam_label, 1e3, 100, 21, 0, 0);    % with rp = 0, this will give us the number of points in r_array
r_arrays = zeros(length(chan_data), num_points);
new_powers = zeros(length(chan_data), num_points);
old_powers = zeros(length(chan_data), num_points);
betas = zeros(length(chan_data), 1);


max_channel = max(get_simulation_value('chan_list'));


for k = 1:length(chan_data)
    % for k = 1027
    
    if (mod(k, 10) == 0)
        display(['Working on tower ' num2str(k) ' out of ' num2str(length(chan_data))]);
    end
    
    power = chan_data(k, chan_data_indices.erp_idx)*1e3;   % to W from kW
    channel = chan_data(k, chan_data_indices.chan_no_idx);
    rp = chan_data(k, chan_data_indices.fcc_rp_idx);
    ht = chan_data(k, chan_data_indices.haat_idx);
    
    % Skip those TV towers in our database which are not on the channels we
    % care about
    if (channel > max_channel)
        continue;
    end
    
    
    
    
    % Find the local population density
    pop_density = pop_densities(k);
    %     [LONG LAT] = meshgrid(long_coords, lat_coords);
    %     distances = latlong_to_km(LAT, LONG, chan_data(k, chan_data_indices.lat_idx), ...
    %         chan_data(k, chan_data_indices.long_idx));
    %     limit = rp;
    %     pop_density = 0;
    %     while (isnan(pop_density) || pop_density == 0)
    %         idcs = (distances <= limit);
    %         pop_density = mean(pop_density_map(idcs));
    %         limit = limit + 10;
    %     end
    % Save the local population density
    chan_data(k, chan_data_indices.pop_density_idx) = pop_density;
    
    % Find the jam level for this tower
    out = get_jam_level(jam_label, power, ht, channel, pop_density, rp);
    
    % Save the jam level
    betas(k) = out.beta;
    r_arrays(k,:) = out.r_array;
    new_powers(k,:) = out.new_powers;
    old_powers(k,:) = out.old_powers;
    
end



save_data(save_filename(jam_label), 'chan_data', 'chan_data_indices', 'betas', ...
    'r_arrays', 'new_powers', 'old_powers');

end



% This function calculates the power per area allowed at each radius from a
% particular TV tower.
function [output] = get_jam_level(jam_label, tv_power, tv_haat, channel, pop_density, rp)


model_number = jam_label.model;
p = jam_label.p;
bpsHz = jam_label.tax;
cr_haat = jam_label.char_label.height;

cochannel_separation_dist = get_simulation_value('cochannel_separation_distance');

% Copied from Toys/dyspan2011/jam4.m on 24 Feb 2011
% Cleaned up on 24 May 2011
% Changed to general version for cochannel separation dist. on 11 June 2013

%% Set up the simulation

TNP = get_simulation_value('TNP');
% rp = get_protection_radius(tv_power, channel, tv_haat, 3, TNP);

spacing = 10;
n = 3;
m = 10;

% if (model_number == 5)
%     min_r = rp+14.15;
% else
min_r = rp+0.1;
% end
max_r = rp + 750;
r_array = [min_r:spacing/m:(min_r+n*spacing) (min_r+(n+1)*spacing):spacing:max_r];
% if (model_number ~= 5)
% r_array = sort([r_array rp+13.7 rp+15]);
extra_spacing = (spacing/m)/2;
r_array = sort([r_array (rp+cochannel_separation_dist+extra_spacing) ...
    (rp+cochannel_separation_dist-extra_spacing)]);

% end

% Set up cell area and distance between secondaries according to the local
% population density and the model number
switch(model_number)
    case {1,2},
        cr_dist_to_tx = get_simulation_value('hotspot_jam_radius');
        cell_areas = pi*(cr_dist_to_tx)^2;
    case {3,4,5},
        % He'll either go halfway out his cell or 50km outward -- the 50km
        % case corresponds to when his cell area is capped at 100^2*pi km^2
        % anyway
        cr_dist_to_tx = min(sqrt((p/pop_density)/pi)/2, 50);
        
        if (model_number == 5)
            % this is approximately what we were using last time -- see
            % find_old_make_jam_areas.m
            cell_areas = 400;
            % we want to cut out the flat tax completely
            %             bpsHz = 0;
        else
            % need to multiply range by 2 because we assumed our receiver
            % was only halfway out in our cell
            cell_areas = (pi*(cr_dist_to_tx*2)^2);
        end
        
    otherwise,
        error('Unknown model number.');
end

%% Make our secondaries
r_inner = [min_r (r_array(1:end-1) + (spacing/m)/2)];
r_outer = [r_inner(2:end) r_inner(end)+spacing];

if (~all(r_inner < r_outer))
    error('Rings not placed correctly.');
end

r_array = unique([r_inner r_outer(end)]);

if (rp == 0)
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

%% Check to see if the positioning and areas are correct
% if 0
%     figure; set(gcf, 'outerposition', [288   110   577   747]);
%     subplot(2,1,1); hold on;
%     c = [0 0];
%     circle(c, rp, 50, 'g');
%     for i = 1:length(r_inner)
%         circle(c, r_inner(i), 40, 'b-');
%     end
%     for i = 1:length(r_outer)
%         circle(c, r_outer(i), 50, 'r-');
%     end
%     [x y] = pol2cart(theta, r);
%     scatter(x,y, 50);
%     axis([.9*min_r, 1.1*max_r, -50 50])
%
%     subplot(2,1,2); hold on;
%     plot(r_inner, '.-');
%     plot(r_outer, 'r.-');
%     plot(r_array(2:end), 'go', 'markersize', 10);
%     plot(r_array(1), 'go', 'markersize', 10);
%     legend('r inner', 'r outer', 'r array', 'location', 'southeast');
%
%
%     figure; set(gcf, 'outerposition', [866   113   571   744]);
%     subplot(3,2,1);
%     plot(r, '.-');
%     title('r');
%
%     subplot(3,2,2);
%     plot(theta, '.-');
%     title('theta');
%
%     subplot(3,2,3);
%     plot(ring_areas, '.-');
%     title('ring areas');
%
%     %     subplot(3,2,4);
%     %     plot(tower_areas, '.-');
%     %     title('tower areas');
%
%     subplot(3,2,5);
%     plot(r_index, '.-');
%     title('r index');
%     grid on;
%
% end
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


wifi_power = old_powers .* cell_areas; % scale power based on the amount of jam you scoop up


% Make old rate 1 - clean
noise = TNP;
old_rate = log2(1 + cr_signal.* wifi_power ./ noise);


% Make old rate 2 - TV noise
dist_to_tv_tx = r_array;
noise = TNP + apply_path_loss(tv_power, channel, tv_haat, dist_to_tv_tx)';
test_rate = log2(1 + cr_signal.*wifi_power ./ noise);


output_r_array = mean([r_inner; r_outer], 1);
switch(model_number)
    case {1,2,3,4},     idcs = test_rate < bpsHz;
    case {5},           idcs = (output_r_array - rp) < ...
                            get_simulation_value('cochannel_separation_distance');
                        % zero out the powers within rn
    otherwise,          error('Unknown model number.');
end
old_rate(idcs) = 0;



%% Find new powers, new rates
beta_min = 0;
beta_max = 1;

% tv_signal = tv_apply_path_loss(tv_power, channel, tv_haat, rp);
% target_snr = 15;

beta_stop = 0;
iterations = 0;
max_iterations = 20;
while (~beta_stop && iterations < max_iterations)
    beta = mean([beta_min, beta_max]);
    
    %     target_rate = beta*old_rate - bpsHz;      % models 1 and 2 use this
    
    %     target_rate = beta*(old_rate - bpsHz);          % used to charge flat tax
    target_rate = beta*old_rate;        % no flat tax
    target_rate(idcs) = 0;
    
    if (any(target_rate < 0))
        target_rate
        error('Negative target rate');
    end
    
    %     target_rate(target_rate < 0) = 0;
    
    
    
    % power/(wifi tower)
    wifi_power = ((2.^(target_rate) - 1) .* (TNP) ) / cr_signal;
    
    % power/area = (power/tower) / (area/tower)
    power_per_area = wifi_power ./ cell_areas;
    
    % set the last three to be equal
    power_per_area(end-1:end) = ones(1,2) * power_per_area(end-2);
    
    % now scale back to power/tower
    % power/tower = power/area * area/tower
    jam_tower_power = power_per_area .* tower_areas;
    
    
    % Check TV SNR condition
    new_powers_long = short_to_long(jam_tower_power, r_index, num_points);
    total_tv_interference = sum(new_powers_long'.*rp_fractions);
    %     tv_snr_at_rp = 10*log10( tv_signal / (total_tv_interference + TNP) );
    
    %     if (tv_snr_at_rp > target_snr)
    %         beta_min = beta;
    %     else
    %         beta_max = beta;
    %     end
    %     beta_stop = ( (tv_snr_at_rp - target_snr) < 0.05) && (tv_snr_at_rp - target_snr) > 0;
    
    
    if (total_tv_interference < TNP)
        beta_min = beta;
    else
        beta_max = beta;
    end
    beta_stop = ( (total_tv_interference > 0.98*TNP) && (total_tv_interference < TNP) );
    
    
    iterations = iterations + 1;
end



%% Output
if (iterations == max_iterations)
    warning('Hit the maximum number of iterations before converging');
end


if (any(power_per_area < 0))
    error('Negative power per area');
end

output.beta = beta;
% output.r_array = r_array;
output.r_array = output_r_array;
output.new_powers = power_per_area;
output.old_powers = old_powers;
output.old_rate = old_rate;
output.test_rate = test_rate;
output.new_rate = target_rate;
output.rp = rp;


% beta
% rp


% diff = mean([r_inner; r_outer], 1) - rp
% r_inner(1)'-rp
% r_outer(1)'-rp

end


% To decrease computational time, we take advantage of the circular
% symmetry of the problem by using one point per radius for some
% calculations. In this function, we duplicate these point so that all
% points are explicitly included.
function [long_version] = short_to_long(short_version, r_index, num_points)
long_version = zeros(1, num_points);
r_index = [r_index, num_points + 1];
for i = 1:length(r_index)-1
    long_version(r_index(i):r_index(i+1)-1) = short_version(i);
end
end

