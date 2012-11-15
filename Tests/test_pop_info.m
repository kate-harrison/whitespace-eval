%% Test population and zip data

% Can verify some info with
% http://www.census.gov/geo/www/maps/2010_census_profile_maps/census_profile_2010_main.html



clc; clear all; close all;

year = 2010;

load(['pop_data' num2str(year)]);

display(['There are ' num2str(sum(pop_data.data(:,pop_data.pop_idx)==0)) ...
    ' census tracts with zero population.']);

% state = 2;   % Alaska
% state = 30;     % Montana
% state = 48;     % Texas
% state = 56;     % Wyoming
% state = 1;      % Alabama
% state = 55;     % Wisconsin
state = 12;     % Florida

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
data_path = ['Population_and_tower_data/Population/' num2str(year)];


state_num = num2str(state, '%02d');
poly_filename = [data_path '/Geography/tl_2010_' state_num ...
    '_tract' field_num '/tl_2010_' state_num '_tract' field_num '.shp'];

[S,A] = shaperead(poly_filename, 'UseGeoCoords', true);

%% Plot the state
close all;

% in = 0;
% test_lat = 46.65;
% test_long = -91.2;

figure; hold on; grid on;
set(gcf, 'outerposition', [441    77   685   741]);
for i = 1:length(S)
% for i = 39

%     in = in | inpolygon(test_lat, test_long, S(i).Lat, S(i).Lon);
%     if (in)
%         i
%     end

    idcs = [0 find(isnan(S(i).Lon))];
%     plot_lat = S(i).Lat;
%     plot_long = S(i).Lon;
    %     plot_lat(idcs(2:end)) = plot_lat(idcs(1:end-1)-1);
    %     plot_long(idcs(2:end)) = plot_long(idcs(1:end-1)-1);
    
    for j = 1:length(idcs)-1
        idcs2 = idcs(j)+1:idcs(j+1)-1;
        plot_lat = S(i).Lat(idcs2);
        plot_long = S(i).Lon(idcs2);
        patch(plot_long, plot_lat, [1 1 1]*.9);
        
    end
end
