function [value] = get_simulation_value(variable_name)
%   [value] = get_simulation_value(variable_name)
%
%   Returns default values for the variables below.
%
% Supported variable:
%
%   bandwidth - the width of one TV band in Hz
%   max_p_range - maximum range (in km) when calculating tower distance
%       based on population density
%   chan_list - list of TV channels
%   TNP - thermal noise power (noise on a clean channel)
%   target_TV_SNR - TV SNR reception threshold (dB)
%   fade_margins - values of existing fade margin maps (dB)
%   recompute - recompute if .mat file exists? (1 = yes, 0 = no)
%   figure_visibility - display figures? ('on' = yes, 'off' = no)
%   heights - heights allowed in our propagation model
%   distances - distances allowed in our propagation model
%   labels - labels used within this code base
%   tower_data_year - year the tower data was gathered (options: 2008, 2011)
%   pop_data_year - year the population data was gathered (options: 2000, 2010)
%   pop_data_type - default population type (see valid_pop_types below)
%   map_size - default map size (options: 200x300, 400x600)
%   dB_leak - how much each channel leaks (in dB) into its adjacent channels
%   pl_squares_width - default range-of-influence for secondary
%       self-interference
%   hotspot_jam_radius - the radius (km) of a WiFi/hotspot cell in the jam model
%
%
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

switch(variable_name)
    case 'bandwidth',   value = 6e6;    % Hz
    case 'max_p_range', value = 100;    % km
        
    % NOTE: code has not been tested to make sure it can handle a change in
    % chan_list
    case 'chan_list',
        value = [[2:36] [38:51]];
        
    case 'TNP',
        % Find the thermal noise power
        k = 1.3803e-23; % Boltzmann's constant
        T = 290;        % Temperature in degrees Kelvin (~room temperature)
        B = get_simulation_value('bandwidth');
        value = k*T*B;     % Noise power in Watts
        
    case 'target_TV_SNR',
        value = 15;
        
    case 'fade_margins',
%         file = load('Data/Fade margins/fade_margin_values.mat');
%         value = file.fade_margin;
        value = [[.001 .003 .005 .008 .010 .015 .020 .040 .060 .080 .090] .1:.1:1 1.2:.2:2 2.5:.5:10 11:20]; %[[0:0.1:1] [2:0.5:10] [11:20]];

    case 'recompute',
        value = 0;
            % 0 = do not recompute if .mat file exists
            % 1 = recompute even if .mat file exists
            
    case 'figure_visibility',
        value = 'off';
            % 'off' = don't display figures but still allow saving
            % 'on' = display figures normally
            
    case 'heights',
        value = [10 20 37.5 75 150 300 600 1200]; % m
        
    case 'distances',
        value = [.01 * [1:10] .1 * [2:10] [2:20] [25:5:100] [110:10:200] [225:25:1000]]; % km
        
    case 'labels',
        value = 'capacity, ccdf_points, char, fcc_mask, fm_mask, jam, hex, mac_table, noise, pl_squares';
        
    case 'tower_data_year',
        value = '2011';   % Valid options: 2008, 2011; must be string to allow for 2011a (e.g.)
    
    case 'map_size',
        value = '200x300';  % Default map size
        
    case 'dB_leak',
        value = 50; % This is how much each channel leaks (in dB) into its adjacent channels
        
    case 'pop_data_year',
        value = 2010;   % Valid options: 2000, 2010 (census years)
        
    case 'pop_data_type',
        value = ['real-' num2str(get_simulation_value('pop_data_year'))];
        
    case 'pl_squares_width',
        value = 10;
        
    case 'hotspot_jam_radius',
        value = .1; % km = 100 m    -- This is the radius of a wifi/hotspot cell in the jam model
        
        
    % Arrays of valid values
    case 'valid_map_sizes',
        value = {'200x300', '201x301', '400x600', '800x1200', '1600x2400', '20x30'};
        
    case 'valid_channels_descr',
        value = {'tv-2008', 'tv-2011', '52', 'tv'};
        
    case 'valid_pop_data_years',
        value = [2000, 2010];
        
    case 'valid_pop_types',
        value = {'none', 'uniform-2000', 'uniform-2010', 'real-2000', 'real-2010', ...
            'min-2000', 'min-2010', 'max-2000', 'max-2010'};
        
    case 'valid_device_types',
        value = {'tv', 'cr', 'cr_portable', 'tv-2008', 'tv-2011', 'cr-2008', 'cr-2011'};
        
    case 'valid_tower_data_years',
        value = {'2011'};
        
    otherwise,
        error(['Unknown name for requested variable: ' variable_name]);
end

    
end