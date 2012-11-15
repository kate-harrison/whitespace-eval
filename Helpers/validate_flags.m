function [varargout] = validate_flags(file_type, flag_type, flag_value)
%   [] = validate_flags(file_type, flag_type, flag_value)
%
%   Makes sure that variable values are valid. In some cases ('channels',
%   and 'device_type'), it outputs the default value for ambiguous cases.
%
%   Input options are too numerous to list, so please open the file if
%   unsure.
%
%   See also: generate_label, get_simulation_value, validate_label


% These are flags that may appear in multiple file types and thus bypass
% that routing system
switch(flag_type)
    case 'map_size',
        % Validate map size
        if ~any(string_is(flag_value, get_simulation_value('valid_map_sizes')))

            error(['Unrecognized map size ''' flag_value '''. Valid sizes: ' ...
                cellstr2str(get_simulation_value('valid_map_sizes'))]);
        end
        return;
        
    case 'channels',
        if any(string_is(flag_value, get_simulation_value('valid_channels_descr')))
            if (strcmp('tv', flag_value))
                % Get the default option
                varargout{1} = ['tv-' get_simulation_value('tower_data_year')];
            else
                varargout{1} = flag_value;
            end
            
        else    % no match found        
            error(['Invalid noise channel descriptor ''' flag_value '''. '...
                'Valid descriptors: ' ...
                cellstr2str(get_simulation_value('valid_channels_descr'))]);
        end
        return;
        
    case 'device_type',
        if any(string_is(flag_value, get_simulation_value('valid_device_types')))
            
            switch(flag_value)  % set defaults
                case 'tv',
                    varargout{1} = ['tv-' get_simulation_value('tower_data_year')];
                case 'cr',
                    varargout{1} = ['cr-' get_simulation_value('tower_data_year')];
                otherwise,
                    varargout{1} = flag_value;
            end
                        
            
        else    % no match found
            error(['Invalid device type ''' flag_value '''. '...
                'Valid types: ' cellstr2str(get_simulation_value('valid_device_types'))]);
            
        end
        return;

    case 'pop_data_year',
        if ~any(flag_value == get_simulation_value('valid_pop_data_years'))
            error(['Invalid year for population data. Valid years: ' ...
                num2str(get_simulation_value('valid_pop_data_years'))]);
        end
        return;
        
        
    case 'population_type',
        if any(string_is(flag_value, get_simulation_value('valid_pop_types')))
            % Do nothing
        else

            error(['Invalid population type ''' flag_value '''. '...
                'Valid types: ' cellstr2str(get_simulation_value('valid_pop_types'))]);
        end
        return;
        
    case 'tower_data_year',
        if ~any(string_is(flag_value, get_simulation_value('valid_tower_data_years')))
            error(['Invalid year for tower data. Valid years: ' ...
                cellstr2str(get_simulation_value('valid_tower_data_years'))]);
        end
        return;

        
end

switch(file_type)
    
    
    case 'jam',             % JAM
        switch(flag_type)
            case 'stage',
                switch(flag_value)
                    case {'chan_data', 'power_map', 'rate_map'}, % do nothing
                    otherwise, error(['Invalid jam stage: ' flag_value]);
                end
                
            case 'model',
                if (flag_value == 6)
                    display('*** Warning: model=6 is a special test model. Don''t use it normally!');
                else
                if (flag_value > 5 || flag_value < 0)
                    error(['Invalid jam model number: ' num2str(flag_value)]);
                end
                end
                
            case 'power_type',
                switch(flag_value)
                    case {'none', 'new_power', 'old_dream', 'flat3'}, % do nothing
                    otherwise, error(['Invalid jam power type: ' flag_value]);
                end
                
            case 'tax',
                if (flag_value < 0)
                    error(['Invalid jam tax: ' num2str(flag_value)]);
                end
                
            case 'p'
                if any(flag_value < 0)  % mostly trust generate_label to catch errors here
                    error(['Invalid jam p: ' num2str(flag_value)]);
                end
        end
        

        
    
    case 'capacity',        % CAPACITY
        switch(flag_type)
            case 'capacity_type',
                switch(flag_value)
                    case {'per_area', 'per_person', 'single_user', 'raw'}, % do nothing
                    otherwise, error(['Invalid capacity type: ' flag_value]);
                end
                
            case 'range_type',
                switch(flag_value)
                    case {'p', 'r'}, % do nothing
                    otherwise, error(['Invalid capacity range type: ' flag_value]);
                end
                
            case 'range_value',
                % This limit is imposed by our path loss model
                if (flag_value <= 0.01)
                    error(['Invalid capacity range value (must be > 0.01 km): ' flag_value]);
                end
                
            otherwise
                error(['Invalid flag type: ' flag_type]);
                
        end
        
    
    case 'ccdf_points',     % CCDF points
        switch(flag_type)
            case 'variable',
                switch(flag_value)
                    case {'tv_removal-1', 'tv_removal-2', 'fade_margin'}, % do nothing
                    otherwise, error(['Invalid CCDF points variable type: ' flag_value]);
                end
            case 'mask_type',
                switch(flag_value)
                    case {'fcc', 'fade_margin', 'fm-cochan', 'none'}, % do nothing
                    otherwise, error(['Invalid CCDF points mask type: ' flag_value]);
                end
        end
        
        
        
    
    case 'char',            % CHAR
        switch(flag_type)
            case 'height',
                % This limit is imposed by our path loss model
                if (flag_value <= 10 || flag_value >= 1200)
                    error(['Invalid height (must be >= 10 m, <= 1200 m): ' num2str(flag_value)]);
                end
                
            case 'power',
                if (flag_value < 0)
                    error(['Invalid power (must be >= 0): ' num2str(flag_value)]);
                end
        end
        
        
    case 'fcc_mask',        % FCC mask
        % All portions of this label are checked above
        

    case 'fm_mask',         % FM mask
        switch(flag_type)
            case 'margin_value',
                if (flag_value < 0)
                    error(['Invalid fade margin value: ' num2str(flag_value)]);
                end
        end
    
    case 'mac',             % MAC EXCLUSIONS
        % All portions of this label are checked above
        
            
    
    case 'noise',       % NOISE
        switch(flag_type)
            case 'cochannel',
                switch(flag_value)
                    case {'no', 'yes'}, % do nothing
                    otherwise,
                        error(['Invalid noise cochannel descriptor: ' flag_value]);
                end
                                
            case 'leakage_type',
                switch(flag_value)
                    case {'none', 'both', 'up', 'down'}, % do nothing
                    otherwise,
                        error(['Invalid noise leakage type: ' flag_value]);
                end
        end
        
    case 'pl_squares',
        switch(flag_type)
            case 'type',
                switch(flag_value)
                    case {'local', 'long_range'}, % do nothing
                    otherwise,
                        error(['Invalid pathloss squares type: ' flag_value]);
                end
                
            case 'width',
%                 flag_value
                if (flag_value < 0)
                    error('Pathoss squares width must be >= 0.');
                end
                
            case 'p'
                if (flag_value < 0)
                    error(['Invalid pathloss squares p: ' num2str(flag_value)]);
                end

        end
        
    case 'hex',
        switch(flag_type)
            case 'type'
                switch(flag_value)
                    case {'wifi', 'cellular'},   % do nothing
                    otherwise,
                        error(['Invalid HEX type: ' flag_value ...
                            '. Valid options are: wifi, cellular']);
                end
        end
        
        
    otherwise,
        error(['Invalid file type: ' file_type]);
        
        
end