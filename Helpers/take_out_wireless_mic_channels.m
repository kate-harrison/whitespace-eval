function [mask wireless_mic_channels] = take_out_wireless_mic_channels(mask)
%   [mask wireless_mic_channels] = take_out_wireless_mic_channels(mask)
%
%   Removes up to two channels for wireless microphone exclusions as
%   described in the 2010 FCC rules:
%
%   The rules state to take out the first available channel below channel
%   37 (between 2 and 36) and the first available channel above channel 37
%   (between 38 and 51). If there is no channel available to remove in one
%   range, then we take two from the other range.
%
%
%   mask (input) = mask indicating availability of channels to cognitive
%       radios (1 = available; 0 = not available)
%
%   mask (output) = new mask with up to two more channels marked as
%       unavailable
%   wireless_mic_channels = mask indicating which channels were taken at
%       each location (1 = removed due to wireless mic. exclusions)

lower_idx = get_channel_index(36);
higher_idx = get_channel_index(38);

% Make sure that channels 3 and 4 are zero since they are never available
% to cognitive radios
mask([get_channel_index(3), get_channel_index(4)], :, :) = 0;


map_size = determine_map_size(size(mask));
[is_in_us lat_coords long_coords] = get_us_map(map_size);


% A 1 in this matrix indicates that that channel was lost at that location
% to wireless microphone exclusions
wireless_mic_channels = zeros(size(mask));

for i = 1:length(lat_coords)
    for j = 1:length(long_coords)
        if (~is_in_us(i,j))
            continue;
        end
        
        list = mask(:, i, j);
        
        % Search for a channel in [2, 36] to remove; if none found, look
        % for two channels in the upper range and otherwise only look for
        % one.
        l = find(list(1:lower_idx) == 1, 1, 'last');
        if (isempty(l))
            n = 2;
        else
            n = 1;
        end
        
        % Search for a channel in [38, 51] to remove; if no channels were
        % available for removal in either range, do nothing; if no channels
        % are available in this range, try again to take from the lower
        % range (but this time take two channels if possible).
        h = find(list(higher_idx:end) == 1, n, 'first') + lower_idx;
        if (isempty(h) && isempty(l))
%             display('Cannot take away more channels');
        else if (isempty(h))
                l = find(list(1:lower_idx) == 1, 2, 'last');
            end
        end
        
        % Set the channels as unavailable
        mask([l h], i, j) = 0;
        
        % Mark which channels were removed
        wireless_mic_channels([l h], i, j) = 1;

    end
end

end