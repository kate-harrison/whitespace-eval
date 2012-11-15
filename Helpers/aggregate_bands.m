function [ total ] = aggregate_bands( capacity )
%AGGREGATE_BANDS Adds up the capacities in 'capacity' for the four usual
%cases.
%
%   [ total ] = aggregate_bands( capacity )
%
%   capacity - matrix containing channel capacities (should be
%   length(chan_list)x*x* and the first dimension should be ordered
%   according to chan_list) (chan_list = get_simulation_value('chan_list'))
%
%   Returns the sum of all layers. Totals do not include channels 3 and 4.



% We will consistently exclude these.
ch3 = get_channel_index(3);
ch4 = get_channel_index(4);

idx = remove_from_array([ch3 ch4], 1:size(capacity,1));

capacity = capacity(idx, :, :);
total = squeeze(sum(capacity, 1));

end





function [return_array] = remove_from_array(val, array)
%   [return_array] = remove_from_array(val, array)

for i = 1:length(val)
    value = val(i);
    array = array(array ~= value);
end

return_array = array;

end