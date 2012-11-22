function [] = run_all()
% Makes most desired files all at once

clc;

global screen_width;
screen_width = 80;


%% Start diary
delete('run_all_transcript.txt');   % Clear the previous diary
diary('run_all_transcript.txt');

%% Greet the user
wrap_display_msg(['From basic population data, TV tower data, and a propagation '...
    'model, this code will generate the data necessary to make most basic figures.']);

wrap_display_msg(['Please note that some of the data may take a while to generate and you ' ...
    'are advised to examine the contents of this file for more details. Of ' ...
    'course, you may press Ctrl+C at any time to stop the process and all ' ...
    'but the current data set will be saved. If you choose to do so, please ' ...
    'call ''diary off'' afterward if you wish to ensure that the diary is saved.']);

wrap_display_msg(['Feel free to comment out bits of code you don''t need. '...
    'If you wish to continue, please press any key now.']);

wrap_display_msg(['Finally, there will be a diary kept of the output since ' ...
    'every script clears the screen before it is run.']);

pause;


%% Set up the path and make necessary directories
status_msg('Setting up path, directories, and defaults');
run_me_first;

%% Define global variables
global map_size chars pop_year tower_year tv_channels cr_channels ...
    population_type p_array r_array jam_models jam_taxes;

%% We'll use the default map size and census year
% status_msg('Choose default parameters');
map_size = get_simulation_value('map_size');
pop_year = get_simulation_value('pop_data_year');
tower_year = get_simulation_value('tower_data_year');
tv_channels = ['tv-' tower_year];
cr_channels = ['cr-' tower_year];
population_type = combine_flag('real', pop_year);


%% These are the different characteristics to evaluate
% status_msg('Define CR characteristics of interest');
chars_temp(1) = generate_label('char', 30, 4);
% chars_temp(2) = generate_label('char', 10.1, 4);
% chars_temp(3) = generate_label('char', 30, 100e-3);
% chars_temp(4) = generate_label('char', 10.1, 100e-3);

% We have to do this little dance because we declare chars to be global
% which automatically intializes it as a matrix rather than as an array of
% structs, producing an error. This avoids that problem.
chars = chars_temp;


%% These are the different range values to evaluate
r_array =  [1 4.1 10];
p_array = 2000;
% p_array = [125 250 500 1000 2000 4000 8000 16000];

%% Different jam models to use
jam_models = 1:4;
jam_taxes = .5;

%% Make descretized US map and area
status_msg('Making US maps');
make_us_map(map_size);
make_us_area(map_size);

%% Read and process the TV tower data
status_msg('Reading tower data');
read_tower_data(tower_year);

%% Read and process the population data
status_msg('Making population data');
make_pop_info(pop_year);
make_tract_info(pop_year);
population_label = generate_label('population', 'raw', population_type, map_size);
make_population(population_label);
get_tower_nearby_pops(pop_year, tower_year);

%% Miscellaneous
status_msg('Making miscellaneous files');
make_colors();
make_plot_parameters();
region_outline_label = generate_label('region_outline', map_size);
make_region_outline(region_outline_label);

%% Make masks (FM and FCC)
status_msg('Making FCC and fade-margin masks');
make_masks();

%% Make noise (from TV towers) data
status_msg('Making TV noise maps');
make_noise_maps();

%% Make the MAC tables (for use in capacities)
% Time: approx. 10 seconds per set of characteristics
status_msg('Making MAC tables');
make_mac_tables();

%% Make basic capacities
% For each characteristic, we compute the following number of capacity
% maps:
%   * 2 capacity types (single_user, per_area)
%   * 2 range types (r = [1 4.1 10] km, p = [2000])
%   * number of range values
%   * 1 noise type (cochannel: real or thermal noise)
%   * 1 leakage type (both adjacent channels)
%   = 2 * (3+1) * 1 * 1 = 8 maps
% Time per map: 
%   + single_user: 30 seconds?
%   + per_area (includes per_person, raw): 10 minutes?
% Total time: 4*(30 seconds) + 4*(10 minutes) = ~42 minutes
status_msg('Making basic capacities');
make_basic_capacities();
make_basic_capacities_extra();

