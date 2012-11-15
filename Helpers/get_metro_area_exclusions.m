function [excl_mask] = get_metro_area_exclusions(map_size, varargin)
%   [excl_maps] = get_metro_area_exclusions(map_size, [*])
%
%   Returns a set of maps (one per channel) with
%       0 = CR cannot transmit under metropolitan rules
%       1 = otherwise (not excluded based on metro. rules)
%
%   Note: values outside the US are set to 0.
%
%   map_size = resolution for resulting data
%       Accepted values: '200x300', '201x301', '400x600'
%   * is an optional second argument; if it exists at all, the original
%       information for the metropolitan areas will be displayed.
%
% We can find the coordinates of the major metropolitan regions at
%   http://ecfr.gpoaccess.gov/cgi/t/text/text-idx?c=ecfr&sid=f2938faee302d197d532716bbd4af432&rgn=div5&view=text&node=47:5.0.1.1.3&idno=47#47:5.0.1.1.3.11.111.2
% Which is linked from a post on 7/20/2011 on
%   http://www.fcc.gov/encyclopedia/white-space-database-administration-q-page

if ~isempty(varargin)
    display(' ------- FORMAT ------- ');
    display('METROPOLITAN AREA NAME');
    display('   Lat:  LATITUDE in decimal degrees (LATITUDE in deg, min, sec)');
    display('   Long: LONGITUDE in decimal degrees (LONGITUDE in deg, min, sec)');
    display('   Channels: CHANNELS prohibited');
    display(' ----- END FORMAT ----- ');
    display(' ');
end


cochannel_dist = 134;
adj_channel_dist = 131;

metros(01) = make_metro('Boston, MA', [42, 21,24.4], [71,03,23.2], [14 16]);
metros(02) = make_metro('Chicago, IL', [41,52,28.1], [87,38,22.2], [14 15]);
metros(03) = make_metro('Cleveland, OH', [41,29,51.2], [81,49,49.5], [14 15]);
metros(04) = make_metro('Dallas/Fort Worth, TX', [32,47,9.5], [96,47,38.0], [16]);
metros(05) = make_metro('Detroit, MI', [42,19,48.1], [83,02,56.7], [15,16]);
metros(06) = make_metro('Houston, TX', [29,45,26.8], [95,21,37.8], [17]);
metros(07) = make_metro('Los Angeles, CA', [34,03,15.0], [118,14,31.3], [14,16,20]);
metros(08) = make_metro('Miami, FL', [25,46,38.4], [80,11,31.2], [14]);
metros(09) = make_metro('New York, NY/NE NJ', [40,45,6.4], [73,59,37.5], [14,15,16]);
metros(10) = make_metro('Philadelphia, PA', [39,56,58.4], [75,9,19.6], [19,20]);
metros(11) = make_metro('Pittsburgh, PA', [40,26,19.2], [79,59,59.2], [14,18]);
metros(12) = make_metro('San Francisco/Oakland, CA', [37,46,38.7], [122,24,43.9], [16,17]);
metros(13) = make_metro('Washington, DC/MD/VA', [38,53,51.4], [77,0,31.9], [17,18]);



chan_list = get_simulation_value('chan_list');

excl_mask = get_us_map(map_size, length(chan_list));
[is_in_us lat_coords long_coords] = get_us_map(map_size);

[longs_map lats_map] = meshgrid(long_coords, lat_coords);
longs_vec = longs_map(:);
lats_vec = lats_map(:);

% is_in_us_vec = is_in_us(:);


% For each metropolitan area
for i = 1:length(metros)
    if ~isempty(varargin)
        display_metro(metros(i));
    end
    
    distances = latlong_to_km(metros(i).lat, metros(i).long, lats_vec, longs_vec);
    cochannel_points = (distances > cochannel_dist);
    adj_channel_points = (distances > adj_channel_dist);
    
    cochannel_mask = reshape(cochannel_points, size(is_in_us));
    adj_channel_mask = reshape(adj_channel_points, size(is_in_us));

    % For each channel that's reserved in the metropolitan area
    for j = 1:length(metros(i).channels)
        % Apply cochannel exclusions
        coch_idx = get_channel_index(metros(i).channels(j));
        excl_mask(coch_idx, :, :) = squeeze(excl_mask(coch_idx, :, :)) & cochannel_mask;
        
        % Apply adjacent channel exclusions
        if (has_frequency_neighbor(coch_idx, 'up'))
            adj_idx = coch_idx + 1;
            excl_mask(adj_idx, :, :) = squeeze(excl_mask(adj_idx, :, :)) & adj_channel_mask;
        end
        
        if (has_frequency_neighbor(coch_idx, 'down'))
            adj_idx = coch_idx - 1;
            excl_mask(adj_idx, :, :) = squeeze(excl_mask(adj_idx, :, :)) & adj_channel_mask;
        end

    end
end




end









function [metro] = make_metro(name, lat, long, channels)

metro.name = name;

metro.lat = lat(1) + lat(2)/60 + lat(3)/3600;
metro.lat_orig = lat;

metro.long = -(long(1) + long(2)/60 + long(3)/3600);
metro.long_orig = long;



metro.channels = channels;

end



function [] = display_metro(metro)

display(metro.name);
display(['   Lat:  ' num2str(metro.lat) '       (' num2str(metro.lat_orig) ')']);
display(['   Long: ' num2str(metro.long) '       (' num2str(metro.long_orig) ')']);
display(['   Channels: ' num2str(metro.channels)]);

end