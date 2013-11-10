function [varargout] = load_by_label(label)
% [varargout] = load_by_label(label)
%
% Output arguments are as follows:
%
%
%   CAPACITY:       [capacity extras]
%
%   CCDF points:    [average median extras]
%
%   CHAR:           [height power]
%
%   FCC mask:       [mask extras]
%
%   FM mask:        [mask extras]
%
%   JAM:            Dependent on stage:
%       * chan_data: [old_powers new_powers r_arrays betas chan_data
%                       chan_data_indices]
%       * power_map: [new_power_map old_power_map flat_power_maps
%                       excl_mask beta_map]
%       * rate_map:  [fair_rate_map fair_rate_map_nomedfilt avg_rate_map
%                       min_rate_map]
%
%   HEX model:      [area_array signals noises num_points]
%                     Use as follows:
%                       signals(channel_index, area_index, point_index)
%                       noises(channel_index, area_index, point_index)
%
%   MAC table:      [interference mac_radii]
%
%   NOISE:          [noise]
%
%   PL_SQUARES:     Dependent on type:
%       * local:     [int dont_care_map] (int has fields num_towers, care,
%                       center_interference)
%       * long-range: [pl_squares] (pl_squares has fields distances,
%                       fractions, idx_x, idx_y
%
%   POPULATION:     [population_map]
%
%   REGION_AREAS:   [areas lat_coords long_coords]
%
%   REGION_MASK:    [mask lat_coords long_coords]
%
%   REGION_OUTLINE: [lats longs]
%
%   TV_SIGNAL:      [maxiumum_signal_strength]
%
%
% Note: If the data doesn't exist, the function will return an error.
%
% See also: generate_label




% Old jam loader:
%   JAM:            [new_power_map old_power_map chan_data flat_power_map1
%                       flat_power_map2]




% Note: if the data doesn't exist, it will be created and saved, then
% loaded.

switch(label.label_type)
    case 'capacity',
        [varargout] = load_capacity_by_label(label);
    case 'ccdf_points',
        [varargout] = load_ccdf_points_by_label(label);
    case 'char',
        [varargout] = load_char_by_label(label);
    case 'fcc_mask',
        [varargout] = load_fcc_mask_by_label(label);
    case 'fm_mask',
        [varargout] = load_fm_mask_by_label(label);
    case 'jam',
        [varargout] = load_jam_by_label(label);
    case 'hex',
        [varargout] = load_hex_by_label(label);
    case 'mac_table',
        [varargout] = load_mac_table_by_label(label);
    case 'noise',
        [varargout] = load_noise_by_label(label);
    case 'pl_squares',
        [varargout] = load_pl_squares_by_label(label);
    case 'population',
        [varargout] = load_population_by_label(label);
    case 'region_areas',
        [varargout] = load_region_areas_by_label(label);
    case 'region_mask',
        [varargout] = load_region_mask_by_label(label);
    case 'region_outline',
        [varargout] = load_region_outline_by_label(label);
    case 'test',
        error('TEST labels do not have associated files.');
    otherwise,
        error(['Unrecognized label: ' label]);
end

end






% -------------------------------------------------------------------------
%     CAPACITY
% -------------------------------------------------------------------------
function [out] = load_capacity_by_label(capacity_label)
% [capacity extras] = load_capacity_by_label(capacity_label)

% Load the right file
switch(capacity_label.capacity_type)
    case {'per_area', 'per_person', 'raw'},
%         temp_label.capacity_type = 'per_area';
        temp_label = generate_label('capacity', 'per_area', ...
            capacity_label.range_type, capacity_label.range_value, ...
            capacity_label.population_type, capacity_label.char_label, ...
            capacity_label.noise_label, capacity_label.cell_model_label);
    otherwise,  % do nothing (do not change)
        temp_label = capacity_label;
end

% Create the data if it doesn't exist
if (~data_exists(temp_label))
    make_capacity(temp_label);
end

temp_filename = generate_filename(temp_label);
file = load([temp_filename '.mat']);

% Output the correct values
switch(capacity_label.capacity_type)
    case {'per_area', 'single_user'},
        out{1} = file.capacity;
        out{2} = file.extras;
    case 'per_person',

        cap_per_area = file.capacity;
        pop_density = get_pop_density(capacity_label.noise_label.map_size, ...
            capacity_label.population_type, size(cap_per_area,1));
        out{1} = cap_per_area ./ pop_density;
        out{2} = file.extras;
    case 'raw',
        out{1} = file.extras.raw_capacity;
        out{2} = file.extras;
end


check_for_warnings(file);

end

% -------------------------------------------------------------------------
%     CCDF points
% -------------------------------------------------------------------------
function [out] = load_ccdf_points_by_label(ccdf_points_label)
%   [average median] = load_ccdf_points_by_label(ccdf_points_label)

if (~data_exists(ccdf_points_label))
    make_ccdf_points(ccdf_points_label);
end
ccdf_filename = generate_filename(ccdf_points_label);
file = load([ccdf_filename '.mat']);

out{1} = file.average;
out{2} = file.median;
out{3} = file.extras;

check_for_warnings(file);

end

% -------------------------------------------------------------------------
%     CHAR(acteristics)
% -------------------------------------------------------------------------
function [out] = load_char_by_label(char_label)
% [height power] = load_char_by_label(char_label)

out{1} = char_label.height;
out{2} = char_label.power;

end


% -------------------------------------------------------------------------
%     FCC mask
% -------------------------------------------------------------------------
function [out] = load_fcc_mask_by_label(fcc_mask_label)
%   [mask extras] = load_fcc_mask_by_label(fcc_mask_label)

% If it's a CR mask and the user requested that we apply the wireless
% microphone exclusions...
[device_type] = split_flag(fcc_mask_label.device_type);
need_to_apply_mic_exclusions = string_is(device_type, 'cr') ...
    && fcc_mask_label.apply_wireless_mic_exclusions;

if need_to_apply_mic_exclusions
    % Load the version that does not apply them
    fcc_mask_label.apply_wireless_mic_exclusions = false;
end

% Load the data (generate if necessary)
if (~data_exists(fcc_mask_label))
    make_fcc_mask(fcc_mask_label);
end
fcc_mask_filename = generate_filename(fcc_mask_label);
file = load([fcc_mask_filename '.mat']);
if ~isfield(file, 'extras') 
    file.extras = 'none';
end

if need_to_apply_mic_exclusions
    % Apply the mic exclusions
    mask = file.extras.mic_removed.mask;
    file.extras.cochannel_mask = file.extras.mic_removed.cochannel_mask;
    file.extras.wireless_mic_channels = ...
        file.extras.mic_removed.wireless_mic_channels;
else
    mask = file.mask;
end

% All relevant data from this field has been copied over if necessary so
% there is no need to return it.
if isfield(file.extras, 'mic_removed')
    file.extras = rmfield(file.extras, 'mic_removed');
end
    
out{1} = mask;
out{2} = file.extras;

check_for_warnings(file);

end


% -------------------------------------------------------------------------
%     F(ade) M(argin) mask
% -------------------------------------------------------------------------
function [out] = load_fm_mask_by_label(fm_mask_label)
%   [mask] = load_mask_by_label(fm_mask_label)

if (~data_exists(fm_mask_label))
    make_fm_mask(fm_mask_label);
end

fm_mask_filename = generate_filename(fm_mask_label);
file = load([fm_mask_filename '.mat']);
if ~isfield(file, 'extras') 
    file.extras = 'none';
end

[device_type] = split_flag(fm_mask_label.device_type);

out{1} = file.mask;
out{2} = file.extras;

check_for_warnings(file);

end


% -------------------------------------------------------------------------
%     JAM model
% -------------------------------------------------------------------------
function [out] = load_jam_by_label(jam_label)
%   [new_power_map old_power_map chan_data flat_power_map1 flat_power_map2]
%        = load_hex_by_label(hex_label)

if (~data_exists(jam_label))
    make_data(jam_label);
end

jam_filename = generate_filename(jam_label);
file = load([jam_filename '.mat']);

switch(jam_label.stage)
    case 'chan_data',
        % Data in CHAN_DATA stage
        % 	betas	<8071x1 double>
        % 	chan_data	<8071x10 double>
        % 	chan_data_indices	<1x1 struct>
        % 	filename	'JAM chan_data model=1 power=none (CHAR height=30 power=0) tax=0.5 p=0'
        % 	jam_label	<1x1 struct>
        % 	new_powers	<8071x104 double>
        % 	old_powers	<8071x104 double>
        % 	r_arrays	<8071x104 double>
        % 	temp_jam_label	<1x1 struct>
        
        
        out = {file.old_powers file.new_powers file.r_arrays file.betas ...
                file.chan_data file.chan_data_indices};
        
        
    case 'power_map',
        % Data in POWER_MAP stage
        % 	adj_restrictions	<1x1 struct>
        % 	beta_map	<49x201x301 double>
        % 	betas	<8071x1 double>
        % 	chan_data	<8071x10 double>
        % 	chan_data_indices	<1x1 struct>
        % 	chan_list	<1x49 double>
        % 	cochannel_exclusions_only	<1x1 struct>
        % 	excl_mask	<49x201x301 logical>
        % 	fcc_label	<1x1 struct>
        % 	fcc_mask	<49x201x301 logical>
        % 	filename	'JAM power_map model=1 power=none (CHAR height=30 power=0) tax=0.5 p=0.mat'
        % 	flat_power3	<1x49 double>
        % 	flat_power3_40dB	<1x49 double>
        % 	flat_power_map1	<49x201x301 double>
        % 	flat_power_map2	<49x201x301 double>
        % 	flat_power_map3	<49x201x301 double>
        % 	i	49
        % 	jam_label	<1x1 struct>
        % 	layer	<1x201x301 double>
        % 	new_power_map	<49x201x301 double>
        % 	new_powers	<8071x89 double>
        % 	old_power_map	<49x201x301 double>
        % 	old_powers	<8071x89 double>
        % 	r_arrays	<8071x89 double>
        % 	rp_list	<8071x1 double>
        % 	temp_jam_label	<1x1 struct>
        
        flat_power_maps.flat_power3 = file.flat_power3;
        flat_power_maps.flat_power3_boost = file.flat_power3_boost;
        flat_power_maps.flat_power_map1 = file.flat_power_map1;
        flat_power_maps.flat_power_map2 = file.flat_power_map2;
        flat_power_maps.flat_power_map3 = file.flat_power_map3;
        
        out = {file.new_power_map file.old_power_map flat_power_maps ...
            file.excl_mask file.beta_map};
        
        
    case 'rate_map',
        % Data in RATE_MAP stage
        % 	avg_rate_map	<49x201x301 double>
        % 	fair_rate_map	<49x201x301 double>
        % 	fair_rate_map_nomedfilt	<49x201x301 double>
        % 	jam_label	<1x1 struct>
        % 	min_rate_map	<49x201x301 double>
        % 	uniform_power_map	<49x201x301 double>
        % 	width	10
        
        out = {file.fair_rate_map file.fair_rate_map_nomedfilt ...
                file.avg_rate_map file.min_rate_map};
        

end


check_for_warnings(file);

end


% -------------------------------------------------------------------------
%     HEX(agon) cell model
% -------------------------------------------------------------------------
function [out] = load_hex_by_label(hex_label)
%   [area_array signals noises num_points] =
%       load_hex_by_label(hex_label)

power = hex_label.char_label.power;
hex_label.char_label.power = 1;

if (~data_exists(hex_label))
    error('Hex data does not exist');
end

hex_filename = generate_filename(hex_label);
file = load([hex_filename '.mat']);

out{1} = file.area_array;
out{2} = file.signals * power;
out{3} = file.noises * power;
out{4} = file.num_points;
% out{4} = file.x_points;
% out{5} = file.y_points;

check_for_warnings(file);

end


% -------------------------------------------------------------------------
%     MAC table
% -------------------------------------------------------------------------
function [out] = load_mac_table_by_label(mac_table_label)
%   [ interference mac_radii ] = load_mac_table_by_label(mac_table_label)

if (~data_exists(mac_table_label))
    make_mac_table(mac_table_label);
end
mac_table_filename = generate_filename(mac_table_label);
file = load([mac_table_filename '.mat']);

out{1} = file.interference;
out{2} = file.mac_radii;

check_for_warnings(file);

end


% -------------------------------------------------------------------------
%     NOISE
% -------------------------------------------------------------------------
function [out] = load_noise_by_label(noise_label)
% [noise] = load_noise_by_label(noise_label)

if (~data_exists(noise_label))
    make_noise(noise_label);
end
noise_filename = generate_filename(noise_label);
file = load([noise_filename '.mat']);

out{1} = file.noise;

check_for_warnings(file);

end



% -------------------------------------------------------------------------
%     PL_SQUARES
% -------------------------------------------------------------------------
function [out] = load_pl_squares_by_label(pl_squares_label)
% [varargout] = load_pl_squares_by_label(pl_squares_label)

if (~data_exists(pl_squares_label))
    make_data(pl_squares_label);
end

pl_squares_filename = generate_filename(pl_squares_label);
file = load([pl_squares_filename '.mat']);



switch(pl_squares_label.type)
    case 'local',
        out = {file.int file.dont_care_map};
        % also available: chan_list, tower_area_map, tower_per_pixel_map
    case 'long_range',
        out = {file.pl_squares};
        % also available: chan_list, lat_coords, long_coords, pl_squares_label
end

check_for_warnings(file);

end


% -------------------------------------------------------------------------
%     POPULATION
% -------------------------------------------------------------------------
function [out] = load_population_by_label(population_label)
% [population_map] = load_population_by_label(population_label)

if (~data_exists(population_label))
    make_data(population_label);
end

[population_type population_year] = split_flag(population_label.population_type);
filename = generate_filename(population_label);
file = load(filename);

switch(population_label.type)
    case 'raw',
        switch(population_type)
            case 'real',
                population = file.population;

            case 'uniform',
                is_in_us = get_us_map(map_size);
                total_population = sum(sum(file.population));
                num_pixels = sum(sum(is_in_us));
                people_per_pixel = total_population/num_pixels;

                population = is_in_us * people_per_pixel;

            case {'min', 'max'},
                us_area = get_us_area(map_size);
                pop_density = eval(['file.' population_type '_pop_density']);
                population = us_area .* pop_density;

            otherwise
                error(['Invalid population type: ' population_type]);
        end
        
        out = {population};
        
    case 'density',
        switch(population_type)
            case 'real',
                pop_density = file.pop_density;

            case 'uniform',
                is_in_us = get_us_map(map_size, 1);
                average_pop_density = mean(mean(file.pop_density(is_in_us)));
                pop_density = is_in_us * average_pop_density;

            case {'min', 'max'},
                us_area = get_us_area(map_size);
                pop_density = eval(['file.' population_type '_pop_density']);

            otherwise
                error(['Invalid population type: ' population_type]);
        end
        
        out = {pop_density};
        
    otherwise,
        error(['Unexpected population type: ' population_label.type]);
end

check_for_warnings(file);

end


% -------------------------------------------------------------------------
%     REGION_AREAS
% -------------------------------------------------------------------------
function [out] = load_region_areas_by_label(region_areas_label)
% [lats longs] = load_region_areas_by_label(region_areas_label)

if (~data_exists(region_areas_label))
    make_data(region_areas_label);
end

region_areas_filename = generate_filename(region_areas_label);
file = load([region_areas_filename '.mat']);

out = {file.us_area file.lat_coords file.long_coords};

check_for_warnings(file);

end


% -------------------------------------------------------------------------
%     REGION_MASK
% -------------------------------------------------------------------------
function [out] = load_region_mask_by_label(region_mask_label)
% [lats longs] = load_region_mask_by_label(region_mask_label)

if (~data_exists(region_mask_label))
    make_data(region_mask_label);
end

region_mask_filename = generate_filename(region_mask_label);
file = load([region_mask_filename '.mat']);

out = {file.is_in_us file.lat_coords file.long_coords};

check_for_warnings(file);

end


% -------------------------------------------------------------------------
%     REGION_OUTLINE
% -------------------------------------------------------------------------
function [out] = load_region_outline_by_label(region_outline_label)
% [lats longs] = load_region_outline_by_label(region_outline_label)

if (~data_exists(region_outline_label))
    make_data(region_outline_label);
end

region_outline_filename = generate_filename(region_outline_label);
file = load([region_outline_filename '.mat']);

out = {file.lats file.longs};

check_for_warnings(file);

end


function [out] = load_tv_signal_by_label(tv_signal_label)

if (~data_exists(tv_signal_label))
    make_data(tv_signal_label);
end

tv_signal_filename = generate_filename(tv_signal_label);
file = load([tv_signal_filename '.mat']);

out = {file.maxiumum};

check_for_warnings(file);
end



function check_for_warnings(file)

% no warning info present
if ~isfield(file, 'debug_info') || ~isfield(file.debug_info, 'warnings')  
    return;
end

warnings = file.debug_info.warnings;
if isempty(warnings)    % no actual warnings present
    return;
end

% Display the warnings
try
    display('The following warnings from data generation were found in the file:');
    for w = 1:length(warnings)
        display(warnings{w});
    end
catch err
    display('Warnings exist but they could not be displayed:');
    disp(err);
end
    
end

