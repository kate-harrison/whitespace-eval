function [] = make_tract_info(year)
%   [] = make_tract_info(year)
%
% Reads in shapefiles containing polygon data for census tracts and
% combines it with the population data created by make_pop_info.m to make
% tract_info.mat which will be used in make_population_maps.m.
%
%   year = year for census data (valid: 2000, 2010)
%
% Please open this file to see additional information (e.g. where to obtain
% the data.)
%
%
% NOTE: Currently this file works for the US only.

switch(get_simulation_value('region_code'))
    case 'US',
    otherwise,
        error('Unsupported region code.');
end


% These shapefiles (downloaded from
% ftp://ftp2.census.gov/geo/tiger/TIGER2010/TRACT/) will give us the
% polygon which describes each census tract. They also include the area of
% each polygon (broken down into water and land area). In this section, we
% will link the population information from the previous section with each
% tract and its polygon. The result is stored in a structure and saved for
% further processing.
%
% We can read shapefiles with Matlab using the following command:
%
%       [S,A] = shaperead(filename)
%
% Relevant information for polygon |i| is accessed using:
%
%       S(i).Lon = list of longitude points
%       S(i).Lat = list of latitude points
%       A(i).STATEFPxx = string for state code
%       A(i).CTIDFPxx = unique identifier = [state_code county_code tract_code]
%       A(i).ALANDxx = land area (m^2)
%       A(i).AWATERxx = water area (m^2)
%
% Endnote #16 on page 6-20 of
% http://www.census.gov/prod/cen2010/doc/pl94-171.pdf indicates that
% |ALAND10| and |AWATER10| are in m^2.
%
%
% To obtain this information again, use the following commands:
%
% 2010 data:
%   wget * ftp://ftp2.census.gov/geo/tiger/TIGER2010/TRACT/2010/tl_2010_[0-9][0-9]_tract10.zip
% 2000 data:
%   wget * ftp://ftp2.census.gov/geo/tiger/TIGER2010/TRACT/2000/tl_2010_[0-9][0-9]_tract00.zip



% Check to make sure it's a valid year
validate_flags('', 'pop_data_year', year)


% If you want to force a regeneration of the data (even if it already
% exists), set this to 1. Otherwise, set it to 0. Here, we choose the
% default option.
regenerate = get_simulation_value('recompute');
% regenerate = 1;

% Note that we will make sure that the year is noted in two places (namely,
% the containing folder and the filename) so that there are no accidents.
switch(year)
    case 2000,  file_num = '500';   field_num = '00';
    case 2010,  file_num = '510';   field_num = '10';
    otherwise,
        error(['Invalid census year: ' num2str(year) ...
            '. Valid inputs are 2000 and 2010.']);
end

% The fields in the structure read in from the file differ based on year;
% here, we generalize the field names. See the article below for syntax
% questions:
% http://blogs.mathworks.com/loren/2005/12/13/use-dynamic-field-references/
switch(year)
    case 2000,  field.geoid = ['CTIDFP' field_num];
    case 2010,  field.geoid = ['GEOID' field_num];
end
field.state = ['STATEFP' field_num];
field.landarea = ['ALAND' field_num];
field.waterarea = ['AWATER' field_num];


% This is the directory in which we'll be working
data_path = get_population_data_dir(year);

% This is the file which contains the population data for this year
pop_filename = [data_path '/Population/pop_data' num2str(year) '.mat'];

% This is the file we will save
result_filename = [data_path '/tract_info' num2str(year) '.mat'];



% If the file already exists and we don't want to regenerate the file, exit
% now.
if ( (exist(result_filename, 'file') == 2) && ~regenerate )
    return;
end

% Load the population information
load(pop_filename);


% Preallocate for speed
tract_info.geoid = [];
tract_info.lats = [];
tract_info.longs = [];
tract_info.pop = [];
tract_info.land_area = [];
tract_info.total_area = [];
tract_info.pop_density = [];
tract_info.state = [];

% We'll keep track of any weird things that might happen with these
% variables
total_polys = 0;
num_missed_zctas = 0;


% Our files are numbered through 56 but this will be sure to catch
% them (and won't error if it doesn't exist).
% File #72 is for Puerto Rico -- leave it out
for state = 1:59
    
    % State #2 is Alaska -- skip it
    % State #15 is Hawaii -- skip it
    if (state == 2 || state == 15)
        continue;
    end
    
    state_num = num2str(state, '%02d');
    poly_filename = [data_path '/Geography/tl_2010_' state_num ...
        '_tract' field_num '/tl_2010_' state_num '_tract' field_num '.shp'];
    
    if (exist(poly_filename, 'file') ~= 2)
        continue;
    else
        display(poly_filename)
    end
    
    [S,A] = shaperead(poly_filename, 'UseGeoCoords', true);
    
    num_shapes = length(A)
    total_polys = total_polys + num_shapes;
    
    clear temp_polys;   % Clear the data from last time so we don't have any funny business
    temp_polys(num_shapes).geoid = [];
    temp_polys(num_shapes).lats = [];
    temp_polys(num_shapes).longs = [];
    temp_polys(num_shapes).pop = [];
    temp_polys(num_shapes).land_area = [];
    temp_polys(num_shapes).total_area = [];
    temp_polys(num_shapes).pop_density = [];
    temp_polys(num_shapes).state = [];
    
    
    
    % For each polygon...
    for i = 1:num_shapes
        % Record ZCTA, lat coords, long coords, land area, and total area
        temp_polys(i).geoid = str2double(A(i).(field.geoid));
        temp_polys(i).lats = S(i).Lat;
        temp_polys(i).longs = S(i).Lon;
        temp_polys(i).land_area = A(i).(field.landarea)/1e6;  % Convert from m^2 to km^2
        temp_polys(i).total_area = (A(i).(field.landarea) + A(i).(field.waterarea))/1e6;
        temp_polys(i).state = str2double(A(i).(field.state));
        
        % Now we work on finding the population for this ZCTA
        % Find those entries in our population data matrix which have the same
        % ZCTA as our polygon
        idx = find(pop_data.data(:, pop_data.geoid_idx) == temp_polys(i).geoid);
        
        switch(length(idx))
            case 0,
                display(['No match found for GeoID ' A(i).(field.geoid)]);
                temp_polys(i).pop = 0/0;
                continue;
            case 1, % nothing
            case 2,
                display(['Found duplicate entry for GeoID' A(i).(field.geoid)]);
        end
        temp_polys(i).pop = sum(pop_data.data(idx, pop_data.pop_idx));
        
%         % Select those entries whose state matches this polygon's
%         % state and add up the populations
%         states = pop_data.data(idx, pop_data.state_idx);
%         idx2 = (states == str2double(A(i).(field.state)));
%         idx = idx(idx2);
%         if (isempty(idx))
%             temp_polys(i).pop = 0/0;        % no corresponding data found => NaN
%             num_missed_zctas = num_missed_zctas + 1
%         else
%             temp_polys(i).pop = sum(pop_data.data(idx, pop_data.pop_idx));
%         end
        
        
        % Assign the population density as (population)/(total area). Note that
        % we could also choose to use (population)/(land area) as Mubaraq did
        % in his original code.
        temp_polys(i).pop_density = temp_polys(i).pop / temp_polys(i).total_area;
        
        
    end
    
    
    % Add this state to existing data
    [tract_info] = [tract_info, temp_polys];
    
end

% Initialization of zcta_polys + concatenation of structures causes a null
% first entry, so we remove it
tract_info(1) = [];

if (length(tract_info) ~= total_polys)
    length_array = length(tract_info)
    total_polys
    error('Number of polygons doesn''t match');
end

if (num_missed_zctas > 0)
    warning(['Unable to find population data for ' num2str(num_missed_zctas) ...
        ' polygons. You might want to verify that you have population data ' ...
        'for all shapefiles you downloaded (e.g. you may have left out ', ...
        'Alaska in one but not both']);
end


%% Save some data in matrices so we can load just that data from the .mat file
num_els = length(tract_info);
pop = zeros(1, length(tract_info));
pop_density = zeros(1, length(tract_info));
land_area = zeros(1, length(tract_info));
total_area = zeros(1, length(tract_info));


for i = 1:num_els
    pop(i) = tract_info(i).pop;
    pop_density(i) = tract_info(i).pop_density;
    land_area(i) = tract_info(i).land_area;
    total_area(i) = tract_info(i).total_area;
end


save(result_filename, 'tract_info', 'pop', 'pop_density', 'land_area', 'total_area');

