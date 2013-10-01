function [] = make_fcc_mask(fcc_mask_label)
%   [] = make_fcc_mask(fcc_mask_label)
%
%   Generates map data to answer the following questions:
%       1) Can a whitespace device (CR) transmit here?
%           The resulting entry mask(c,i,j) is 1 if the CR can transmit on
%           channel c at lat coord i and long coord j and 0 otherwise*.
%
%       2) Can TV be received here?
%           The resulting entry mask(c,i,j) is 1 if TV is received on
%           channel c at lat coord i and long coord j and 0 otherwise.
%
%   Exclusion radii are computed in read_tower_data and separation
%   distances are specified in get_simulation_value.
%
%   See also: read_tower_data, get_tower_data, get_simulation_value, 
%       take_out_wireless_mic_channels, load_by_label,
%       combine_cochannel_and_adjacent_channel_exclusions
%
%   * Wireless microphone exclusions are computed here but are not included
%   in the 'mask' variable. See load_by_label to understand how to extract
%   a mask with wireless microphone exclusions applied from the data at
%   hand.
%
%   Note: this function generates and saves data which answers both
%   questions above. This will not adversely affect the behavior of
%   load_by_label().

switch(fcc_mask_label.label_type)
    case 'fcc_mask',
    otherwise,
        error(['Unsupported mode: tried to run make_fcc_mask() with ' ...
            'label of type ' fcc_mask_label.label_type]);
end

% Read in the parameters
[~, tower_data_year] = split_flag(fcc_mask_label.device_type);
map_size = fcc_mask_label.map_size;

% Data for apply_wireless_mic_exclusions = true is not saved but instead
% generated from the apply_wireless_mic_exclusions = false data at
% load-time. We manually assign this to false here to avoid confusion but
% it will not affect the outcome. To underscore this point, we clear the
% 'fcc_mask_label' variable after the compute-status check to show that it
% is not used elsewhere.
fcc_mask_label.apply_wireless_mic_exclusions = false;

% If we don't need to compute, exit now
if (get_compute_status(fcc_mask_label) == 0)
    return;
end
clear fcc_mask_label;


% Tell the user what is happening
display(['Generating FCC mask data for map size = ' map_size ...
    ', tower data year = ' tower_data_year]);

% Get the list of channels
chan_list = get_simulation_value('chan_list');

% Determine the separation distances
r_co_ext = get_simulation_value('cochannel_separation_distance');    % km
r_adj_ext = get_simulation_value('adjacent_channel_separation_distance');   % km
% Find the max of these values so that we select an appropriately-sized
% subset ("box") later.
max_buffer_size = max([0 r_co_ext r_adj_ext]);

% We use a structure to hold some commonly-used variables. The structure is
% to reduce the number of input arguments required for each function. Note
% that although this large (in bytes) structure is passed into several
% functions on each iteration, it is not actually copied due to Matlab's
% "lazy copying"/"copy on write" convention (it is never modified in those
% functions). See
% http://blogs.mathworks.com/loren/2006/05/10/memory-management-for-functions-and-variables/
% for more details.
[default_mask, world.lat_coords, world.long_coords] = ...
    get_us_map(map_size, length(chan_list));
[world.LONGS world.LATS] = meshgrid(world.long_coords, world.lat_coords);

% Load the tower data
[chan_data struct] = get_tower_data(tower_data_year);
struct_to_vars; % "deal" the fieldnames of 'struct' to local variables

% Create "blank" arrays, one layer for each channel
tv_user_mask = false(size(default_mask));
cochannel_mask = default_mask;
adjacent_channel_mask = default_mask;

