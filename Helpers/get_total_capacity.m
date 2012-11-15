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

capacity = load_by_label(capacity_label);
if (ischar(exclusions_label) && strcmp(exclusions_label, 'none'))
    exclusion_mask = ones(size(capacity));
else
    if (nargin >= 3 && varargin{1})
        [~, extras] = load_by_label(exclusions_label);
        exclusion_mask = extras.mask_pre_mic_channels;
    else
        exclusion_mask = load_by_label(exclusions_label);
    end
end
total_capacity = aggregate_bands(capacity.*exclusion_mask);

is_in_us = get_us_map(capacity_label.noise_label.map_size, 1);
total_capacity(~is_in_us) = inf;

return;