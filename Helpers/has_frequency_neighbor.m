function [ result ] = has_frequency_neighbor(self_idx, type)
%   [ result ] = has_frequency_neighbor(self_idx, type)
%
%   type = up, down
%   self_idx = index of this channel in chan_list
%
%   1 = true/yes, 0 = false/no


% file = load('chan_list.mat');
% chan_list = file.chan_list;
chan_list = get_simulation_value('chan_list');

switch(type)
    case 'up',
        result = (self_idx < length(chan_list)) && ...
            (abs(get_freq(chan_list(self_idx+1)) - get_freq(chan_list(self_idx))) == 6);
    case 'down',
        result = (self_idx > 1) && ...
            (abs(get_freq(chan_list(self_idx-1)) - get_freq(chan_list(self_idx))) == 6);
    otherwise,
        error(['Wrong neighbor type: ' type]);
end

end