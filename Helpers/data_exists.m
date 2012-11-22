function [ result ] = data_exists(label)
%   [ result ] = data_exists(label)
%
%   Returns 'true' if the data exists and 'false' otherwise.

filename = generate_filename(label);
result = (exist([filename '.mat'], 'file') == 2);

end