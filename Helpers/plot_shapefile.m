function [fig_handle] = plot_shapefile(filename, varargin)
%   [fig_handle] = plot_shapefile(filename, [color], [linewidth])
%
%   Plots the shapefile specified by [filename] with background color
%   [color] and outlines with linewidth [linewidth].
%
%   If [filename] is 'us', the USA state map is plotted (source:
%   usastatehi.shp which ships with Matlab).
%
%   Defaults:
%       color: light gray
%       linewidth: 1
%
%   May leave [color] empty (anything for which ~isempty(color) evaluates
%   to true) to use default color but specify a linewidth.


if (string_is(filename, 'us'))
    new_filename = 'usastatehi.shp';
else
    new_filename = filename;
end

if (nargin >= 2 && ~isempty(varargin{1}))
    color = varargin{1};
else
    color = [.9 .9 .9];
end

if (nargin >= 3)
    lw = varargin{2};
else
    lw = 1;
end

[S,A] = shaperead(new_filename, 'usegeocoords', true);


fig_handle = gcf;
grid on; hold on;

for i = 1:length(S)
    % If it's just a point, plot that and continue
    if string_is(S(i).Geometry, 'Point')
        plot(S(i).Lon, S(i).Lat, 'b.', 'markersize', 10);
        continue;
    end
    
    % If it's a patch...
    idcs = [0 find(isnan(S(i).Lon))];

    for j = 1:length(idcs)-1
        idcs2 = idcs(j)+1:idcs(j+1)-1;
        plot_lat = S(i).Lat(idcs2);
        plot_long = S(i).Lon(idcs2);
        patch(plot_long, plot_lat, color, 'LineWidth', lw);
        
    end
end

switch(filename)
    case 'us', axis(100*[-1.273232468320087  -0.657623926713269   0.238587155963303   0.495467889908257]);
        set(gcf, 'outerposition', [56   126   992   731]);
end


end