function [ result ] = data_exists(label)
%   [ result ] = exists(label)

filename = generate_filename(label);
result = (exist([filename '.mat'], 'file') == 2);

end