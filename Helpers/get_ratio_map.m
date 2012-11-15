function [ratio_map] = get_ratio_map(label)
%   [ratio_map] = get_ratio_map(label)
%
%   Returns the ratio map for a jam model. Ratio maps compare the "new
%   rate" with the "dream rate" in the following way:
%
%       ratio = (new rate) / (dream rate)
%
%   The input should be the label for the new rate (typically with
%   power_type = 'new_power' or 'flat3').

map_size = label.noise_label.map_size;
is_in_us = get_us_map(map_size);


for i = 1:2
    temp_label = label;
    switch(i)
        case 1, power_type = label.power_type; %    'new_power'; -- don't change, this way it can be new_power or flat
        case 2, power_type = 'old_dream';
            if (label.hybrid)
                temp_label.p = label.p2;
                temp_label.hybrid = false;
            end
    end
    temp_label.power_type = power_type;
    
    [fair_rate_map] = load_by_label(temp_label);
    
%     filename = generate_filename(temp_label);
    
%     display(['Loading ' filename]);
%     load(filename, 'fair_rate_map');
    
    
    switch(i)
        case 1, new_rate = fair_rate_map;
        case 2, old_rate = fair_rate_map;
    end
end

ratio_map = aggregate_bands( new_rate ) ./ aggregate_bands( old_rate );
ratio_map(~is_in_us) = inf;


end