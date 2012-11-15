% This is a basic test file which provides code to test the shapefiles.

% We can read shapefiles with Matlab using the following command:
%
%       [S,A] = shaperead(filename)
%
% Relevant information for polygon |i| is accessed using:
%
%       S(i).Lon = list of longitude points
%       S(i).Lat = list of latitude points
%       A(i).STATEFPxx = string for state code
%       A(i).ZCTA5CExx = string for ZCTA code
%       A(i).GEOIDxx = string for GeoID = [state_code zcta_code]
%       A(i).ALANDxx = land area (m^2)
%       A(i).AWATERxx = water area (m^2)
%

%% Check total land area

clc; clear all; close all;
year = 2010;
state = 2;   % Alaska
% state = 30;     % Montana
% state = 48;     % Texas
% state = 56;     % Wyoming
% state = 1;      % Alabama

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
field.zcta = ['CTIDFP' field_num];
field.state = ['STATEFP' field_num];
field.landarea = ['ALAND' field_num];
field.waterarea = ['AWATER' field_num];

% This is the directory in which we'll be working
data_path = ['Population_and_tower_data/Population/' num2str(year)];


state_num = num2str(state, '%02d');
poly_filename = [data_path '/Geography/tl_2010_' state_num ...
    '_tract' field_num '/tl_2010_' state_num '_tract' field_num '.shp'];

[S,A] = shaperead(poly_filename, 'UseGeoCoords', true);

total_area = 0;

for i = 1:length(A)
    total_area = total_area + A(i).(field.landarea) + A(i).(field.waterarea);
end

total_area/1e6


%% Look at the shape of each state

clc; clear all; close all;

for i = 1:80
    close all;
    figure;
    
    state_num = num2str(i, '%02d');
    filename = ['Population_and_tower_data/Population/2010/Geography/tl_2010_' ...
        state_num '_tract10/tl_2010_' state_num '_tract10.shp']
    
    if (exist(filename, 'file')~=2)
        continue;
    end
    
    plot_shapefile(filename, [1 1 1]*.9);
    title(num2str(i));
    pause
end