%% NEED TO MAKE PRE-HEX FILES
status_msg('Precomputing hexagon data');
make_hex_files();

%% Make hex capacities
status_msg('Making hex capacities');
make_hex_capacities();

%% Make CCDF points
status_msg('Making CCDF points');
make_ccdfs();

%% Precompute for map-level secondary self-interference
status_msg('Precomputing for map-level secondary self-interference');
make_pathloss_squares();

%% Make jam data and capacities
status_msg('Making jam data and capacities');
make_jam_capacities();



%%
diary off;

end

function [] = wrap_display_msg(msg)

global screen_width;

wrap_length = screen_width;

splits = regexp(msg, ' ', 'split');

reset = 1;
out = [' '];
for i = 1:length(splits)
    
    prop_length = length(out) + 1 + length(splits{i});
    
    if (prop_length > wrap_length - 1)
        if (reset && i > 1)  % We didn't add the string last time because it was too long
            out = [splits{i-1}];
        end
        
        out = strtrim(out); % Remove excess whitespace
        disp(out);
        reset = 1;
    end
    
    if (reset)
        out = [];
        reset = 0;
    end
    
    out = [out ' ' splits{i}];
    
    
end
out = strtrim(out); % Remove excess whitespace
disp(out);

disp(' ');

end


function [] = status_msg(msg)

global screen_width;

msg2 = [' = ' strtrim(upper(msg)) ' = '];
pad_length = screen_width - mod(length(msg2), screen_width);
try
    msg2 = [repmat('-', 1, ceil(pad_length/2)) msg2 repmat('-', 1, floor(pad_length/2))];
% display_greeting = reshape(greeting, wrap_length, length(greeting)/wrap_length)';
% disp(display_greeting);
catch err
    pad_length
    screen_width
    length(msg2)
end
disp(msg2);


end


function [] = make_noise_maps()

global map_size tv_channels;

% TV channels
channels = tv_channels;

% Noise type
for n_type = 1:2
    switch(n_type)
        case 1, cochannel = 'yes';
        case 2, cochannel = 'no';
    end
    
    % Leakage type
    for l_type = 1:4
        switch(l_type)
            case 1, leakage_type = 'none';
            case 2, leakage_type = 'both';
            case 3, leakage_type = 'up';
            case 4, leakage_type = 'down';
        end
        noise_label = generate_label('noise', cochannel, map_size, channels, ...
            leakage_type);  
        make_noise(noise_label);
    end
end


%% 700 MHz / channel 52
channels = '52';
cochannel = 'no';
leakage_type = 'none';
noise_label = generate_label('noise', cochannel, map_size, channels, leakage_type);
make_noise(noise_label);

end


function [] = make_masks()
global cr_channels tv_channels chars map_size

% FCC masks
for i = 1:2
    switch(i)
        case 1, device_type = cr_channels;
        case 2, device_type = tv_channels;
    end
    
    fcc_mask_label = generate_label('fcc_mask', device_type, map_size);
    make_fcc_mask(fcc_mask_label);
end



% Fade margin masks
fm_margins = get_simulation_value('fade_margins');

% Characteristic
for i = 1:length(chars)
    char_label = chars(i);
    
    % Fade margins
    for m = 1:length(fm_margins)
        margin = fm_margins(m);
        
        fm_mask_label = generate_label('fm_mask', cr_channels, map_size, margin, char_label);
        make_fm_mask(fm_mask_label);
    end
end

end


function [] = make_mac_tables()
global chars;
for ch_type = 1:2
    switch(ch_type)
        case 1, channels = 'tv';
        case 2, channels = '52';
    end
    
    for i = 1:length(chars)
        mac_table_label = generate_label('mac_table', channels, chars(i));
        make_mac_table(mac_table_label);
    end
end

end


function [] = make_basic_capacities()
global chars map_size tv_channels population_type p_array r_array;

% TV channels
channels = tv_channels;

