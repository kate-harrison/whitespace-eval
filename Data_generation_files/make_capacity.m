function [] = make_capacity(capacity_label)
%   [] = make_capacity(capacity_label)

capacity_type = capacity_label.capacity_type;
range_type = capacity_label.range_type;
range_value = capacity_label.range_value;
population_type = capacity_label.population_type;
char_label = capacity_label.char_label;
noise_label = capacity_label.noise_label;
% mac_char_label = capacity_label.mac_table_label.char_label;

cell_model = capacity_label.cell_model_label.label_type;

if (strcmp(range_type, 'p') == 1 && strcmp(population_type, 'none') == 1)
    error(['Trying to compute capacity p with population type ' population_type]);
end


% If we don't need to compute, exit now
if (get_compute_status(capacity_label) == 0)
    return;
end

global map_size
map_size = noise_label.map_size;
is_in_us = get_us_map(map_size, 1);

% SET THE TRANSMITTER-TO-RECEIVER DISTANCE
switch (range_type)
    case 'r',
        % range_map = r*is_in_us
        range_map = range_value * is_in_us;
        range_map(~is_in_us) = 100;  % does not matter since we'll zero out
        % these values anyway but it needs to be nonzero for the path loss
        % model to work
        extras.range_value = range_value;
    case 'p',
        % calculate range_map based on p
        % Exclusion radius at each point on the map
        % people = pop_density * pi * r^2
        pop_density = get_pop_density(map_size, population_type, 1);
        range_map = sqrt(range_value./(pop_density*pi));
        
        % How many points will we cap with max_range?
        max_range = get_simulation_value('max_p_range');
        extras.max_range = max_range;
        extras.number_capped_points = sum(sum(range_map > max_range));
        extras.percentage_capped_points = extras.number_capped_points/sum(sum(is_in_us))*100;

        % Set the maximum range
        range_map(range_map > max_range) = max_range;
        range_map(~is_in_us) = max_range;
        

        extras.range_map = range_map;
    otherwise,
        error('Unknown range type.');
end

switch(cell_model)
    case 'none',
        % Make single user capacity throughout the US
        capacity = get_single_user_capacity(range_map, noise_label, char_label);
        capacity = clean_capacity_data(capacity);
        
    case 'mac_table',
        
        % COMPUTE CAPACITY under the MAC model
        % If single-user capacity...
        if (strcmp(capacity_type, 'single_user') == 1)
                % USED TO HAVE THE CODE FOR THE SINGLE-USER CASE IN HERE
            error('Should not be here');
        % Otherwise go through capacity per area
        else
            capacity_label.capacity_type = 'per_area';
            % Find the capacity per area
            [capacity extras.raw_capacity extras.mac_radius] = get_cap_per_area(capacity_label, range_map);
            
            % Note that we do not calculate the capacity per person here
            % (we do so in load_by_label.m) so that we can use a general
            % filename with pop_type=none to prevent recomputation of
            % equivalent data.
            
            capacity = clean_capacity_data(capacity);
            extras.raw_capacity = clean_capacity_data(extras.raw_capacity);
        end
        
        
    case 'hex',     % takes about 325 seconds
        if (range_type ~= 'p')
            error(['Can only use range_type=p for now. You tried range_type=' range_type]);
        end
        
        if ~string_is(capacity_label.capacity_type, 'per_area')
            error('Can only create per-area hex capacity (but can load any type).');
        end

        p = capacity_label.range_value;
        [extras.raw_capacity extras.raw_capacity_from_avg extras.min_capacity ...
            extras.area_map extras.capped_map] = get_raw_capacity_hex(capacity_label);
        

        % Capacity per area
        rep_area_map = shiftdim(repmat(extras.area_map, [1 1 size(extras.raw_capacity,1)]),2);
        capacity = extras.raw_capacity./rep_area_map;           % Capacity per area
        
        % Capacity per person
        extras.cap_per_person = extras.raw_capacity / p;
        
        % Clean up the maps
        capacity = clean_capacity_data(capacity);
        extras.raw_capacity = clean_capacity_data(extras.raw_capacity);
        extras.raw_capacity_from_avg = clean_capacity_data(extras.raw_capacity_from_avg);
        extras.min_capacity = clean_capacity_data(extras.min_capacity);
        extras.cap_per_person = clean_capacity_data(extras.cap_per_person);
        
        % Save
        filename = save_filename(capacity_label);
        save_data(filename, 'capacity', 'extras');

        
        
        
end



% Make sure extras exists
if (exist('extras', 'var') == 0)
    extras.contents = 'none';
