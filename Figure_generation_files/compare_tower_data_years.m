function [] = compare_tower_data_years(year1, year2)
%   [] = compare_tower_data_years(year1, year2)
%
%   This function aids in the comparison of two different sets of tower
%   data, as referenced by their years.

chan_list = get_simulation_value('chan_list');

figure;
for channel = chan_list
    clf;    % clear the figure
    map_of_towers_by_channel(channel, year1, 'b');  % plot year1
    map_of_towers_by_channel(channel, year2, 'r');  % plot year2
    title(['(channel ' num2str(channel) ') blue = ' year1 ', red = ' year2 ...
        ', magenta = both']);   % add a title
    pause;  % wait for the user
end