function [avg med] = get_fade_margin_stacked_graph_data(capacity_label)

temp_nl = capacity_label.noise_label;
with_noise_label = generate_label('noise', 'yes', temp_nl.map_size, temp_nl.channels, 'both');
without_noise_label = generate_label('noise', 'no', temp_nl.map_size, temp_nl.channels, 'none');

% No noise, no exclusions
temp_cap_label = capacity_label;
temp_cap_label.noise_label = without_noise_label;
temp_ccdf_label = generate_label('ccdf_points', 'fade_margin', 'none', temp_cap_label);
[avg.no_noise_no_excl med.no_noise_no_excl] = load_by_label(temp_ccdf_label);

% Yes noise, no exclusions
temp_cap_label = capacity_label;
temp_cap_label.noise_label = with_noise_label;
temp_ccdf_label = generate_label('ccdf_points', 'fade_margin', 'none', temp_cap_label);
[avg.yes_noise_no_excl med.yes_noise_no_excl] = load_by_label(temp_ccdf_label);

% Yes noise, coch. exclusions
temp_cap_label = capacity_label;
temp_cap_label.noise_label = with_noise_label;
temp_ccdf_label = generate_label('ccdf_points', 'fade_margin', 'fm-cochan', temp_cap_label);
[avg.yes_noise_coch_excl med.yes_noise_coch_excl] = load_by_label(temp_ccdf_label);

% Yes noise, all exclusions
temp_cap_label = capacity_label;
temp_cap_label.noise_label = with_noise_label;
temp_ccdf_label = generate_label('ccdf_points', 'fade_margin', 'fade_margin', temp_cap_label);
[avg.yes_noise_all_excl med.yes_noise_all_excl] = load_by_label(temp_ccdf_label);


end