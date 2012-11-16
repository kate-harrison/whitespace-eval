function [] = read_tower_data(year)
%   [] = read_tower_data(year)
%
%   Parses the .txt file containing the tower data and outputs to
%   [get_simulation_value('data_dir') '/chan_data2011.mat']
%
%   NOTE: Currently this file works for the US only.
%
%   See also: get_simulation_value


switch(get_simulation_value('region_code'))
    case 'US',
    otherwise,
        error('Unsupported region code.');
end

% Make sure we have data for the specified year
if (~string_is(year, '2011'))
    error(['Unsupported tower data year: ' year]);
end

%% Process the tower data
filename = [get_simulation_value('data_dir') '/chan_data2011.mat'];
% If we don't need to compute, exit now
if (get_compute_status(filename) == 0)
    return;
end

%% File location and format
% Source: http://transition.fcc.gov/mb/video/tvq.html. Use the following
% options:
%
% * State = All states
% * Call sign = [blank]
% * Application file number = [blank]
% * City = [blank]
% * Lower channel = All channels
% * Upper channel = 69
% * Service = All services
% * Record types = Licensed stations
% * Output = Text file (pipe delimited / no links)
%
% Use
% http://transition.fcc.gov/mb/audio/am_fm_tv_textlist_key.txt to
% understand the resulting file. Some of the information is copied below.
%
% *File fields*
%
%  Callsign
%  (Not used for TV)
%  Service
%  Channel
%  Directional Antenna (DA) or NonDirectional (ND)
%  Frequency Offset
%  TV Zone
%  (Not Used for TV)
%  TV Status
%  City
%  State
%  Country
%  File Number (Application, Construction Permit or License) or Docket Number (Rulemaking)
%  Effective Radiated Power (kW)
%  (Not Used for TV)
%  Antenna Height Above Average Terrain (HAAT)
%  (Not used for TV)
%  Facility ID Number (unique to each station)
%  N (North) or S (South) Latitude
%  Degrees Latitude
%  Minutes Latitude
%  Seconds Latitude
%  W (West) or (E) East Longitude
%  Degrees Longitude
%  Minutes Longitude
%  Seconds Longitude
%  Licensee or Permittee
%  Kilometers distant (radius) from entered latitude, longitude
%  Miles distant (radius) from entered latitude, longitude
%  Azimuth, looking from center Lat, Lon to this record's Lat, Lon
%  Height of Antenna Radiation Center Above Mean Sea Level (RCAMSL) *
%  Polarization (Horizontal, Circular, Elliptical)                  *
%  Directional Antenna ID Number                                    * **
%  Directional Antenna Pattern Rotation (degrees)                   *
%  Antenna Structure Registration Number                            *
%  Antenna Radiation Center Height Above Ground Level               #
%  Application ID number (from CDBS database)***
%
%    ERP = ERP (maximum) times the [(relative field value) squared]


%% Load the file
% Import the data
file = importdata('tvq_licensed_only.txt');


% Access information for tower |i| with
%
%  file.textdata(i, 4) = service type
%  file.textdata(i, 5) = channel
%  file.textdata(i, 6) = directionality
%  file.textdata(i, 12) = state
%  file.textdata(i, 13) = country
%  file.textdata(i, 15) = ERP (kW)
%  file.textdata(i, 17) = HAAT
%  file.textdata(i, 20) = N vs. S latitude
%  file.textdata(i, 21) = latitude degrees
%  file.textdata(i, 22) = latitude minutes
%  file.textdata(i, 23) = latitude seconds
%  file.textdata(i, 24) = E vs. W longitude
%  file.textdata(i, 25) = longitude degrees
%  file.textdata(i, 26) = longitude minutes
%  file.textdata(i, 27) = longitude seconds
%  file.textdata(i, 29) = km offset from registered lat/long

col.service_type = 4;
col.channel = 5;
col.directionality = 6;
col.state = 12;
col.country = 13;
col.ERP_kW = 15;
col.HAAT = 17;
col.lat_dir = 20;
col.lat_deg = 21;
col.lat_min = 22;
col.lat_sec = 23;
col.long_dir = 24;
col.long_deg = 25;
col.long_min = 26;
col.long_sec = 27;
col.km_offset = 29;


