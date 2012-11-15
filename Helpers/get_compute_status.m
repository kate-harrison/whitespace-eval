function [ result ] = get_compute_status(input)
% function [ result ] = get_compute_status(input)
%
%   Input is either a label or a filename (complete with .mat extension).

result = 1;

is_struct = (isstruct(input));

if (is_struct)
    filename = generate_filename(input);
else
    filename = input;
end


% Check to see if we need to (re)compute
if (is_struct && data_exists(input)) || (~is_struct && (exist([input], 'file') == 2))  % Exists
    if (get_simulation_value('recompute'))  % Recompute
        action = 'recomputing';
    else
                                            % Skip
        display(['__Skipping__ ' filename]);
        result = 0;
    end
    
else                                % Doesn't exist yet
    action = 'computing';

end

if (result == 1)
    display(['Working on... (' action ') ' filename]);
end


end