function [mask] = combine_cochannel_and_adjacent_channel_exclusions(cochannel_mask, adjacent_channel_mask)
%   [mask] = combine_cochannel_and_adjacent_channel_exclusions( ...
%                                   cochannel_mask, adjacent_channel_mask)
%
%   This function combines the individual exclusions given in
%   cochannel_mask and adjacent_channel_mask to produce a combined
%   exclusions mask. The algorithm followed for channel c is roughly:
%
%   0. Initialize: mask = cochannel_mask
%   1. Does channel c have an upper adjacent channel?
%   2. If no, skip to step 4.
%   3. If yes, mask(c,:) = mask(c,:) & adjacent_channel_mask(c+1,:).
%   4. Repeat steps 1-3 for a lower adjacent channel.
%
%   See also: has_frequency_neighbor, make_fcc_mask



% Start with just the cochannel exclusions
mask = cochannel_mask;

% Get the list of channels
chan_list = get_simulation_value('chan_list');

% For each channel, apply the adjacent-channel exclusions
for i = 1:length(chan_list)    
    % Check for and process an upward-adjacent frequency
    if (has_frequency_neighbor(i, 'up'))
        mask(i,:) = mask(i,:) & adjacent_channel_mask(i+1,:);
    end
    
    % Check for and process a downward-adjacent frequency
    if(has_frequency_neighbor(i, 'down'))
        mask(i,:) = mask(i,:) & adjacent_channel_mask(i-1,:);
    end
end

end