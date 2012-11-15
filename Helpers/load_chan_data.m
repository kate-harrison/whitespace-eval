function [chan_data idcs] = load_chan_data(tower_data_year)
%   [chan_data idcs] = load_chan_data(tower_data_year)
%
%   Loads channel data for the specified tower data year.
%
%   See also: get_simulation_value


switch(tower_data_year)
    case '2011',
        load('Population_and_tower_data/Tower/2011/chan_data2011.mat');
        idcs = struct('ad_idx', ad_idx, 'chan_no_idx', chan_no_idx, ...
            'lat_idx', lat_idx, 'long_idx', long_idx, ...
            'haat_idx', haat_idx, 'erp_idx', erp_idx, ...
            'fcc_rp_idx', fcc_rp_idx);
        
    otherwise,
        error(['Unknown tower data year: ''' tower_data_year '''; valid options: ' ...
            cellstr2str(get_simulation_value('valid_tower_data_years'))]);
        
end

end