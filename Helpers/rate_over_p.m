function [avg_per_tower med_per_tower perc_data p_array] = rate_over_p(jam_label, percentiles)



population = get_population('200x300', 'real', 1);
is_in_us = get_us_map('200x300', 1);

p_array = [125 250 500 1000 2000 4000 8000];

avg_per_tower = zeros(size(p_array));
med_per_tower = zeros(size(p_array));
perc_data = zeros([length(percentiles) length(p_array)]);

for i = 1:length(p_array)
    
    temp_label = jam_label;
    if (~jam_label.hybrid)
        temp_label.p = p_array(i);
    else if (jam_label.p1 == p_array(i))
            temp_label.hybrid = false;
            temp_label.p = p_array(i);
        else
            temp_label.p_string = [num2str(jam_label.p1) ',' num2str(p_array(i))];
        end
    end
    
    filename = generate_filename(temp_label);
    file = load(filename);
    map = file.fair_rate_map;
    map = squeeze(sum(map,1));
    
    
    [cdfX cdfY avg_per_tower(i) med_per_tower(i)] = calculate_cdf_from_map(map, population, is_in_us);
    %             [cdfX cdfY avg_per_person(i) med] = calculate_cdf_from_map(map/p, population, is_in_us);
    
    for j = 1:length(percentiles)
        perc_data(j,i) = get_percentile_from_ccdf(cdfX, cdfY, percentiles(j));
    end
    
end



% avg_per_person = avg_per_tower ./ p_array;



end