% First few lines (for help with sorting out field numbers):
%1       2            3     4   5    6            7            8   9     10              11             12   13          14              15         16       17       18         19      20 21  22    23   24  25  26    27                                      28                                              29         30         31         32       33        34        35       36       1          2
% | callsign   | null     |ser|chan|dir | freq offset        |TVz|n/a|status |city                     |st |cty| file no            | ERP (kW) | null     | HAAT   | null   | fac. ID no|NS|degminsec lat |EW|degminsec long | licensee                                                                   | km/mi from latlong    | azimuth   |abovesea|polariz.|dir. anten ID, rot | anten. |abv grnd| app ID # |
% |K02JU       |-         |TX |2   |DA  |                    |-  |-  |LIC    |SELAWIK                  |AK |US |BLTTV  -19800620IA  |0.018  kW |-         |0.0     |-       |11543      |N |66 |35 |57.00 |W |160 |0  |0.00  |CITY OF SELAWIK                                                             |   0.00 km |   0.00 mi |  0.00 deg |72.    m|H       |20773     |210.    |-       |0.      |21309     |
% |K02KB       |-         |TX |2   |DA  |                    |-  |-  |LIC    |ALLAKAKET                |AK |US |BLTTV  -19800908IY  |0.018  kW |-         |0.0     |-       |1036       |N |66 |33 |53.00 |W |152 |38 |38.00 |ALLAKAKET CITY COUNCIL                                                      |   0.00 km |   0.00 mi |  0.00 deg |113.   m|H       |20773


% Output format (for backward-compatibility)
%        load 'chan_data_extra.mat'
% Variables within
% 	amsl_idx	7
% 	asrn_idx	3
% 	chan_data	<8071x10 double>
% 	chan_no_idx	1
% 	dist_th_idx	9
% 	erp_idx	8
% 	fac_id_idx	2
% 	fcc_rp_idx	10
% 	haat_idx	6
% 	lat_idx	4
% 	long_idx	5

% Output format
chan_no_idx = 1;
lat_idx = 2;            % in decimal degrees
long_idx = 3;           % in decimal degrees
haat_idx = 4;           % in meters
erp_idx = 5;            % in  kW
dist_th_idx = 6;
fcc_rp_idx = 7;         % in km
ad_idx = 8;             % 'A' or 'D' representing analog and digital respectively

num_cols = 8;


%% Define parameters

TNP = get_simulation_value('TNP');
% threshold =  0.1 * TNP;         % 10% of thermal noise power


% Path loss interpretation information
dist = get_simulation_value('distances');
height = get_simulation_value('heights');

small = 1e-8;

% Some values for reference
min_dist = min(dist);
max_dist = max(dist);
min_haat = min(height);
max_haat = max(height);


% Modify these slightly so that get_E accepts them
dist(1) = dist(1) + small;
dist(length(dist)) = dist(length(dist)) - small;
height(1) = height(1) + small;
height(length(height)) = height(length(height)) - small;


num_entries = size(file.data, 1);

% Output matrix
chan_data = zeros(num_entries, num_cols);
chan_data(:, dist_th_idx) = inf;

