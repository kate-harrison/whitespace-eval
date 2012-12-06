function [mask] = remove_unused_channels(mask, mode)
%   [mask] = remove_unused_channels(mask, mode)
%
%   Remove unused channels based on the region (e.g. these are channels 3
%   and 4 in the USA).
%
%   mask = the 3-dimensional array to operate on
%   mode = {'zero', 'remove'}: zero out vs. remove the layers of the mask


if ndims(mask) ~= 3
    error(['First input argument must be 3-dimensional.']);
end

channels = get_simulation_value('unused_channels');
idcs = [];
for ch_idx = 1:length(channels)
    idcs(ch_idx) = get_channel_index(channels(ch_idx));
end
% idcs = get_channel_index(channels)

switch(mode)
    case 'zero',
        mask(idcs,:,:) = 0;
    case 'remove',
        mask(idcs,:,:) = [];
    otherwise,
        error(['Unused remove mode: ' mode '; acceptable modes: zero, remove']);
end