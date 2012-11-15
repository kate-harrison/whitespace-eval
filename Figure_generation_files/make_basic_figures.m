% Generates some of the basic figures


% clc; clear all; close all;
% global map_size;



%%     NUMBER OF CHANNELS AVAILABLE THROUGHOUT THE US TO COGNITIVE RADIOS

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
options.filename = 'Number of channels available throughout the US to cognitive radios';

% Plot
make_map(allowed, options);


%%     BASIC CAPACITY MAPS

clc; clear all; close all;


% Simulation options
visible = get_simulation_value('figure_visibility');
overwrite_existing_figures = 1;
channels = 'tv';
map_size = get_simulation_value('map_size');
population_type = 'real';
noise_label = generate_label('noise', 'yes', map_size, channels, 'both');
fake_char_label = generate_label('char', 30, 4);
% Variables
chars = { ...
    generate_label('char', 30, 4), ...
    generate_label('char', 10.1, 4), ...
    generate_label('char', 30, 100e-3), ...
    generate_label('char', 10.1, 100e-3) ...
    };
capacity_types = {'single_user', 'per_area', 'per_person', 'raw'};
exclusions = { ...
    generate_label('fcc_mask', 'cr', map_size), ...
    generate_label('fm_mask', 'cr', map_size, 1, fake_char_label) ...
    };
range_types = {'r', 'p'};
r_values = [1 4.1 10];  % km
p_values = [2000]; % people per tower
% p_values = [125 250 500 1000 2000 4000 8000 16000];



% Specify plotting options
options.visibility = visible;
options.state_outlines = 'on';
options.filename = 'Number of channels available throughout the US to cognitive radios';
options.map_type = 'log';
options.autolabel = 'on';



for char_type = 1:4
    char_label = chars{char_type};
    mac_table_label = generate_label('mac_table', channels, char_label);
    for c_type = 2:4
        capacity_type = capacity_types{c_type};
        for e_type = 1:2
            exclusions_label = exclusions{e_type};
            % Fix the char label for the FM mask
            if (strcmp(exclusions_label.label_type, 'fm_mask'))
                exclusions_label.char_label = char_label;
            end
            
            for r_type = 1:2
                range_type = range_types{r_type};
                switch(range_type)
                    case 'r',
                        range_values = r_values;
                    case 'p',
                        range_values = p_values;
                end
                
                for range_value = range_values
                    
                    
                    % Generate the label and filename
                    capacity_label = generate_label('capacity', capacity_type, range_type, ...
                        range_value, population_type, char_label, noise_label, mac_table_label);
                    capacity_filename = generate_filename(capacity_label);
                    
                    plot_title = ['FIGURE ' capacity_filename];
                    % If the figure already exists, don't make it again
                    if (overwrite_existing_figures == 0 && ...
                            exist(['Output/' plot_title '.jpeg'], 'file') == 2)
                        continue;
                    end
                    
                    
                    % If the .mat file hasn't already been generated (or we
                    % are set to overwrite existing .mat files), this line
                    % will generate the .mat file.
                    total_capacity = get_total_capacity(capacity_label, exclusions_label);
                    
                    % Make the figure
                    close all;
                    
                    % Change a few plot options
                    options.title = plot_title;
                    options.filename = plot_title;
                    
                    make_map(total_capacity, options);

                end
            end
        end
        
    end
    
end