function [chan_data idcs] = get_tower_data(tower_data_year)
%   [tower_data idcs] = get_tower_data(tower_data_year)
%
%   Loads tower data for the specified tower data year. The region is
%   specified via the region code in Helpers/get_simulation_value.m.
%
%   See also: get_simulation_value

switch(get_simulation_value('region_code'))
    case 'US',
        switch(tower_data_year)
            case '2011',
                load([get_simulation_value('data_dir') '/chan_data2011.mat']);
                idcs = struct('ad_idx', ad_idx, 'chan_no_idx', chan_no_idx, ...
                    'lat_idx', lat_idx, 'long_idx', long_idx, ...
                    'haat_idx', haat_idx, 'erp_idx', erp_idx, ...
                    'fcc_rp_idx', fcc_rp_idx, 'dist_th_idx', dist_th_idx);
            case '2011greedyrepack',
                load([get_simulation_value('data_dir') '/chan_data2011greedyrepack.mat']);
            case '2011greedyrepackbands',
                load([get_simulation_value('data_dir') '/chan_data2011greedyrepackbands.mat']);
            otherwise,
                error(['Unknown tower data year: ''' tower_data_year ...
                    '''; valid options: ' ...
                    cellstr2str(get_simulation_value('valid_tower_data_years')) ...
                    ' (if the year you specified is listed, then it is simply ' ...
                    'not yet supported in load_chan_data()).']);
        end
        
    case 'AUS',
        error(['Sorry, tower data is not yet available for Australia in ' ...
            'this version of the code.']);
        
    otherwise,
        error(['Unknown region code ''' get_simulation_value('region_code') ...
            '''; please check get_simulation_value.m']);
end

end