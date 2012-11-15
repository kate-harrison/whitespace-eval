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
% temp_label = capacity_label;
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

%         if (isfield(file.extras, 'cap_per_person'))
%             out{1} = file.extras.cap_per_person;
%         else        % Legacy support (did not always store cap_per_person)
        cap_per_area = file.capacity;
        pop_density = get_pop_density(capacity_label.noise_label.map_size, ...
            capacity_label.population_type, size(cap_per_area,1));
        out{1} = cap_per_area ./ pop_density;
%         end
        out{2} = file.extras;
    case 'raw',
        out{1} = file.extras.raw_capacity;
        out{2} = file.extras;
end


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

% average = file.average;
% median = file.median;
out{1} = file.average;
out{2} = file.median;
out{3} = file.extras;

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

if (~data_exists(fcc_mask_label))
    make_fcc_mask(fcc_mask_label);
end
fcc_mask_filename = generate_filename(fcc_mask_label);
file = load([fcc_mask_filename '.mat']);

[device_type] = split_flag(fcc_mask_label.device_type);

switch(device_type)
    case 'cr',
        % Take out channels for wireless microphone exclusions
        file.extras.mask_pre_mic_channels = file.mask;
        [mask file.extras.wireless_mic_channels] = take_out_wireless_mic_channels(file.mask);
    case 'tv',
        mask = file.mask;
    otherwise,
        error(['Unrecognized device type: ' device_type]);
end


out{1} = mask;
out{2} = file.extras;

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

[device_type] = split_flag(fm_mask_label.device_type);

switch(device_type)
    case 'cr',
        % Take out channels for wireless microphone exclusions
        file.extras.mask_pre_mic_channels = file.mask;
        [mask file.extras.wireless_mic_channels] = take_out_wireless_mic_channels(file.mask);
    case 'tv',
        mask = file.mask;
    otherwise,
        error(['Unrecognized device type: ' device_type]);
end


out{1} = mask;
out{2} = file.extras;

end


% -------------------------------------------------------------------------
%     JAM model
% -------------------------------------------------------------------------
function [out] = load_jam_by_label(jam_label)
%   [new_power_map old_power_map chan_data flat_power_map1 flat_power_map2]
%        = load_hex_by_label(hex_label)

if (~data_exists(jam_label))
    error('Jam data does not exist');
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




% OLD VERSION
% load([jam_filename '.mat']);
% % 	beta_map	<49x201x301 double>
% % 	betas	<8071x8 double>
% % 	chan_data	<8071x10 double>
% % 	chan_data_indices	<1x1 struct>
% % 	cr_haat	30
% % 	flat_power_map1	<49x201x301 double>
% % 	flat_power_map2	<49x201x301 double>
% % 	jam_label	<1x1 struct>
% % 	new_power_map	<49x201x301 double>
% % 	new_powers	<8071x21 double>
% % 	old_power_map	<49x201x301 double>
% % 	old_powers	<8071x21 double>
% % 	p	1000
% % 	pop_density_type	'real'
% % 	r_arrays	<8071x21 double>
% 
% out = {new_power_map old_power_map chan_data flat_power_map1 flat_power_map2};
% 
% % out{1} = file.area_array;
% % out{2} = file.signals;
% % out{3} = file.noises;
% % out{4} = file.x_points;
% % out{5} = file.y_points;

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

% interference = file.interference;
% mac_radii = file.mac_radii;
out{1} = file.interference;
out{2} = file.mac_radii;

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

% noise = file.noise;
out{1} = file.noise;

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

end
