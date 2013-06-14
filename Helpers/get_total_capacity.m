function [total_capacity] = get_total_capacity(capacity_label, exclusions_label, varargin)
%   [total_capacity] = get_total_capacity(capacity_label, exclusions_label, 
%                           [do_not_include_wireles_mic_exclusions])
%
%
%   Locations outside the US are set to infinity for plotting purposes.
%
%   exclusions_label = 'none' applies no exclusions
%
%   do_not_include_wireles_mic_exclusions (optional) - if this argument
%       evaluates to true, wireless mic exclusions will be ignored; default
%       is to use wireless mic exclusions
%
%   See also: load_by_label, aggregate_bands, get_us_map

capacity = load_by_label(capacity_label);
if (ischar(exclusions_label) && strcmp(exclusions_label, 'none'))
    exclusion_mask = ones(size(capacity));
else    
    if (nargin >= 3)    % user specified
        does_not_include_wireless_mic_exclusions = logical(varargin{1});
    else    % default
        does_not_include_wireless_mic_exclusions = true
    end
    
    still_need_to_take_out_mic_channels = false;

    switch(exclusions_label.label_type)
        case 'fcc_mask',
            temp_exclusions_label = generate_label('fcc_mask', ...
                exclusions_label.device_type, exclusions_label.map_size, ...
                ~does_not_include_wireless_mic_exclusions);
        case 'fm_mask',
            if ~does_not_include_wireless_mic_exclusions    % does include them
                still_need_to_take_out_mic_channels = true;
            end
            
            temp_exclusions_label = exclusions_label;
        otherwise,
            error(['Mask type not supported: ' exclusions_label.label_type]);
    end
    
    exclusion_mask = load_by_label(temp_exclusions_label);
    
    if still_need_to_take_out_mic_channels
        exclusion_mask = take_out_wireless_mic_channels(exclusion_mask);
    end
end

total_capacity = aggregate_bands(capacity.*exclusion_mask);

is_in_us = get_us_map(capacity_label.noise_label.map_size, 1);
total_capacity(~is_in_us) = inf;

return;