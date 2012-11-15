function [cell_str] = cellstr2str(cell_str_array)
%   [cell_str] = cellstr2str(cell_str_array)
%
%   Example input:      {'a', 'b', 'c'}     (cell array of strings)
%   Example output:     'a, b, c'           (string)


cell_str = [];
for i = 1:length(cell_str_array)
    cell_str = [cell_str ', ' cell2mat(cell_str_array(i))];
end

cell_str(1:2) = [];

end