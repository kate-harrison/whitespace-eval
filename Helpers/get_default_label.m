function [label] = get_default_label(label_type)
%   [label] = get_default_label(label_type)
%
%   This function provides a default label when one is needed, e.g. for
%   quick prototyping. Do *NOT* depend on its output in final code. To
%   prevent unfortunate mistakes, this warning also occurs at run-time.


warning('Return values subject to change at any time: use this function for prototyping only.');

population_type = get_simulation_value('pop_data_type');
tower_data_year = get_simulation_value('tower_data_year');
map_size = get_simulation_value('map_size');

switch(lower(label_type))
    case 'capacity',
        label = generate_label('capacity', 'per_person', 'r', 1, population_type, ...
            get_default_label('char'), get_default_label('noise'), ...
            get_default_label('mac_table'));
    case 'ccdf_points',
        label = generate_label('ccdf_points', 'tv_removal-1', 'fcc', ...
            get_default_label('capacity'));
    case 'char',
        label = generate_label('char', 30, 4);
    case 'fcc_mask',
        label = generate_label('fcc_mask', ['cr-' tower_data_year], map_size);
    case 'fm_mask',
        label = generate_label('fm_mask', ['cr-' tower_data_year], ...
            map_size, 3, get_default_label('char'));
    case 'jam',
        label = generate_label('jam', 'rate_map', 3, 'new_power', ...
            population_type, tower_data_year, get_default_label('char'), ...
            0.5, 2000, get_default_label('noise'));
    case 'hex',
        label = generate_label('hex', 'cellular', get_default_label('char'));
    case 'mac_table',
        label = generate_label('mac_table', ['tv-' tower_data_year], ...
            get_default_label('char'));
    case 'noise',
        label = generate_label('noise', 'yes', map_size, ...
            ['tv-' tower_data_year], 'both');
    case 'pl_squares',
        label = generate_label('pl_squares', 'local', 0, 2000, ...
            population_type, map_size, get_default_label('char'));
    otherwise,
        error(['Unrecognized label type: ' label_type ...
            '; acceptable label types: ' get_simulation_value('labels')]);
end

end
