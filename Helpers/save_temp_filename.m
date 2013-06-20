function [save_as_filename] = save_temp_filename(label, extra_text)
%   [save_as_filename] = save_temp_filename(label, extra_text)
%
%   Generates the a standard temp filename (including path) to use for
%   saving data. The file will be stored in the temp directory (as given by
%   get_simulation_value('temp_dir')) and the "extra text" will be appended
%   to the label's standard name.
%
%   For saving permanent files, save_filename() should be used instead.
%
%   See also: save_filename, generate_filename, get_simulation_value

filename = generate_filename(label);
save_as_filename = [get_simulation_value('temp_dir') '/' filename ...
    ' ' extra_text '.mat'];

end