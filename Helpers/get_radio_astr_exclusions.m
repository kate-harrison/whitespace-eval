function [excl_mask] = get_radio_astr_exclusions(map_size, varargin)
%   [excl_maps] = get_radio_astr_exclusions(map_size, [plot], 
%                                           [display_text], [separation_dist])
%
%   Returns a set of maps (one per channel) with
%       0 = CR cannot transmit under radio astronomy rules
%       1 = otherwise (not excluded based on radio astr. rules)
%
%   Note: values outside the US are set to 0.
%
%   map_size: resolution for resulting data
%       Accepted values: '200x300', '201x301', '400x600'
%   plot (optional): if it evaluates to true, plot the sites on a map
%   display_text (optional): if it evaluates to true, the original
%       information for the radio astronomy areas will be displayed.
%   separation_dist (optional): specify a non-standard separation distance
%
% The original list can be found in the 2010 FCC rules. Updates are as
% follows:
%
% Updates from
%   http://transition.fcc.gov/bureaus/oet/whitespace/TVWS_Workshop3/TVWS_Workshop_3_Presentations_5-26-11_v11.pdf
%       Concern: The NRAO and VLBA station coordinates listed in Section
%           15.712 (h) differ from those listed in Footnote US388 from
%           Chapter 4 of the NTIA Manual.  Additionally, the NTIA manual
%           Section 8.3.2 lists the coordinates of Table Mountain as
%           40°07?50??W, 105°14?40?N, where Section 15.712 (h) lists
%           40°07?50?W, 105°15?40?N.
%       NTIA has looked at these concerns and provided updated coordinates
%           as shown on the following slide. We are finalizing all this
%           with NTIA and will make editorial changes to the rules when
%           everything is formalized with them. We will keep the database
%           administrators informed on progress
%
% Updates from 
%   http://www.fcc.gov/encyclopedia/white-space-database-administration-q-page
%       Question -- 7. In Workshop 3, you updated the radio astronomy
%           coordinates but did not list Sugar Grove in the table. You
%           indicated at that time that you would also verify those
%           coordinates. Do you have those coordinates?
%       Answer -- The coordinates for the Naval Research Observatory in
%           Sugar Grove, WV are 38° 30? 58? N Latitude and 79° 16? 48? W
%           Longitude.

error_if_region_unsupported('US');

if nargin >= 3 && varargin{2}
    display(' ------- FORMAT ------- ');
    display('NAME (LOCATION)');
    display('   Lat:  LATITUDE in decimal degrees (LATITUDE in deg, min, sec)');
    display('   Long: LONGITUDE in decimal degrees (LONGITUDE in deg, min, sec)');
    display(' ----- END FORMAT ----- ');
    display(' ');
    display_text = 1;
else
    display_text = 0;
end

if nargin >= 4
    separation_dist = varargin{3};
else
    separation_dist = 2.4;
end

astr(01) = make_astr('Allen Telescope Array', 'Hat Creek, CA', [40 49 4], [121 28 24]);
astr(02) = make_astr('Arecibo Observatory', 'Arecibo, PR', [18 20 37], [66 45 11]);
astr(03) = make_astr('Green Bank Telescope', 'Green Bank, WV', [38 25 59], [79 50 23]);
astr(04) = make_astr('VLBA - Brewster, WA', 'Brewster, WA', [48 7 52], [119 41 00]);
astr(05) = make_astr('VLBA - Fort Davis, TX', 'Fort Davis, TX', [30 38 06], [103 56 41]);
astr(06) = make_astr('VLBA - Hancock, NH', 'Hancock, NH', [42 56 01], [71 59 12]);
astr(07) = make_astr('VLBA - Kitt Peak, AZ', 'Kitt Peak, AZ', [31 57 23], [111 36 45]);
astr(08) = make_astr('VLBA - Los Alamos, NM', 'Los Alamos, NM', [35 46 30], [106 14 44]);
astr(09) = make_astr('VLBA - Mauna Kea, HI', 'Mauna Kea, HI', [19 48 5], [155 27 20]);
astr(10) = make_astr('VLBA - North Liberty, IA', 'North Liberty, IA', [41 46 17], [91 34 27]);
astr(11) = make_astr('VLBA - Owens Valley, CA', 'Owens Valley, CA', [37 13 54], [118 16 37]);
astr(12) = make_astr('VLBA - Pie Town, NM', 'Pie Town, NM', [34 18 04], [108 07 09]);
astr(13) = make_astr('VLBA - Saint Croix, VI', 'Saint Croix, VI', [17 45 24], [64 35 01]);
astr(14) = make_astr('Naval Research Observatory', 'Sugar Grove, WV', [38 30 58], [79 16 48]);


excl_mask = get_us_map(map_size);
[is_in_us lat_coords long_coords] = get_us_map(map_size);

[longs_map lats_map] = meshgrid(long_coords, lat_coords);
longs_vec = longs_map(:);
lats_vec = lats_map(:);


% For each metropolitan area
for i = 1:length(astr)
    if display_text
        display_astr(astr(i));
    end
    
    distances = latlong_to_km(astr(i).lat, astr(i).long, lats_vec, longs_vec);
    excl_points = (distances > separation_dist);
    
    excl_mask = excl_mask & reshape(excl_points, size(is_in_us));
end


num_layers = length(get_simulation_value('chan_list'));

excl_mask = shiftdim(repmat(excl_mask, [1 1 num_layers]),2);
excl_mask = logical(excl_mask);


if nargin >= 2 && varargin{1}
    % Plot on US map (no sampling)
    figure; plot_shapefile('us');
    for i = 1:length(astr)
        % Plot visualization aid
        [Y X] = km_to_latlong(astr(i).lat, astr(i).long, 10*separation_dist, [0:15:360]);
        patch(X, Y, 'b');
        
        % Plot actual locations
        [Y X] = km_to_latlong(astr(i).lat, astr(i).long, separation_dist, [0:15:360]);
        patch(X, Y, 'r');
    end
    
    xlabel('Longitude (degrees)');
    ylabel('Latitude (degrees)');
end


end









function [astr] = make_astr(name, location, lat, long)

astr.name = name;
astr.location = location;

astr.lat = lat(1) + lat(2)/60 + lat(3)/3600;
astr.lat_orig = lat;

astr.long = -(long(1) + long(2)/60 + long(3)/3600);
astr.long_orig = long;


end



function [] = display_astr(astr)

display([astr.name ' (' astr.location ')']);
display(['   Lat:  ' num2str(astr.lat) '       (' num2str(astr.lat_orig) ')']);
display(['   Long: ' num2str(astr.long) '       (' num2str(astr.long_orig) ')']);

end