% Characteristic
for i = 1:length(chars)
    
    % Capacity type
    for c_type = 1:2
        switch(c_type)
            case 1, capacity_type = 'single_user';
            case 2, capacity_type = 'per_area';
        end
        
        % Range type
        for r_type = 1:2
            switch(r_type)
                case 1, range_type = 'r'; r_val_array = r_array;
                case 2, range_type = 'p'; r_val_array = p_array;
            end
            
            % Range value
            for r_val = 1:length(r_val_array)
                range_value = r_val_array(r_val);
                
                % Noise type
                for n_type = 1:2
                    switch(n_type)
                        case 1, cochannel = 'yes';
                        case 2, cochannel = 'no';
                    end
                    
                    % Noise leakage type
                    for l_type = 1:4
                        switch(l_type)
                            case 1, leakage_type = 'both';
                            case 2, leakage_type = 'none';
                            case 3, leakage_type = 'up';
                            case 4, leakage_type = 'down';
                        end
                        
                        char_label = chars(i);
                        noise_label = generate_label('noise', cochannel, map_size, channels, ...
                            leakage_type);
                        mac_table_label = generate_label('mac_table', channels, char_label);
                        capacity_label = generate_label('capacity', capacity_type, range_type, ...
                            range_value, population_type, char_label, noise_label, mac_table_label);
                        make_capacity(capacity_label);
                    end
                end
            end
        end
    end
end

end


function [] = make_basic_capacities_extra()
global map_size tv_channels population_type;

% Set basic parameters
channels = tv_channels;
capacity_type = 'single_user';
range_type = 'r';
r_val_array = [.1 .5 1 5 10 50 100 500 1000];
height_array = [30 10.1 20:20:100];
power = 4;  % Watts

% Noise type
cochannel = 'yes';
leakage_type = 'both';
noise_label = generate_label('noise', cochannel, map_size, channels, ...
    leakage_type);

cell_model_label = 'none';


% Height
for h = 1:length(height_array)
    height = height_array(h);
    char_label = generate_label('char', height, power);
    
    % Range value
    for r_val = 1:length(r_val_array)
        range_value = r_val_array(r_val);
        
        capacity_label = generate_label('capacity', capacity_type, range_type, ...
            range_value, population_type, char_label, noise_label, cell_model_label);
        make_capacity(capacity_label);
        
        ccdf_label = generate_label('ccdf_points', 'fade_margin', 'fcc', capacity_label);
        make_ccdf_points(ccdf_label);
        
    end
end

end


function [] = make_ccdfs()
global chars map_size tv_channels population_type p_array r_array;

% TV channels
channels = tv_channels;

noise_label = generate_label('noise', 'yes', map_size, channels, ...
    'both');


% Characteristic
for i = 1:length(chars)
    
    % Capacity type
    for c_type = 1:2
        switch(c_type)
            case 1, capacity_type = 'single_user';
            case 2, capacity_type = 'per_area';
        end
        
        % Range type
        for r_type = 1:2
            switch(r_type)
                case 1, range_type = 'r'; r_val_array = r_array;
                case 2, range_type = 'p'; r_val_array = p_array;
            end
            
            % Range value
            for r_val = 1:length(r_val_array)
                range_value = r_val_array(r_val);
                
                % Model type (MAC vs. hex)
                for m_val = 1:2
                    char_label = chars(i);
                    switch(m_val)
                        case 1, cell_model_label = ...
                                generate_label('mac_table', channels, char_label);
                        case 2, cell_model_label = ...
                                generate_label('hex', 'cellular', char_label);
                            if (string_is(range_type, 'r'))
                                continue;
                            end
                    end
                    
                    
                    capacity_label = generate_label('capacity', capacity_type, range_type, ...
                        range_value, population_type, char_label, noise_label, cell_model_label);
                    
                    % TV removal case
                    %   Two different types, with and without sharing
                    %   alternative
                    for j = 1:2
                        variable = ['tv_removal-' num2str(j)];
                        ccdf_label = generate_label('ccdf_points', variable, 'none', capacity_label);
                        make_ccdf_points(ccdf_label);
                    end
                    
                    % Fade margin case
                    variable = 'fade_margin';
                    for a = 1:4
                        switch(a)
                            case 1, mask_type = 'fcc';
                            case 2, mask_type = 'fade_margin';
                            case 3, mask_type = 'fm-cochan';
                            case 4, mask_type = 'none';
                        end
                        ccdf_label = generate_label('ccdf_points', variable, mask_type, capacity_label);
                        make_ccdf_points(ccdf_label);
                    end
                    
                    % Make stacked graph data (just in case we left anything
                    % out)
                    get_fade_margin_stacked_graph_data(capacity_label);
                    
                end
            end
        end
    end