% Update the masks above (tv_user_mask, cochannel_mask,
% adjacent_channel_mask) with the data from each tower.
for t = 1:size(chan_data,1)
    % Select the tower and get info about it
    tower_data = chan_data(t,:);
    
    if tower_data(chan_no_idx) > 51
        continue;
    end
    
    channel_idx = get_channel_index(tower_data(chan_no_idx));
    t_lat = tower_data(lat_idx);
    t_long = tower_data(long_idx);
    t_radius = tower_data(fcc_rp_idx);
    
    % Operate on only a portion of the map. Use this function to get binary
    % arrays describing which lat and long coords contain the circle of
    % radius (t_radius+max_buffer_size) centered at (t_lat, t_long).
    [sub_lat_idcs sub_long_idcs box_empty] = ...
        select_box(world, t_lat, t_long, t_radius+max_buffer_size);
    
    % If there are no pixels within (t_radius+max_buffer_size) of the point
    % (t_lat, t_long), then this tower will not affect the outcome so we
    % can skip it.
    if box_empty
        continue;
    end
    
    % Find the distances of the coordinates within the box to the tower at
    % (t_lat, t_long).
    sub_distances = get_distances_in_box(world, t_lat, t_long, ...
        sub_lat_idcs, sub_long_idcs);
    
    % Update the TV user mask
    in_mat = sub_distances <= t_radius;
    in_mat = reshape(in_mat, [1 size(in_mat)]);
    tv_user_mask(channel_idx, sub_lat_idcs, sub_long_idcs) = ...
        tv_user_mask(channel_idx, sub_lat_idcs, sub_long_idcs) ...
        | in_mat;
  
    % Update the FCC cochannel mask
    in_mat = sub_distances <= (t_radius + r_co_ext);
    in_mat = reshape(in_mat, [1 size(in_mat)]);
    cochannel_mask(channel_idx, sub_lat_idcs, sub_long_idcs) = ...
        cochannel_mask(channel_idx, sub_lat_idcs, sub_long_idcs) ...
        & ~in_mat;
    
    % Update the FCC adjacent channel mask
    in_mat = sub_distances <= (t_radius + r_adj_ext);
    in_mat = reshape(in_mat, [1 size(in_mat)]);
    adjacent_channel_mask(channel_idx, sub_lat_idcs, sub_long_idcs) = ...
        adjacent_channel_mask(channel_idx, sub_lat_idcs, sub_long_idcs) ...
        & ~in_mat;
end


% Use each of the masks computed above to determine the output for each
% type of label. Note that one run through the file generates TV-user data
% as well as the FCC mask without wireless microphone exclusions. If
% desired, wireless microphone exclusions will be applied when the data is
% loaded.
for dt = {'tv', 'cr'}
    device_type = dt{1};
    new_device_type = combine_flag(device_type, tower_data_year);
    temp_fcc_mask_label = generate_label('fcc_mask', ...
        new_device_type, map_size, false);
    clear mask extras
    switch(device_type)
        case 'cr',            
            mask = combine_cochannel_and_adjacent_channel_exclusions(...
                cochannel_mask, adjacent_channel_mask);
            extras.cochannel_mask = cochannel_mask;
            extras.adjacent_channel_mask = adjacent_channel_mask;
            
            [extras.mic_removed.cochannel_mask, extras.mic_removed.wireless_mic_channels] = ...
                take_out_wireless_mic_channels(cochannel_mask);
            extras.mic_removed.mask = ...
                combine_cochannel_and_adjacent_channel_exclusions(...
                extras.mic_removed.cochannel_mask, adjacent_channel_mask);
            
        case 'tv',
            mask = tv_user_mask & default_mask; % zero outside the US
            extras.contents = 'none';
            
    end
    
    filename = save_filename(temp_fcc_mask_label);
    display(['    Saving data for ' filename]);
    % Note: saving as .mat version 7.3 is necessary when data is larger
    % than 2GB (e.g. for 3200x4800 maps).
    save_data(filename, 'mask', 'extras', '-v7.3');
    add_extended_info_to_file(filename, 'get_tower_data', ...
        'combine_cochannel_and_adjacent_channel_exclusions');

end


end


function [sub_lat_idcs sub_long_idcs box_empty] = select_box(world, center_lat, center_long, radius)
    [lats longs] = km_to_latlong(center_lat, center_long, radius, 0:90:270);
    sub_lat_idcs = (world.lat_coords <= max(lats)) & (world.lat_coords >= min(lats));
    sub_long_idcs = (world.long_coords <= max(longs)) & (world.long_coords >= min(longs));
    box_empty = ~any(sub_lat_idcs) || ~any(sub_long_idcs);
end


function [distances] = get_distances_in_box(world, from_lat, from_long, sub_lat_idcs, sub_long_idcs)
if ~any(sub_lat_idcs) || ~any(sub_long_idcs)
    distances = [];
    return;
end

sub_lats = world.LATS(sub_lat_idcs, sub_long_idcs);
sub_longs = world.LONGS(sub_lat_idcs, sub_long_idcs);

distances = latlong_to_km(from_lat, from_long, sub_lats, sub_longs);
end