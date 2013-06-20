function [save_as_filename] = save_filename(label)
%   [save_as_filename] = save_filename(label)
%
%   Generates the a standard filename (including path) to use for saving
%   data.
%
%   The file will be stored in the data directory (as given by
%   get_simulation_value('data_dir')) inside a folder matching the label's
%   type (e.g. 'FCC_MASK').
%
%   For saving temporary files, save_temp_filename() should be used instead.
%
%   See also: save_temp_filename, generate_filename, get_simulation_value


filename = generate_filename(label);
dir = upper(label.label_type);
save_as_filename = [get_simulation_value('data_dir') '/' dir '/' filename '.mat'];

end