function [varargout] = get_simulation_value(variable_name)
%   [value] = get_simulation_value(variable_name)
%
%   Returns default values for the variables below. Example usage:
%       get_simulation_value('map_size')
%
%
% LOCALIZATION
%   region_code - specifies which version of the code we are using
%       (currently this will return 'US' or 'AUS', US vs. Australia)
%   minmax_lat - [min_lat max_lat] for the map depending on the region code
%   minmax_long - [min_long max_long] for the map depending on the region code
%   region_shapefile - [S,A], the shapefile data describing the region
%   unused_channels - channels which are in the channel list but not used
%                       locally
%
% SIMULATION PARAMETERS
%   map_size - default map size (options: 200x300, 400x600, etc.)
%   apply_wireless_mic_exclusions - default choice for this option
%   recompute - recompute if .mat file exists? (1 = yes, 0 = no)
%   figure_visibility - display figures? ('on' = yes, 'off' = no)
%
% PROPAGATION
%   bandwidth - the width of one TV band in Hz
%   chan_list - list of TV channels
%   TNP - thermal noise power (noise on a clean channel)
%   target_TV_SNR - TV SNR reception threshold (dB)
%   dB_leak - how much each channel leaks (in dB) into its adjacent channels
%   cochannel_separation_distance - cochannel separation distance (km)
%   adjacent_channel_separation_distance - adj. channel separation dist. (km)
%
% DATA SOURCES
%   tower_data_year - year the tower data was gathered (options: 2008, 2011)
%   pop_data_year - year the population data was gathered (options: 2000, 2010)
%   pop_data_type - default population type (see valid_pop_types below)
%
% DATA RANGES
%   heights - heights allowed in our propagation model
%   distances - distances allowed in our propagation model
%   fade_margins - values of existing fade margin maps (dB)
%
% DIRECTORIES   (does NOT include trailing /)
%   data_dir - base directory for generated data
%   population_data_dir - base directory for raw population data
%   tower_data_dir - base directory for raw tower assignment data
%
% MISCELLANEOUS
%   labels - labels used within this code base
%   max_p_range - maximum range (in km) when calculating tower distance
%       based on population density
%   pl_squares_width - default range-of-influence for secondary
%       self-interference
%   hotspot_jam_radius - the radius (km) of a WiFi/hotspot cell in the jam model
%
% VALIDATION
%   valid_map_sizes - cell array of strings, each a valid value for map_size
%   valid_channels_descr - cell array of strings, each representing a
%       set of channels ('tv' or '52') and the corresponding year
%   valid_pop_data_years - matrix of integers, each a year for which we
%       have population data
%   valid_pop_types - cell array of strings, each a valid value for
%       population type
%   valid_device_types - cell array of strings, each for a valid device
%       type
%   valid_tower_data_years - cell array of strings, each for a valid tower
%       data year
%   valid_region_codes - cell array of strings, each a valid value for the
%       region code

switch(variable_name)
    
% BEGIN LOCALIZATION
    case 'region_code', value = 'US';   % select the version (US vs. AUS)
        % Note: if you change this, you will need to re-run 'run_me_first'
        % to set the path correctly.
        
    case 'minmax_lat',
        switch(get_simulation_value('region_code'))
            case 'US',  varargout = {24 50};
            case 'AUS', varargout = {-39.5 -10};
            otherwise,
                error(['Unsupported region code: ' ...
                    get_simulation_value('region_code')]);
        end
        
    case 'minmax_long',
        switch(get_simulation_value('region_code'))
            case 'US',  varargout = {-126 -66};
            case 'AUS', varargout = {112 155};
            otherwise,
                error(['Unsupported region code: ' ...
                    get_simulation_value('region_code')]);
        end
        
    case 'region_shapefile',
        switch(get_simulation_value('region_code'))
            case 'US',
                [S,A] = shaperead('usastatehi.shp', 'usegeocoords', true);
                varargout = {S,A};
            case 'AUS',
                [S,A] = shaperead('landareas.shp', 'usegeocoords', true);
                varargout = {S(5) A(5)};
            otherwise,
                error(['Unsupported region code: ' ...
                    get_simulation_value('region_code')]);
        end
        
    case 'unused_channels',
        switch(get_simulation_value('region_code'))
            case 'US',
                value = [3 4];
