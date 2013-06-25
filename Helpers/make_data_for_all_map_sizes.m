function [] = make_data_for_all_map_sizes(label)
%   [] = make_data_for_all_map_sizes(label)
%
%   Make the data for all map sizes (as specified by
%   get_simulation_value('valid_map_sizes')) for the given label.

if ~isfield(label, 'map_size')
    error('Map size does not appear to matter for this label.');
end

map_sizes = get_simulation_value('valid_map_sizes');

for ms = 1:length(map_sizes)
    label.map_size = map_sizes{ms};
    try
        validate_label(label);
        make_data(label);
    catch err
        disp(err);
    end
end


end