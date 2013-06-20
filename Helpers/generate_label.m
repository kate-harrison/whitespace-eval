function [label] = generate_label(varargin)
% [label] = generate_label(label_type, ...)
%
% First argument: type of label
%   Accepted values: capacity, ccdf_points, char, fcc_mask, fm_mask,
%       jam, hex, mac_table, noise, pl_squares
%
% Second through nth arguments: label descriptors (specific to each label)
%   CAPACITY: (capacity_type, range_type, range_value, population_type,
%       char_label, noise_label, cell_model_label )
%           - capacity_type = {'per_area', 'per_person', 'single_user', 'raw'}
%           - range_type = {'r', 'p'}
%   CCDF points: (variable, mask_type, capacity_label)
%           - variable = {'tv_removal-1', 'tv_removal-2', 'fade_margin'}
%           - mask_type = {'fcc', 'fade_margin', 'fm-cochan', 'none'}
%   CHAR: (height, power)
%           - height: > 10, < 1200
%           - power: >= 0
%   FCC mask: (device_type, map_size, apply_wireless_mic_exclusions)
%           - apply_wireless_mic_exclusions = {true, false}
%   FM mask: (device_type, map_size, margin_value, char_label)
%           - margin_value: >= 0
%   JAM: (stage, model, power_type, population_type, tower_data_year, 
%         char_label, tax, p, noise_label)
%           - stage = {'chan_data', 'power_map', 'rate_map'}
%           - model \in {0,1,2,3,4,5}
%           - power_type = {'none', 'new_power', 'old_dream', 'flat3'}
%           - tax: >= 0
%   HEX(agon) cell: (type, char_label)
%           - type = {'wifi', 'cellular'}
%   MAC table: (channels, char_label)
%   NOISE: (cochannel, map_size, channels, leakage_type)
%           - cochannel = {'yes', 'no'}
%           - leakage_type = {'none', 'both', 'up', 'down'}
%   POPULATION: (type, population_type, map_size)
%           - type = {'raw', 'density'}
%   PL_SQUARES: (type, width, p, pop_type, map_size, char_label)
%           - type = {'local', 'long_range'}
%           - width: >= 0
%   REGION_AREAS: (map_size, type)
%           - type = {'masked', 'full'} (uses 'masked' if none specified)
%   REGION_MASK: (map_size)
%   REGION_OUTLINE: (map_size)
%
%
%   Common inputs:
%           - channels = {'tv-2008', 'tv-2011', '52', 'tv'}
%           - device_type = {'tv', 'cr', 'cr_portable', 'tv-2008', 
%                   'tv-2011', 'cr-2008', 'cr-2011'};
%           - tower_data_year = {'2011'}
%           - map_size = {'200x300', '201x301', '400x600', '800x1200'}
%           - p: >= 0
%           - population_type = {'none', 'uniform-2000', 'uniform-2010',
%                   'real-2000', 'real-2010', 'min-2000', 'min-2010',
%                   'max-2000', 'max-2010'}
%
% See also: get_simulation_value, load_by_label, validate_label,
%               validate_flags



if (nargin < 2)
    error('Not enough arguments!');
end

% Convert everything to lowercase for consistency
for i = 1:nargin
    if (ischar(varargin{i}))
        varargin{i} = lower(varargin{i});
    end
end