%             case 'AUS',
%                 value = [];
            otherwise,
                error(['Unsupported region code: ' ...
                    get_simulation_value('region_code')]);
        end
% END LOCALIZATION
      

% BEGIN SIMULATION PARAMETERS
    case 'map_size',
        value = '200x300';  % Default map size
        
    case 'apply_wireless_mic_exclusions',
        value = true;   % default value

    case 'recompute',
        value = 0;
            % 0 = do not recompute if .mat file exists
            % 1 = recompute even if .mat file exists

    case 'figure_visibility',
        value = 'off';
            % 'off' = don't display figures but still allow saving
            % 'on' = display figures normally
% END SIMULATION PARAMETERS


% BEGIN PROPAGATION
    case 'bandwidth',   value = 6e6;    % Hz

    case 'chan_list',
        % NOTE: code has not been tested to make sure it can handle a
        % change in chan_list
        switch(get_simulation_value('region_code'))
            case 'US',  value = [2:36 38:51];
            case 'AUS', value = [2:36 37:69];
                warning(['The Australian chan_list is not guaranteed to '...
                    'work properly yet.']);
            otherwise,
                error(['Unsupported region code: ' ...
                    get_simulation_value('region_code')]);
        end

    case 'TNP',
        % Find the thermal noise power
        k = 1.3803e-23; % Boltzmann's constant
        T = 290;        % Temperature in degrees Kelvin (~room temperature)
        B = get_simulation_value('bandwidth');
        value = k*T*B;     % Noise power in Watts

    case 'target_TV_SNR',
        value = 15;

    case 'dB_leak',
        % This is how much each channel leaks (in dB) into its adjacent
        % channels
        value = 50; % dB
        
    case 'cochannel_separation_distance',
        % NOTE: when changing the values below, we also need to change some
        % of the values in 'r_array' in make_jam.m (around line 484).
        switch(get_simulation_value('region_code'))
            case 'US',  value = 14.4;   % km
            case 'AUS', value = 14.4;   % km
            otherwise,
                error(['Unsupported region code: ' ...
                    get_simulation_value('region_code')]);
        end
        
    case 'adjacent_channel_separation_distance',
        switch(get_simulation_value('region_code'))
            case 'US',  value = 0.74;   % km
            case 'AUS', value = 0.74;   % km
            otherwise,
                error(['Unsupported region code: ' ...
                    get_simulation_value('region_code')]);
        end
% END PROPAGATION


% BEGIN DATA SOURCES
    case 'tower_data_year',
        switch(get_simulation_value('region_code'))
            case 'US',
                % Valid options: 2008, 2011; must be string to allow for
                % 2011a (for example)
                value = '2011';
            case 'AUS',
                value = '2012';
                warning(['The Australian tower data is not guaranteed to '...
                    'work properly yet.']);
            otherwise,
                error(['Unsupported region code: ' ...
                    get_simulation_value('region_code')]);
        end

    case 'pop_data_year',
        switch(get_simulation_value('region_code'))
            case 'US',
                % Valid options: 2000, 2010 (census years)
                value = 2010;
            case 'AUS',
                value = 2006;
                warning(['The Australian population data is not guaranteed to '...
                    'work properly yet.']);
            otherwise,
                error(['Unsupported region code: ' ...
                    get_simulation_value('region_code')]);
        end

    case 'pop_data_type',
        value = ['real-' num2str(get_simulation_value('pop_data_year'))];
% END DATA SOURCES


% BEGIN DATA RANGES
    case 'fade_margins',
