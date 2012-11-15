function [ index ] = get_channel_index( channel_number )
%GET_CHANNEL_INDEX Gets the index for channel_number from the array
%chan_list. Returns 0 if the channel is not in the list.
%
%   [ index ] = get_channel_index( channel_number )
%
%   channel_number = Desired channel number
%
%   index = Its index in chan_list

% load 'chan_list.mat'
chan_list = get_simulation_value('chan_list');
index = find(chan_list == channel_number);

if isempty(index)
    index = 0;
    warning('Channel number not found');
end


end