end



end


function [] = make_hex_files()
global chars;

for i = 1:length(chars)
    for t = 1:2
        switch(t)
            case 1, type = 'wifi';
            case 2, type = 'cellular';
        end
        
        hex_label = generate_label('hex', type, chars(i));
        make_hex(hex_label);
    end
    
end


end


function [] = make_hex_capacities()
global chars map_size tv_channels population_type p_array;

% TV channels
channels = tv_channels;

% Range type
range_type = 'p';



% Characteristic
for i = 1:length(chars)
    
    % Capacity type
    for c_type = 1:2
        switch(c_type)
            case 1, capacity_type = 'single_user';
            case 2, capacity_type = 'per_area';
        end
        
        % Range value
        for r_val = 1:length(p_array)
            range_value = p_array(r_val);
            
            % Noise type
            for n_type = 1
                switch(n_type)
                    case 1, cochannel = 'yes';
                    case 2, cochannel = 'no';
                end
                
                % Noise leakage type
                for l_type = 1
                    switch(l_type)
                        case 1, leakage_type = 'both';
                        case 2, leakage_type = 'none';
                        case 3, leakage_type = 'up';
                        case 4, leakage_type = 'down';
                    end
                    char_label = chars(i);
                    noise_label = generate_label('noise', cochannel, map_size, channels, ...
                        leakage_type);
                    hex_label = generate_label('hex', 'cellular', char_label);
                    capacity_label = generate_label('capacity', capacity_type, range_type, ...
                        range_value, population_type, char_label, noise_label, hex_label);
                    make_capacity(capacity_label);
                end
            end
        end
    end
end

end


function [] = make_pathloss_squares()

global map_size p_array chars population_type;

% Characteristics (though only height matters so we will end up
% skipping many of them)
height_array = unique([chars(:).height]);


% Local vs. long-range
for t = 1:2
    switch(t)
        case 1,
            type = 'local';
            width_array = 0;    % width doesn't matter for type='local'
            p_val_array = p_array;  % p value matters for 'local'
        case 2,
            type = 'long_range';
            width_array = [5 10 30];    % can vary width for type='long_range'
            p_val_array = 0;        % p value doesn't matter for 'long_range'
    end
    
    % Number of people per tower
    for p = p_val_array
        
        
        % Support width for long-range version
        for width = width_array
            
            % Heights
            for h = height_array
                char_label = generate_label('char', h, 0);
                pl_sq_label = generate_label('pl_squares', type, width, ...
                    p, population_type, map_size, char_label);
                generate_filename(pl_sq_label);
                make_pl_squares(pl_sq_label);
            end
        end
    end
    
end


end


function [] = make_jam_capacities()

global map_size chars  tv_channels tower_year ...
    population_type p_array jam_models jam_taxes;


% Characteristics (though only height matters so we will end up
% skipping many of them)
% height_array = unique([chars(:).height]);
height_array = 30;

p_val_array = [2000 125]; %p_array;

% Default noise label
noise_label = generate_label('noise', 'yes', map_size, tv_channels, 'both');

for s = 1:3
    switch(s)
        case 1, stage = 'chan_data';
        case 2, stage = 'power_map';
        case 3, stage = 'rate_map';
    end
    
    for p_type = 1:3
        switch(p_type)
            case 1, power_type = 'new_power';
            case 2, power_type = 'old_dream';
            case 3, power_type = 'flat3';
        end
        
        for model = jam_models
            for height = height_array
                for tax = jam_taxes
                    for p = p_val_array
                        char_label = generate_label('char', height, 0);
                        jam_label = generate_label('jam', stage, model, power_type, ...
                            population_type, tower_year, char_label, tax, p, ...
                            noise_label);
                        make_jam(jam_label);
                    end
                end
            end
        end
    end
end


end