end

capacity_filename = save_filename(capacity_label);
display(['Saving ' capacity_filename]);

% Save the file
save_data(capacity_filename, 'capacity', 'extras');

end




function [capacity] = clean_capacity_data(capacity)
%   [capacity] = clean_capacity_data(capacity)
% Zero values outside the US

global map_size

if (ndims(capacity) == 2)
    num_layers = 1;
else
    num_layers = size(capacity,1);
end

capacity = squeeze(capacity) .* get_us_map(map_size, num_layers);


end




function [fair_capacity avg_capacity min_capacity area_map capped_map] = get_raw_capacity_hex(capacity_label)
%   [fair_capacity area_map capped_map] = get_raw_capacity_hex(capacity_label)
% global W;

noise_label = capacity_label.noise_label;
hex_label = capacity_label.cell_model_label;

[area_array signals noises num_points] = load_by_label(hex_label);
% How to access the data in these arrays:
%   signals(channel_index, area_index, point_index)
%   noises(channel_index, area_index, point_index)

noise_map = load_by_label(noise_label);

map_size = noise_label.map_size;
population_type = capacity_label.population_type;
chan_list = get_simulation_value('chan_list');
is_in_us = get_us_map(noise_label.map_size, 1);
W = get_simulation_value('bandwidth');
num_areas = length(area_array);



% people = pop_density * pi * r^2
% area/tower = people/tower / (people/area)
pop_density = get_pop_density(map_size, population_type, 1);
area_map = capacity_label.range_value ./ pop_density;
area_map(~is_in_us) = 10;   % Fake number so we don't count it among the capped points

% Bound our areas based on what we've computed
max_area = pi * get_simulation_value('max_p_range')^2;
min_area = max( pi * (.05)^2, min(area_array) );
capped_map = (min_area > area_map | max_area < area_map);
%         num_capped = sum(sum(capped_map)) %%sum(sum( (min_area > area_map | max_area < area_map) ))
area_map(area_map < min_area) = min_area;
area_map(area_map > max_area) = max_area;


% Pre-allocate
fair_capacity = zeros([length(chan_list) size(is_in_us)]);
avg_capacity = zeros([length(chan_list) size(is_in_us)]);
min_capacity = zeros([length(chan_list) size(is_in_us)]);


% For each channel
for c = 1:length(chan_list)
    display(['Channel ' num2str(chan_list(c))]);
    signal = squeeze(signals(c,:,:));
    noise = squeeze(noises(c,:,:));
    
    % For each location
    for i = 1:size(is_in_us, 1)
        for j = 1:size(is_in_us, 2)
            if (~is_in_us(i,j)) % Skip if not in the US
                continue;
            end
            
            % Determine signal and noise powers
            % We have a fixed set of areas so we have to interpolate and/or
            % round
            low_idx = find(area_map(i,j) > area_array, 1, 'last');
            if (low_idx == num_areas)
                noise_power = noise(end,:);
                signal_power = signal(end,:);
            else if (isempty(low_idx))
                    noise_power = noise(1,:);
                    signal_power = signal(1,:);
                else    % Interpolate
                    high_idx = low_idx + 1;
                    noise_power = log_interp(area_array(low_idx), noise(low_idx,:), ...
                        area_map(i,j), area_array(high_idx), noise(high_idx,:));
                    signal_power = log_interp(area_array(low_idx), signal(low_idx,:), ...
                        area_map(i,j), area_array(high_idx), signal(high_idx,:));
                end
            end
            
            % What each person would get if they had the link to themselves
            % 100% of the time
            potential_capacity = W*log2(1 + signal_power./(noise_power+noise_map(c,i,j)));
            
            % If everyone gets the same rate (e.g. high-potential users get
            % less time), what is that rate (per person)?
            fair_capacity_per_person = 1/sum(1./potential_capacity);
            % Now, what is the total tower capacity?
            fair_capacity(c,i,j) = fair_capacity_per_person * num_points;  % point dimension

            % Some statistics on our users
            avg_capacity(c,i,j) = mean(potential_capacity);
            min_capacity(c,i,j) = min(potential_capacity);
        end
    end
end


end




function [capacity] = get_single_user_capacity(range_map, noise_label, char_label)
%   [capacity] = make_single_user_capacity(range_map, noise_label,
%   char_label)


B = get_simulation_value('bandwidth');
chan_list = get_simulation_value('chan_list');


% [tx_haat tx_power] = load_char_by_label(char_label);
[tx_haat tx_power] = load_by_label(char_label);
% noise_map = load_noise_by_label(noise_label);
noise_map = load_by_label(noise_label);

