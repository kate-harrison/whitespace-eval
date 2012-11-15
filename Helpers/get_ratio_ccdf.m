function [cdfX cdfY avg med] = get_ratio_ccdf(label, type)
%   [cdfX cdfY avg med] = get_ratio_ccdf(label, type)
%
%   Calculates the CCDF by person (or area) of a ratio map. Ratio maps are
%   explained in get_ratio_map.m.
%
%   See also: get_ratio_map.m

map_size = label.noise_label.map_size;
is_in_us = get_us_map(map_size);


ratio_map = get_ratio_map(label);

switch(type)
    case 'population',
        weight_map = get_population(map_size, 'real', 1);
    case 'area',
        weight_map = get_us_area(map_size);
    otherwise,
        error('Unknown parameter value');
end


[cdfX cdfY avg med] = calculate_cdf_from_map(ratio_map, weight_map, is_in_us);

end