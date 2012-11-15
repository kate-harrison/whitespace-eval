function [label] = deconstruct_filename( filename )
%   [label] = deconstruct_filename( filename )
% Generates the label based on the filename

error(['This function is no longer supported due to lack of use. It was '...
    'last current on Nov 9, 2011.']);

% Changes that would need to happen to make this function current
% * Rearranged jam filename and added population data+year

type = determine_file_type(filename);

switch(type)
    case 'capacity',
        label = deconstruct_capacity_filename(filename);
    case 'ccdf_points',
        label = deconstruct_ccdf_points_filename(filename);
    case 'char',
        label = deconstruct_char_filename(filename);
    case 'fcc_mask',
        label = deconstruct_fcc_mask_filename(filename);
    case 'fm_mask',
        label = deconstruct_fm_mask_filename(filename);
    case 'jam',
        label = deconstruct_jam_filename(filename);
    case 'hex',
        label = deconstruct_hex_filename(filename);
    case 'mac_table',
        label = deconstruct_mac_table_filename(filename);
    case 'noise',
        label = deconstruct_noise_filename(filename);
    case 'pl_squares',
        label = deconstruct_pl_squares_filename(filename);
    otherwise,
        switch(filename)
            case 'none', label = 'none';
            otherwise,
                error(['Unrecognized filename: ' filename]);
        end
end




end



function [type] = determine_file_type(filename)
%   determine_file_type(label)

[split] = regexp(filename, '\s', 'split');
type = lower(split{1});

end


% -------------------------------------------------------------------------
%     CAPACITY
% -------------------------------------------------------------------------
function [capacity_label] = deconstruct_capacity_filename(capacity_filename)
%   [capacity_label] = deconstruct_capacity_filename(capacity_filename) 

[label_split] = regexp(capacity_filename, '(', 'split');

% Take apart the pure capacity part
pure_cap_label = label_split{1};
[split] = regexp(pure_cap_label, '\s', 'split');

[result] = regexp(split{2}, '=', 'split');
capacity_type = result{2};

[result] = regexp(split{3}, '=', 'split');
range_type = result{1};
range_value = result{2};

[result] = regexp(split{4}, '=', 'split');
population_type = result{2};




% Split again to get just the char label
char_label_split = regexp(label_split{2}, ')', 'split');
char_filename = char_label_split{1};
char_label = deconstruct_filename(char_filename);

% Split again to get just the noise label
noise_label_split = regexp(label_split{3}, ')', 'split');
noise_filename = noise_label_split{1};
noise_label = deconstruct_filename(noise_filename);

% Split again to get just the cell model label
mac_table_label_split = regexp(capacity_filename, 'MAC');
mac_table_filename = capacity_filename(mac_table_label_split:end-1);
if (~isempty(mac_table_filename))
    cell_model_filename = mac_table_filename;
else
    mac_table_label_split = regexp(capacity_filename, 'HEX');
    cell_model_filename = capacity_filename(mac_table_label_split:end-1);
end
cell_model_label = deconstruct_filename(cell_model_filename)


% Generate the label structure
capacity_label = generate_label('capacity', capacity_type, range_type, range_value, ...
    population_type, char_label, noise_label, cell_model_label);

end


% -------------------------------------------------------------------------
%     CCDF points
% -------------------------------------------------------------------------
function [ccdf_points_label] = deconstruct_ccdf_points_filename(ccdf_points_filename)
%   [variable, mask_type, capacity_label] =
%   deconstruct_ccdf_points_label(ccdf_points_filename)


[label_split] = regexp(ccdf_points_filename, '(', 'split');

% Take apart the pure capacity part
pure_ccdf_filename = label_split{1};
[split] = regexp(pure_ccdf_filename, '\s', 'split');

[result] = regexp(split{2}, '=', 'split');
variable = result{2};

[result] = regexp(split{3}, '=', 'split');
mask_type = result{2};

% capacity_label_split = regexp(label_split{2}, ')', 'split');

idx = regexp(ccdf_points_filename, '(', 'start');
capacity_filename = ccdf_points_filename(idx(1)+1:end-1);

capacity_label = deconstruct_filename(capacity_filename);
ccdf_points_label = generate_label('ccdf_points', variable, mask_type, capacity_label);


end


% -------------------------------------------------------------------------
%     CHAR(acteristics)
% -------------------------------------------------------------------------
function [char_label] = deconstruct_char_filename(char_filename)
%   [char_label] = deconstruct_char_filename(char_filename)

[split] = regexp(char_filename, '\s', 'split');

[result] = regexp(split{2}, '=', 'split');
height = str2double(result{2});

[result] = regexp(split{3}, '=', 'split');
power = str2double(result{2});

char_label = generate_label('char', height, power);

end


% -------------------------------------------------------------------------
%     FCC mask
% -------------------------------------------------------------------------
function [fcc_mask_label] = deconstruct_fcc_mask_filename(fcc_mask_filename)
%   [fcc_mask_label] = deconstruct_mask_filename(fcc_mask_filename)

[split] = regexp(fcc_mask_filename, '\s', 'split');

[result] = regexp(split{2}, '=', 'split');
device_type = result{2};

[result] = regexp(split{3}, '=', 'split');
map_size = result{2};

fcc_mask_label = generate_label('fcc_mask', device_type, map_size);

end