%         file = load('Data/Fade margins/fade_margin_values.mat');
%         value = file.fade_margin;
        value = [[.001 .003 .005 .008 .010 .015 .020 .040 .060 .080 .090] ...
            .1:.1:1 1.2:.2:2 2.5:.5:10 11:20]; %[[0:0.1:1] [2:0.5:10] [11:20]];

    case 'heights',
        value = [10 20 37.5 75 150 300 600 1200]; % m

    case 'distances',
        value = [.01 * [1:10] .1 * [2:10] [2:20] [25:5:100] [110:10:200] [225:25:1000]]; % km
% END DATA RANGES


% BEGIN DIRECTORIES     (should NOT include trailing /)
    case 'data_dir',    % base directory for generated data
%         value = 'Data';
        value = ['Data/' upper(get_simulation_value('region_code'))];
        
    case 'population_data_dir', % base directory for population data
        value = [get_simulation_value('data_dir') ...
            '/Population_and_tower_data/Population'];
        
    case 'tower_data_dir',  % base directory for raw tower assignment data
        value = [get_simulation_value('data_dir') ...
            '/Population_and_tower_data/Tower'];
% END DIRECTORIES


% BEGIN MISCELLANEOUS
    case 'max_p_range', value = 100;    % km

    case 'labels',
        value = ['capacity, ccdf_points, char, fcc_mask, fm_mask, jam, hex, ' ...
            'mac_table, noise, pl_squares, population, region_areas, ' ...
            'region_mask, region_outline'];

    case 'pl_squares_width',
        value = 10;

    case 'hotspot_jam_radius',
        value = .1; % km = 100 m    -- This is the radius of a wifi/hotspot cell in the jam model
% END MISCELLANEOUS


% BEGIN VALIDATION
    case 'valid_map_sizes',
        value = {'200x300', '201x301', '400x600', '800x1200', '1600x2400', ...
            '20x30', '3200x4800', '100x150'};

    case 'valid_region_codes',  value = {'US', 'AUS'};  % US, Australia

    % Update this when new tower data is added
    case 'valid_tower_data_years',
        switch(get_simulation_value('region_code'))
            case 'US',
                value = {'2011'};
            case 'AUS',
                value = {'2012'};
                warning(['The Australian tower data is not guaranteed to '...
                    'work properly yet.']);
            otherwise,
                error(['Unsupported region code: ' ...
                    get_simulation_value('region_code')]);
        end

    % Update this when new population data is added
    case 'valid_pop_data_years',
        switch(get_simulation_value('region_code'))
            case 'US',
                % Valid options: 2000, 2010 (census years)
                value = [2000, 2010];
            case 'AUS',
                value = [2006];
                warning(['The Australian population data is not guaranteed to '...
                    'work properly yet.']);
            otherwise,
                error(['Unsupported region code: ' ...
                    get_simulation_value('region_code')]);
        end

    % Automatically updated with new tower data years
    case 'valid_channels_descr',
        base_values = {'tv'};
        value = base_values;
        valid_years = get_simulation_value('valid_tower_data_years');
        for y = 1:length(valid_years)
            year = valid_years{y};
            for bv = 1:length(base_values)
                value{end+1} = [base_values{bv} '-' year];
            end
        end
        value{end+1} = '52';

    % Automatically updated with new population data years
    case 'valid_pop_types',
        base_values = {'uniform', 'real' 'min', 'max'};
        value = {'none'};
        valid_years = get_simulation_value('valid_pop_data_years');
        for y = 1:length(valid_years)
            year = valid_years(y);
            for bv = 1:length(base_values)
                value{end+1} = [base_values{bv} '-' num2str(year)];
            end
        end

    % Automatically updated with new tower data years
    case 'valid_device_types',
        base_values = {'tv', 'cr'};
        value = base_values;
        valid_years = get_simulation_value('valid_tower_data_years');
        for y = 1:length(valid_years)
            year = valid_years{y};
            for bv = 1:length(base_values)
                value{end+1} = [base_values{bv} '-' year];
            end
        end
        value{end+1} = 'cr_portable';        
% END VALIDATION


    otherwise,
        error(['Unknown name for requested variable: ' variable_name]);
end

if exist('value', 'var')
    varargout{1} = value;
end

end