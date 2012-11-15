%% Population-related plots

%% Basic population maps
clc; clear all; close all;

year = 2010;
pop_type = 'real';

for m = 1:3
    switch(m)
        case 1, map_size = '200x300';
        case 2, map_size = '400x600';
        case 3, map_size = '800x1200';
    end
    
    pop_density = get_pop_density(map_size, pop_type, 1, year);
    
    make_map(pop_density, 'title', ['Population density in ' num2str(year) ...
        ', map size = ' map_size], 'filename', ['Pop density ' num2str(year) ' ' map_size], ...
        'colorbar_title', 'People/km^2', 'save', 'on', ...
        'state_outlines', 'on', 'no_background', 'on',  ...
        'integer_labels', 'on', 'map_type', 'log', 'scale', 20e3);
end

%% CCDFs by area
clc; clear all; close all;
close all;
year = 2010;

colors = 'rbgk';

for m = 1:3
    switch(m)
        case 1, map_size = '200x300';
        case 2, map_size = '400x600';
        case 3, map_size = '800x1200';
    end
    
    us_area = get_us_area(map_size);
    is_in_us = get_us_map(map_size);
    
    figure;
    
    for t = 1:4
        switch(t)
            case 1, type = 'min';
            case 2, type = 'max';
            case 3, type = 'real';
            case 4, type = 'true';
        end
        
        if (t == 4)
            load('true_pop_cdf2010.mat');
            cdfX = cdfX_pop;
            cdfY = cdfY_pop;
        else
            pop = get_pop_density(map_size, type, 1, year);
            pop(isnan(pop)) = 0;
            [cdfX cdfY] = calculate_cdf_from_map(pop, pop, is_in_us);
        end
        
        loglog(cdfX, 1-cdfY, colors(t)); hold on;
        
        leg_strs{t} = type;
    end
    
    grid on; title(['CCDFs for map size ' map_size]);
    xlabel('Population density (people/km^2)');
    axis([10e-3 10e5 10e-6 1.1]);
    
    legend(leg_strs, 'location', 'southwest');
    
    return;
    
    save_plot('png', ['Population density CCDFs ' map_size]);
    
end



%% True population map
% Have to include min_land_area to keep Matlab from crashing

clc; clear all; close all;
year = 2010;
tract_info = load_tract_info(year);

min_land_area = 100;
max_pop_density = 0;
for i = 1:length(tract_info)
    if (tract_info(i).land_area < min_land_area)
        cut = cut + 1;
        continue;
    end
    max_pop_density = max(max_pop_density, tract_info(i).pop_density);
end


tic
close all;
figure;
set(gcf,'Visible','off');
plot_shapefile('us');
hold on;
cut = 0;
for i = 1:length(tract_info)
    
    if (tract_info(i).land_area < min_land_area)
        cut = cut + 1;
        continue;
    end

    idcs = [0 find(isnan(tract_info(i).longs))];

    for j = 1:length(idcs)-1
        idcs2 = idcs(j)+1:idcs(j+1)-1;
        plot_lat = tract_info(i).lats(idcs2);
        plot_long = tract_info(i).longs(idcs2);
        
        alpha = tract_info(i).pop_density / max_pop_density;
%         alpha = 1;

        patch(plot_long, plot_lat, 'b', 'facealpha', alpha, 'edgecolor', 'none');
        
    end
end
cut
plotted = length(tract_info) - cut
save_plot('png', 'True pop density');
toc



%% Census tracts

clc; clear all; close all;
year = 2010;
[ population pop_density land_area total_area ] = load_tract_info(year);

[cdfX_area cdfY_area] = calculate_cdf_from_map(population, total_area, ones(size(population)));
[cdfX_pop cdfY_pop] = calculate_cdf_from_map(population, population, ones(size(population)));


figure;
loglog(cdfX_pop, 1-cdfY_pop, 'b');
hold on;
loglog(cdfX_area, 1-cdfY_area, 'r');
legend('By pop.', 'By area');
grid on; axis tight;
axis([1e3 inf -inf inf]);
scale_axes('x', round(logspace(3,5,10)));