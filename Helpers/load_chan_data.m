function [chan_data idcs] = load_chan_data(tower_data_year)
%   [chan_data idcs] = load_chan_data(tower_data_year)
%
%   Loads tower data for the specified tower data year. The region is
%   specified via the region code in Helpers/get_simulation_value.m.
%
%   See also: get_simulation_value, get_tower_data

warning(['This function has been renamed: use get_tower_data() ' ...
         'instead (same function signature).']);

[chan_data idcs] = get_tower_data(tower_data_year);

end