function [save_as_filename] = save_filename(label)
%   [save_as_filename] = save_filename(label)

filename = generate_filename(label);
dir = upper(label.label_type);
save_as_filename = ['Data/' dir '/' filename '.mat'];

end