% -------------------------------------------------------------------------
%     F(ade) M(argin) mask
% -------------------------------------------------------------------------
function [fm_mask_label] = deconstruct_fm_mask_filename(fm_mask_filename)
%   [fm_mask_label] = deconstruct_mask_filename(fm_mask_filename)

[label_split] = regexp(fm_mask_filename, '(', 'split');

% Take apart the pure capacity part
pure_fcc_mask_label = label_split{1};
[split] = regexp(pure_fcc_mask_label, '\s', 'split');

[result] = regexp(split{2}, '=', 'split');
device_type = result{2};

[result] = regexp(split{3}, '=', 'split');
map_size = result{2};

[result] = regexp(split{4}, '=', 'split');
margin_value = str2double(result{2});


if (strcmpi(device_type, 'cr'))
    % Split again to get just the char label
    char_label_split = regexp(label_split{2}, ')', 'split');
    char_filename = char_label_split{1};
    
    char_label = deconstruct_filename(char_filename);
else
    char_label = 'none';
end

fm_mask_label = generate_label('fm_mask', device_type, map_size, margin_value, char_label);

end



% -------------------------------------------------------------------------
%     JAM model
% -------------------------------------------------------------------------
function [jam_label] = deconstruct_jam_filename(jam_filename)
%   [jam_label] = deconstruct_jam_filename(jam_filename)

[label_split] = regexp(jam_filename, ' ', 'split');

% Stage
stage = label_split{2};

% Model number
[model_split] = regexp(label_split{3}, '=', 'split');
model = str2num(model_split{2});

% Power type
[power_split] = regexp(label_split{4}, '=', 'split');
power_type = power_split{2};

% Split again to get just the char label
char_label_split = regexp(jam_filename, '(', 'split');
char_label_split2 = regexp(char_label_split{2}, ')', 'split');
char_filename = char_label_split2{1};
char_label = deconstruct_filename(char_filename);

% Tax
[tax_split] = regexp(label_split{8}, '=', 'split');
tax = str2num(tax_split{2});

% p
[p_split] = regexp(label_split{9}, '=', 'split');
p = p_split{2};
if (length(regexp(p, ',', 'split')) == 1)
    p = str2num(p);
end

% Split again to get just the char label
noise_label_split = regexp(jam_filename, '(', 'split');
noise_label_split2 = regexp(noise_label_split{3}, ')', 'split');
noise_filename = noise_label_split2{1};
noise_label = deconstruct_filename(noise_filename);


% Generate the label structure
jam_label = generate_label('jam', stage, model, power_type, char_label, tax, p, noise_label);

end




% -------------------------------------------------------------------------
%     HEX(agon) cell model
% -------------------------------------------------------------------------
function [hex_label] = deconstruct_hex_filename(hex_filename)
%   [hex_label] = deconstruct_hex_filename(hex_filename)

[split] = regexp(hex_filename, '\s', 'split');

[result] = regexp(split{2}, '=', 'split');
type = result{2};

[another_split] = regexp(hex_filename, '(', 'split');
char_filename = another_split{2}(1:end-1);

char_label = deconstruct_filename(char_filename);
hex_label = generate_label('hex', type, char_label);

end


% -------------------------------------------------------------------------
%     MAC table
% -------------------------------------------------------------------------
function [mac_table_label] = deconstruct_mac_table_filename(mac_table_filename)
%   [mac_table_label] = deconstruct_mac_table_filename(mac_table_filename)

[split] = regexp(mac_table_filename, '\s', 'split');

[result] = regexp(split{2}, '=', 'split');
channels = result{2};

[another_split] = regexp(mac_table_filename, '(', 'split');
char_filename = another_split{2}(1:end-1);

char_label = deconstruct_filename(char_filename);
mac_table_label = generate_label('mac_table', channels, char_label);


end


% -------------------------------------------------------------------------
%     NOISE
% -------------------------------------------------------------------------
function [noise_label] = deconstruct_noise_filename(noise_filename)
%   [noise_label] = deconstruct_noise_filename(noise_filename)

[split] = regexp(noise_filename, '\s', 'split');

[result] = regexp(split{2}, '=', 'split');
cochannel = result{2};

[result] = regexp(split{3}, '=', 'split');
map_size = result{2};

[result] = regexp(split{4}, '=', 'split');
channels = result{2};

[result] = regexp(split{5}, '=', 'split');
leakage_type = result{2};

noise_label = generate_label('noise', cochannel, map_size, channels, leakage_type);

end



% -------------------------------------------------------------------------
%     PL_SQUARES
% -------------------------------------------------------------------------
function [pl_squares_label] = deconstruct_pl_squares_filename(pl_squares_filename)
%   [noise_label] = deconstruct_noise_filename(noise_filename)

[split] = regexp(pl_squares_filename, '\s', 'split');

[result] = regexp(split{2}, '=', 'split');
type = result{2};

[result] = regexp(split{3}, '=', 'split');
width = str2num(result{2});
 
[result] = regexp(split{4}, '=', 'split');
p = str2num(result{2});

[result] = regexp(split{5}, '=', 'split');
map_size = result{2};

% Split again to get just the char label
char_label_split = regexp(pl_squares_filename, '(', 'split');
char_label_split2 = regexp(char_label_split{2}, ')', 'split');
char_filename = char_label_split2{1};
char_label = deconstruct_filename(char_filename);

pl_squares_label = generate_label('pl_squares', type, width, p, map_size, char_label);

end

