function [] = make_draft_map(map, title_text)
%   [] = make_draft_map(map, title_text)

if islogical(map)
    map = map*1.0;
end

map_size = get_map_size_string(size(map));
if ~isinf(map(1))   % automask
    region_mask = get_us_map(map_size);
    map(~region_mask) = inf;
end

figure; set(gcf, 'outerposition', [440   296   809   555]);

imagesc(map);
title(title_text);

colorbar;
axis xy;
axis off;
ca = caxis;
caxis([ca(1) 1.1*ca(2)]);
set_bw_cmap;

% Region outlines
set(gcf, 'color', 'white');
set(gcf,'InvertHardcopy','off');

% Plot the region outlines
region_outline_label = generate_label('region_outline', map_size);
[lats longs] = load_by_label(region_outline_label);
patch(longs, lats, 'w', 'linewidth', 1, 'facecolor', 'none', ...
    'edgecolor', 'k');