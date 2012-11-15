function [ cap_per_area, capacity, radius ] = get_best_exclusion_radius( chan_no, tx_dist_to_rx, tx_power, tx_haat, ambient_noise, radii, noise_list )
% GET_BEST_EXCLUSION_RADIUS Finds the optimal MAC exclusion radius for a secondary
%   transmitter using a lookup table of precomputed values (radii, noise_list)
%
%   [ cap_per_area, capacity, radius ] = get_best_exclusion_radius( chan_no,
%   tx_dist_to_rx, tx_power, tx_haat, ambient_noise, radii, noise_list )
%
%   chan_no = channel number for all transmitters
%   tx_dist_to_rx = distance from this receiver to the transmitter whose
%       signal it wishes to receive in km (can be either a scalar or a
%       column vector whose dimensions match those of ambient_noise)
%   tx_power = secondary transmitter power (assumed the same on all secondary
%       transmitters) in Watts
%   tx_haat = secondary transmitter HAAT (height above average terrain)
%       (assumed the same on all secondary transmitters) in meters
%   ambient_noise = thermal noise, primary transmitter power in Watts
%   (should be a column vector)
%   radii = the radii corresponding to the noise levels in noise_list
%   noise_list = total noise contribution from all secondaries in the model
%       at each radius in radii (should be a column vector)
%
%   Returns
%       capacity per area (in bps/km^2)
%       actual capacity (in bps) achieved with the corresponding exclusion
%           radius
%       radius (in km) inside of which all other secondary
%           transmitters must be quiet if this secondary receiver is to
%           achieve this target channel capacity.
%
%
%
%   NOTE: Does not allow an exclusion radius greater than the distance from
%   the user to its tower.


B = get_simulation_value('bandwidth');
tx_power_after_pl = apply_path_loss(tx_power, chan_no, tx_haat, tx_dist_to_rx);

% Create a mesh that is each combination of addition of elements of
% ambient_noise and noise_list
% Each column is a new entry from ambient noise
% Each row is a new entry from noise list

new_ambient_noise = repmat(ambient_noise', length(noise_list), 1);

new_noise_list = repmat(noise_list, 1, length(ambient_noise));

% Don't allow MAC radii which are smaller than the distance to the tower
new_radii_array = repmat(radii', 1, length(ambient_noise));
new_dist_array = repmat(tx_dist_to_rx, length(radii), 1);
new_noise_list(new_radii_array < new_dist_array) = inf;

total_noise = new_ambient_noise + new_noise_list;

if (length(tx_dist_to_rx) == size(total_noise, 2))
    rep_factor = 1;
else
    rep_factor = size(total_noise, 2);
end

new_tx_power_after_pl = repmat(tx_power_after_pl', length(noise_list), rep_factor);


capacity = B .* log2(1 + new_tx_power_after_pl./(total_noise));

% Scale each entry by the radius corresponding to that entry in
% noise_list to get cap/area for that entry
capacity_per_area = repmat(1./(pi*radii.^2), length(ambient_noise), 1)' .* capacity;

[C, I] = max(capacity_per_area, [], 1);    % Maximize each column (= over each entry in noise_list)

% I gives the index of each column but does not offset properly
% Example: if it gives [5 2 8 9] it means the 5th entry of column 1, the
% 2nd entry of column 2, etc. However, if we feed this into 'capacity',
% we'll get these entries from only the first column. To fix this, we do
% the following:
I2 = I + [0:length(tx_dist_to_rx)-1] * length(noise_list);

cap_per_area = C;
capacity = capacity(I2);
radius = radii(I);


end

