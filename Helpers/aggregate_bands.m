function [total] = aggregate_bands(capacity)
%   [total] = aggregate_bands(capacity)
%
%   capacity - matrix containing channel capacities (should be
%   length(chan_list)x*x* and the first dimension should be ordered
%   according to chan_list) (chan_list = get_simulation_value('chan_list'))
%
%   Returns the sum of all layers. Totals do not include unused channels,
%   defined in get_simulation_value:
%       get_simulation_value('unused_channels')
%   (e.g., in the US these are channels 3 and 4).
%
%   See also: get_simulation_value.m

capacity = remove_unused_channels(capacity, 'zero');
total = squeeze(sum(capacity, 1));

end

