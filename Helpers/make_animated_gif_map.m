function [] = make_animated_gif_map(map, filename, prefix, varargin)
%   [] = make_animated_gif_map(map, filename, prefix, [clims])
%
%   Makes an animated gif from the layers of the map and save it with the
%   filename provided (do not include the extension).
%
%   Maps will be titled as '[prefix] layer#'. If the number of layers
%   matches the length of the channel list (get_simulation_value('chan_list')),
%   the corresponding channel number will be used instead of the layer
%   number.
%
%   The optional fourth argument is an array of the limits of the caxis.
%
%   Credit: http://www.mathworks.com/support/solutions/en/data/1-48KECO/
%
%   See also: get_simulation_value, imagesc, caxis, getframe, frame2im, imwrite

gif_filename = [filename '.gif'];
delete(gif_filename);

map_size = get_map_size_string(size(map));
region_mask = get_us_map(map_size);

if nargin > 3
    clims = varargin{1};
else
    clims = [-inf inf];
end

chan_list = get_simulation_value('chan_list');
if length(chan_list) ~= size(map,1)
    chan_list = 1:size(map,1);
end

f = figure;
set(f, 'outerposition', [440   348   681   503]);
for n = 1:size(map,1)
    layer = squeeze(map(n,:,:));
    layer(~region_mask) = inf;
    imagesc(layer);
    axis xy; axis off;
    set_bw_cmap;
    caxis(clims);
    
%     set(gca, 'position', [0 0 1 1]);
    
    t = title(['  ' prefix ' ' num2str(chan_list(n))]);
    pos = get(t, 'position');
    set(t, 'position', [pos(1) 0]);
%     set(t, 'position', [0.5 1]);
    set(t, 'fontsize', 14);
    set(t, 'fontname', 'computermodern');
    set(t, 'fontweight', 'bold');
    
    drawnow
%     frame = getframe(f);
    frame = getframe; % cuts out title
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    if n == 1;
        imwrite(imind,cm,gif_filename,'gif', 'Loopcount',inf);
    else
        imwrite(imind,cm,gif_filename,'gif','WriteMode','append');
    end
end


end