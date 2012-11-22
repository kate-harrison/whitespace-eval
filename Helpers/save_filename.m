function [save_as_filename] = save_filename(label)
%   [save_as_filename] = save_filename(label)

filename = generate_filename(label);
dir = upper(label.label_type);
save_as_filename = [get_simulation_value('data_dir') '/' dir '/' filename '.mat'];

end