% accepted_values = 'capacity, ccdf_points, char, fcc_mask, fm_mask, jam, hex, mac_table, noise, pl_squares';
accepted_values = get_simulation_value('labels');
switch(varargin{1})
    case 'capacity',
        num_needed_args = 7; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_capacity_label(varargin{2:end});
    case 'ccdf_points',
        num_needed_args = 3; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_ccdf_points_label(varargin{2:end});
    case 'char',
        num_needed_args = 2; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_char_label(varargin{2:end});
    case 'fcc_mask',
        num_needed_args = [2 3]; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_fcc_mask_label(varargin{2:end});
    case 'fm_mask',
        num_needed_args = 4; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_fm_mask_label(varargin{2:end});
    case 'jam',
        num_needed_args = 9; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_jam_label(varargin{2:end});
    case 'hex',
        num_needed_args = 2; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_hex_label(varargin{2:end});
    case 'mac_table',
        num_needed_args = 2; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_mac_table_label(varargin{2:end});        
    case 'noise',
        num_needed_args = 4; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_noise_label(varargin{2:end});
    case 'population',
        num_needed_args = 3; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_population_label(varargin{2:end});
    case 'pl_squares', 
        num_needed_args = 6; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_pl_squares_label(varargin{2:end});
    case 'region_areas',
        num_needed_args = [1 2]; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_region_areas_label(varargin{2:end});
    case 'region_mask',
        num_needed_args = 1; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_region_mask_label(varargin{2:end});
    case 'region_outline',
        num_needed_args = 1; verify_num_args(num_needed_args, nargin, varargin{1});
        label = generate_region_outline_label(varargin{2:end});
        
    otherwise,
        error(['Unrecognized label type: ''' varargin{1} '''. Acceptable values are: ' accepted_values]);
end

label.label_type = varargin{1};

validate_label(label);

end


function [] = verify_num_args(num_needed, num_received, label_type)

% First argument doesn't count since it's the label type
num_received = num_received - 1;

switch(length(num_needed))
    case 1,     % fixed number
        if (num_needed ~= num_received)
            error(['Insufficient number of arguments. Supplied ' ...
                num2str(num_received) ' and needed ' num2str(num_needed) ...
                ' for label type ' upper(label_type) '.']);
        end
        
    case 2,     % range
        if (num_received < num_needed(1) || num_received > num_needed(2))
            error(['Incorrect number of arguments: Supplied ' ...
                num2str(num_received) ' and needed between ' ...
                num2str(num_needed(1)) ' and ' num2str(num_needed(2)) ...
                ' for label type ' upper(label_type) '.']);
        end
        
    otherwise,
        error('Unexpected case.');
end

end



% -------------------------------------------------------------------------
%     CAPACITY
% -------------------------------------------------------------------------
function [capacity_label] = generate_capacity_label(capacity_type, range_type, range_value, population_type, char_label, noise_label, cell_model_label )
%   [capacity_label] = generate_capacity_label(capacity_type, range_type,
%   range_value, population_type, char_label, noise_label, cell_model_label)

capacity_label.capacity_type = capacity_type;
capacity_label.range_type = range_type;
capacity_label.range_value = range_value;

% Set the population value
switch(capacity_label.range_type)
    case 'r',
        switch(capacity_type)
            case {'single_user', 'raw', 'per_area'},    % No population data is used for these calculations
                capacity_label.population_type = 'none';
            case {'per_person'},    % Population data is used for these calculations
                [capacity_label.population_type capacity_label.population_year] ...
                    = generate_population_type(population_type);
        end
    case 'p',
        [capacity_label.population_type capacity_label.population_year] ...
            = generate_population_type(population_type);
end

capacity_label.char_label = char_label;
capacity_label.noise_label = noise_label;
switch(capacity_type)
    case 'single_user',
        capacity_label.mac_table_label.label_type = 'none';
        capacity_label.cell_model_label.label_type = 'none';
    otherwise, 
        capacity_label.mac_table_label = cell_model_label;  % Kept for compatibility -- remove
        capacity_label.cell_model_label = cell_model_label;
end

end


% -------------------------------------------------------------------------
%     CCDF points
% -------------------------------------------------------------------------
function [ccdf_points_label] = generate_ccdf_points_label(variable, mask_type, capacity_label)
%   [ccdf_points_label] = generate_ccdf_points_label(variable, mask_type,
%   capacity_label)

% ccdf_points_label.label_type = 'ccdf';
ccdf_points_label.variable = variable;
ccdf_points_label.mask_type = mask_type;
ccdf_points_label.capacity_label = capacity_label;

end


% -------------------------------------------------------------------------
%     CHAR(acteristics)
% -------------------------------------------------------------------------
function [char_label] = generate_char_label(height, power)
%   [char_label] = generate_char_label(height, power)

char_label.height = height;
char_label.power = power;


end


% -------------------------------------------------------------------------
%     FCC mask
% -------------------------------------------------------------------------
function [fcc_mask_label] = generate_fcc_mask_label(device_type, map_size, varargin)
%   [fcc_mask_label] = generate_mask_label(device_type, map_size, [apply_wireless_mic_exclusions])

device_type = validate_flags('', 'device_type', device_type);
fcc_mask_label.device_type = device_type;

fcc_mask_label.map_size = map_size;

% Figure out the correct value for 'apply_wireless_mic_exclusions'
[dev_type year] = split_flag(fcc_mask_label.device_type);
if string_is(dev_type, 'tv')
    fcc_mask_label.apply_wireless_mic_exclusions = false;
else
    if ~isempty(varargin)   % if the user specified some value, use it (we will validate later)
        fcc_mask_label.apply_wireless_mic_exclusions = varargin{1};
    else    % user did not specify => use default value
        fcc_mask_label.apply_wireless_mic_exclusions = ...
            get_simulation_value('apply_wireless_mic_exclusions');
        soft_warning('Using the default choice for wireless mic exclusions.');
    end
end

end


% -------------------------------------------------------------------------
%     F(ade) M(argin) mask
% -------------------------------------------------------------------------
function [fm_mask_label] = generate_fm_mask_label(device_type, map_size, margin_value, char_label)
%   [fm_mask_label] = generate_mask_label(device_type, map_size, margin_value, char_label)

device_type = validate_flags('', 'device_type', device_type);
fm_mask_label.device_type = device_type;

fm_mask_label.map_size = map_size;
fm_mask_label.margin_value = margin_value;
fm_mask_label.char_label = char_label;

end


% -------------------------------------------------------------------------
%     JAM model
% -------------------------------------------------------------------------
function [jam_label] = generate_jam_label(stage, model, power_type, population_type, tower_data_year, char_label, tax, p, noise_label)
%   [jam_label] = generate_jam_label(stage, model_number, power_type, population_type, tower_data_year, char_label, tax, p)

% if (round(p) == p)
%     jam_label.hybrid = false;
% else
%     jam_label.hybrid = true;
%     jam_label.p1 = round(p);
%     jam_label.p2 = (p - round(p))*1e4;
% end

if (ischar(p))
%     jam_label.p_string = p;
%     [T,R] = strtok(p, ',');
%     jam_label.p1 = str2num(T);
%     [T] = strtok(R, ',');
%     jam_label.p2 = str2num(T);

    [p_array] = str2num(p);
    jam_label.p1 = p_array(1);
    jam_label.p2 = p_array(2);
%     jam_label.length_p2 = length(T);

    if (jam_label.p1 == jam_label.p2)
        p = jam_label.p1;
        jam_label.hybrid = false;
%         jam_label.p_string = p;
    else
        jam_label.p_string = p;
        p = str2num(p);
        jam_label.hybrid = true;
    end
else
    jam_label.hybrid = false;
end

switch(model)
    case 5,
        tax = 0;
end

switch(stage)
    case {'chan_data', 'power_map'}
        power_type = 'none';
        switch(model)
            case {1,2}, p = 0;
        end
end

[jam_label.population_type jam_label.population_year] ...
    = generate_population_type(population_type);


jam_label.stage = stage;
jam_label.model = model;
jam_label.power_type = power_type;
jam_label.char_label = char_label;
jam_label.tax = tax;
jam_label.p = p;
jam_label.tower_data_year = tower_data_year;

if (model ~= 0)
    jam_label.char_label.power = 0; % since the power is actually variable...
end

switch(stage)
    case 'chan_data',          jam_label.noise_label = 'none';
        
    case 'power_map',
        if (isstruct(noise_label))
            jam_label.noise_label = noise_label.map_size;
        elseif (ischar(noise_label))
            jam_label.noise_label = noise_label;
        else error('Unknown type for noise label in jam label.');
        end
        
        validate_flags('', 'map_size', jam_label.noise_label);
        
    case 'rate_map', jam_label.noise_label = noise_label;
        if ~isstruct(noise_label)
            error(['Expected full noise label but got: ' noise_label]);
        end
        
end


end


% -------------------------------------------------------------------------
%     HEX(agon) cell model
% -------------------------------------------------------------------------
function [hex_label] = generate_hex_label(type, char_label)
%   [hex_label] = generate_hex_label(type, char_label)

hex_label.type = type;
hex_label.char_label = char_label;

end


% -------------------------------------------------------------------------
%     MAC table
% -------------------------------------------------------------------------
function [mac_table_label] = generate_mac_table_label(channels, char_label)
%   [mac_table_label] = generate_mac_table_label(channels, char_label)

mac_table_label.channels = split_flag(channels);
mac_table_label.char_label = char_label;

end


% -------------------------------------------------------------------------
%     NOISE
% -------------------------------------------------------------------------
function [noise_label] = generate_noise_label( cochannel, map_size, channels, leakage_type )
%   [noise_label] = generate_noise_label( cochannel, map_size, channels,
%   leakage_type )

noise_label.cochannel = cochannel;
noise_label.map_size = map_size;

% 'TV' case included for backwards-compatibility/default option
channels = validate_flags('', 'channels', channels);
noise_label.channels = channels;

noise_label.leakage_type = leakage_type;

end


% -------------------------------------------------------------------------
%     PL_SQUARES
% -------------------------------------------------------------------------
function [pl_squares_label] = generate_pl_squares_label( type, width, p, pop_type, map_size, char_label )
%   [pl_squares_label] = generate_pl_squares_label( type, width, p, pop_type,
%       map_size, char_label )

pl_squares_label.type = type;

switch(type)
    case 'local',       width = 0;  % can only support width=0 right now
    case 'long_range',  p = 0;      % set to 0 -- p doesn't matter
                        pop_type = 'none';  % population doesn't matter
end
pl_squares_label.width = width;
pl_squares_label.p = p;

pl_squares_label.population_type = generate_population_type(pop_type);

pl_squares_label.map_size = map_size;
char_label.power = 0;
pl_squares_label.char_label = char_label;

end

% -------------------------------------------------------------------------
%     POPULATION
% -------------------------------------------------------------------------
function [population_label] = generate_population_label( type, population_type, map_size )
%   [population_label] = generate_population_label( type, population_type, map_size )

population_label.type = type;
population_label.population_type = generate_population_type(population_type);
population_label.map_size = map_size;

end


% -------------------------------------------------------------------------
%     REGION_AREAS
% -------------------------------------------------------------------------
function [region_areas_label] = generate_region_areas_label( map_size, varargin )
%   [region_areas_label] = generate_region_areas_label( map_size, [type] )

region_areas_label.map_size = map_size;

if nargin > 1
    region_areas_label.type = varargin{1};
else
    region_areas_label.type = 'masked';
end

end


% -------------------------------------------------------------------------
%     REGION_MASK
% -------------------------------------------------------------------------
function [region_mask_label] = generate_region_mask_label( map_size )
%   [region_mask_label] = generate_region_mask_label( map_size )

region_mask_label.map_size = map_size;

end


% -------------------------------------------------------------------------
%     REGION_OUTLINE
% -------------------------------------------------------------------------
function [region_outline_label] = generate_region_outline_label( map_size )
%   [region_outline_label] = generate_region_outline_label( map_size )

region_outline_label.map_size = map_size;

end




% -------------------------------------------------------------------------
%     HELPER FUNCTIONS
% -------------------------------------------------------------------------
function [string pop_year pop_type] = generate_population_type(population_type)
%   [string pop_year] = generate_population_type(population_type)

[pop_type pop_year_str] = split_flag(population_type);

switch(pop_type)
    case 'none',    % Do nothing
        pop_year = 'none';
        string = 'none';
    otherwise,
        switch(pop_year_str)
            case 'none',
                pop_year = get_simulation_value('pop_data_year');
                pop_year_str = num2str(pop_year);
                soft_warning(['Assuming population year ' ...
                    pop_year_str ' when creating label.']);
            otherwise,
                pop_year = str2double(pop_year_str);
        end
        string = [pop_type '-' pop_year_str];
end

end