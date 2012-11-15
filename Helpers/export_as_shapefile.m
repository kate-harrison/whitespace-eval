function [data_map] = export_as_shapefile(filename, data_map, varargin)
%   [] = export_as_shapefile(filename, data_map, [plot_function])
%
%   filename = name to save the file
%   data map = map of the data to be exported
%   plot_function (optional) = pre-process the data by mapping it with a
%   function (options: 'linear', 'log')

if all(size(data_map) == 1)
    data_map = get_pop_density(get_simulation_value('map_size'), ...
        get_simulation_value('pop_data_type'));
    display('Exporting population data');
end


%% Create polygon information
display('Creating polygon information');
map_size = determine_map_size(size(data_map));
[is_in_us, lat_coords, long_coords] = get_us_map(map_size);

width = long_coords(2) - long_coords(1);
height = lat_coords(2) - lat_coords(1);

box_lat = [1 1 -1 -1 1] * height/2;
box_long = [-1 1 1 -1 -1] * width/2;

[LONG LAT] = meshgrid(long_coords, lat_coords);
long_array = LONG(:);
lat_array = LAT(:);
is_in_us_array = is_in_us(:);



%% Massage the data
display('Prepping the data');
tooltip_data_map = data_map;
if (nargin > 2)
    switch(lower(varargin{1}))
        case 'log',
            data_map = log10(data_map);
        case 'linear',
            % do nothing
        otherwise,
            error(['Unknown function: ' varargin{1}]);
    end
end
data_array = data_map(:);
tooltip_data_array = tooltip_data_map(:);


%% Clean up the data array
display('Cleaning the data');
del_idcs = isnan(data_array) | isinf(data_array) | ~is_in_us_array;
data_array(del_idcs) = [];
tooltip_data_array(del_idcs) = [];
long_array(del_idcs) = [];
lat_array(del_idcs) = [];

idcs = 1:length(data_array);

[S(idcs).Geometry] = deal('Polygon');
[S(idcs).data] = deal(0);
[S(idcs).tooltip_data] = deal(0);
[S(idcs).Lon] = deal(num2cell(0));
[S(idcs).Lat] = deal(num2cell(0));
[S(idcs).center_lat] = deal(num2cell(0));
[S(idcs).center_long] = deal(num2cell(0));


for i = idcs
    longs = long_array(i) + box_long;
    lats = lat_array(i) + box_lat;
    S(i) = struct('Geometry', 'Polygon', 'data', data_array(i), ...
        'tooltip_data', tooltip_data_array(i), 'Lon', (longs), 'Lat', (lats), ...
        'center_lat', lat_array(i), 'center_long', long_array(i));
end


%% Write the shapefiles, zip them, then delete them (leaving the zip file)
display('Writing files');
shapewrite(S, filename);
% display(['Saved shapefiles: ' filename]);

zip([filename '.zip'], {[filename '.shx'], [filename '.shp'], [filename '.dbf']});
display(['Saved zip file: ' filename '.zip']);

delete([filename '.shx'], [filename '.shp'], [filename '.dbf']);
% display('Cleaned up shapefiles');

end