% Do a little dance to accomodate 2D arrays without changing the code
% (essentially make them into 3D arrays with a singleton dimension)
if (ndims(noise_map) == 2)
    temp = shiftdim(repmat(noise_map, [1 1 2]),2);
    noise_map = temp(1,:,:);
    clear temp;
end

capacity = zeros(size(noise_map));

for i = 1:size(noise_map,1)
    chan_no = chan_list(i);
    display(['   Working on channel ' num2str(chan_no)]);
    for row = 1:size(noise_map, 2)
        noise = squeeze(noise_map(i, row, :));
        tx_dist_to_rx = range_map(row, :);
        tx_power_after_pl = apply_path_loss(tx_power, chan_no, tx_haat, tx_dist_to_rx);
        cap = B .* log2(1 + tx_power_after_pl./(noise));
        capacity(i, row, :) = cap;
    end
end

% Squeeze the matrix back down (in case it was originally a 2D array)
capacity = squeeze(capacity);


end






function [ cap_per_area raw_capacity excl_radii ] = get_cap_per_area(capacity_label, range_map)
%   [ cap_per_area raw_capacity excl_radii ] =
%       get_cap_per_area(capacity_label, range_map)

noise_label = capacity_label.noise_label;
char_label = capacity_label.char_label;
mac_table_label = capacity_label.mac_table_label;

% validate_noise_label(noise_label);
% noise_map = load_noise_by_label(noise_label);
noise_map = load_by_label(noise_label);

% channels = get_channels_from_label(noise_label);
channels = noise_label.channels;
% [noise radii] = load_mac_table_by_label(generate_mac_table_label(channels, mac_char_label));
[noise radii] = load_by_label(mac_table_label);
% [tx_haat tx_power] = deconstruct_char_label(char_label);
[tx_haat tx_power] = load_by_label(char_label);


% Translate to what the function expects
switch(channels)
    case 'tv', chan_list = get_simulation_value('chan_list');
    case '52', chan_list = [52];
end
noise_data = noise_map;
noise_list = noise;
radii_list = radii;
tx_dist_to_rx = range_map;

% Old function that used to do this stuff...
%GET_CAP_PER_AREA_FROM_MAP Summary of this function goes here
%
%   [ caps_per_area capacities radii ] = get_caps_per_area_from_maps(
%   chan_list, noise_data, noise_list, radii_list, tx_dist_to_rx, tx_power,
%   tx_haat )
%
%   chan_list - list of channels in the 3D map
%   noise_data - map of ambient noise for each channel
%   noise_list - exclusion radius lookup tables
%   radii_list - radius list corresponding to the exclusion radius lookup
%       tables
%   tx_dist_to_rx - distance between the secondary transmitter and
%       secondary receiver (in km)
%   tx_power - power of the secondary transmitter (in Watts)
%   tx_haat - heigh above average terrain for the transmitter (in meters)



chan_list = get_simulation_value('chan_list');
tx_dist_to_rx = repmat(tx_dist_to_rx, [1 1 length(chan_list)]);
if (ndims(noise_data)==2)
    old_noise = noise_data;
    noise_data = zeros(1, size(noise_data, 1), size(noise_data, 2));
    noise_data(1,:,:) = old_noise;
end


caps_per_area = zeros(size(noise_data));  % Create a blank array to hold the capacity/area
capacities = zeros(size(noise_data));  % Create a blank array to hold the raw capacities
radii = zeros(size(noise_data));  % Create a blank array to hold the radii
num_rows = size(noise_data, 2);

% For each channel...
for ch = 1:length(chan_list)
    display(['   Working on channel ' num2str(chan_list(ch))]);
    
    % Select the appropriate noise column (based on channel)
    noise_list_ch = squeeze(noise_list(:, ch));
    
    % At most we can supply a vector to the function so we go row
    % by row
    for row = 1:num_rows
%         display(['     Row ' num2str(row)]);
            ambient_noise = squeeze(noise_data(ch, row, :)); % Removes trivial dimensions and turns it into a column vector

        [caps_per_area(ch, row, :) capacities(ch, row, :) radii(ch, row, :)] = ...
            get_best_exclusion_radius(chan_list(ch), tx_dist_to_rx(row, :, ch), ...
            tx_power, tx_haat, ambient_noise, radii_list, noise_list_ch);
        
    end
end


% Translate back
cap_per_area = caps_per_area;
raw_capacity = capacities;
excl_radii = radii;

end