for i = 1:num_entries
    if (mod(i, 500) == 0)
        display(['Working on tower ' num2str(i) ' out of ' num2str(num_entries)]);
    end
    
    % Channel number
    chan_data(i, chan_no_idx) = str2num(cell2mat(file.textdata(i, col.channel)));
    
    % Find the type of service (analog vs. digital vs. distributed digital)
    % Note that chan_data(i, ad_idx) is actual the ASCII code for the
    % character assigned to it (to get the character back, use
    % char(chan_data(i, ad_idx)).
    switch(strtrim(cell2mat(file.textdata(i, col.service_type))))
        case {'DT', 'DC', 'LD', 'DS', 'DX'} % digital
            chan_data(i, ad_idx) = 'D';
        case {'CA', 'TX', 'TS'} % analog
            chan_data(i, ad_idx) = 'A';
        case {'DD'} % distributed digital
            chan_data(i, ad_idx) = 'R'; % we'll remove this later
            continue;
        otherwise,
            error(['Unknown service type: ''' ...
                strtrim(cell2mat(file.textdata(i, col.service_type))) '''']);
    end
    
    % Convert the latitude data into the decimal representation of the latitude
    switch(strtrim(cell2mat(file.textdata(i, col.lat_dir))))
        case 'N', lat.sign = 1;
        case 'S', lat.sign = -1;
        otherwise, error('Couldn''t read latitude sign!');
    end
    lat.deg = str2num(cell2mat(file.textdata(i, col.lat_deg)));
    lat.min = str2num(cell2mat(file.textdata(i, col.lat_min)));
    lat.sec = str2num(cell2mat(file.textdata(i, col.lat_sec)));
    lat.dec = lat.sign*(lat.deg + lat.min/60 + lat.sec/3600);
    
    % Convert the longitude data into the decimal representation of the latitude
    switch(strtrim(cell2mat(file.textdata(i, col.long_dir))))
        case 'E', long.sign = 1;
        case 'W', long.sign = -1;
        otherwise, error('Couldn''t read longitude sign!');
    end
    long.deg = str2num(cell2mat(file.textdata(i, col.long_deg)));
    long.min = str2num(cell2mat(file.textdata(i, col.long_min)));
    long.sec = str2num(cell2mat(file.textdata(i, col.long_sec)));
    long.dec = long.sign*(long.deg + long.min/60 + long.sec/3600);
    
    % Save latitude and longitude data
    chan_data(i, lat_idx) = lat.dec;
    chan_data(i, long_idx) = long.dec;
    
    % Preprocess the height to be an appropriate amount
    ht = str2num(cell2mat(file.textdata(i, col.HAAT)));
    if (ht <= min_haat)
        ht = min(height);
    end
    if (ht >= max_haat)
        ht = max(height);
    end
    chan_data(i, haat_idx) = ht;
    
    % Parse the ERP (e.g. '2   kW')
    % Splits into a cell array indexed as:
    %   split_str{1} = magnitude
    %   split_str{2} = units
    split_str = regexp(cell2mat(file.textdata(i, col.ERP_kW)), '[ ]+', 'split');
    % Make sure that it is always specified in kW
    switch(split_str{2})    % units
        case 'kW',  % do nothing
        otherwise,
            display(cell2mat(file.textdata(i,col.ERP_kW)));
            error(['Wrong units: ' split_str{3}]);
    end
    % Save the ERP (in kW)
    chan_data(i, erp_idx) = abs(str2double(split_str{1}));
    % FYI there's one TV tower (index 744) which has negative power
    % for some reason -- perhaps a problem with reading the file.
    % We use the absolute value to take care of this issue.
    
    
    % Calculate the threshold distance
    %     chan_data(i, dist_th_idx) = get_effective_radius(chan_data(i, erp_idx), ...
    %         chan_data(i, chan_no_idx), chan_data(i, haat_idx), threshold);
    
    chan_data(i, fcc_rp_idx) = get_AD_protection_radius( ...
        chan_data(i, erp_idx)*1e3, ...    % need this in W
        chan_data(i, chan_no_idx), ...
        chan_data(i, haat_idx), ...
        chan_data(i, ad_idx) ...
        );
    
    
    
end


%% Remove the distributed digital towers
% Go through and remove entries marked for removal ('R')
remove_idcs = [];
for i = 1:num_entries
    if (char(chan_data(i, ad_idx)) == 'R')
        remove_idcs = [remove_idcs i];
    end
end
chan_data(remove_idcs,:) = [];
removed = length(remove_idcs);

display(['Removed ' num2str(removed) ' Distributed Digital TV entries.']);




%% Remove points outside the continental US
% This removes approximately 500 entries (about 6% of original list)
lats_vec = chan_data(:, lat_idx);
longs_vec = chan_data(:, long_idx);
tower_points = [longs_vec, lats_vec];


[S,A] = shaperead('usastatehi.shp', 'usegeocoords', true);

in_vec = zeros(size(lats_vec));

for i = 1:length(S)
    
    % Omit Alaska and Hawaii
    if (i == 2 || i == 11)
        continue;
    end
    
    
    idcs = [0 find(isnan(S(i).Lon))];
    
    for j = 1:length(idcs)-1
        idcs2 = idcs(j)+1:idcs(j+1)-1;
        plot_lat = S(i).Lat(idcs2);
        plot_long = S(i).Lon(idcs2);
        poly_points = [plot_long; plot_lat]';
        [in] = inpoly(tower_points, poly_points);
        
        in_vec = in_vec | in;
    end
end

chan_data(~in_vec, :) = [];


save(filename, 'chan_data', 'chan_no_idx', 'lat_idx', 'long_idx', ...
    'haat_idx', 'erp_idx', 'dist_th_idx', 'fcc_rp_idx', 'ad_idx');
end