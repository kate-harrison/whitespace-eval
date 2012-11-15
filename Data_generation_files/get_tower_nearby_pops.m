function [populations pop_densities areas] = get_tower_nearby_pops(pop_year, tower_year)
%   [populations pop_densities areas] = get_tower_nearby_pops(pop_year, tower_year)
%
%   Gives the population and population density within the FCC's r_p for
%   each tower (same order as chan_data).
%
%   Note: filed under Data_generation_files/ because it generates the data
%   if it doesn't exist.

filename = ['Data/tower_nearby_pops tower_year=' tower_year ' pop_year=' num2str(pop_year) '.mat'];

if ~(exist(filename, 'file') == 2)
    
    display(['Working on... ' filename]);
    
    [chan_data chan_data_indices] = load_chan_data(tower_year);
    lats = chan_data(:, chan_data_indices.lat_idx);
    longs = chan_data(:, chan_data_indices.long_idx);
    rps = chan_data(:, chan_data_indices.fcc_rp_idx);
    
    
    
    
    close all;
    
    areas = pi*rps.^2;
    populations = zeros(size(rps));
    
    NOP = 20;
    
    tract_info = load_tract_info(pop_year);
    
    % Create bounding boxes for the polygons
    for i = 1:length(tract_info)
        tract_info(i).max_lat = max(tract_info(i).lats);
        tract_info(i).min_lat = min(tract_info(i).lats);
        tract_info(i).max_long = max(tract_info(i).longs);
        tract_info(i).min_long = min(tract_info(i).longs);
    end
    
    
    
    
    for i = 1:length(lats)
        rp = rps(i);
        
        if (rp == 0)
            continue;
        end
        
        if (mod(i, 10) == 0)
            display(['Working on tower ' num2str(i) ' out of ' num2str(length(lats))]);
        end
        
        clear tower_pt
        [tower_pt.y tower_pt.x] = km_to_latlong(lats(i), longs(i), rp, linspace(0, 359, 20));
        tower_pt.hole = 0;
        
        %     patch(tower_pt.x, tower_pt.y, 'b', 'facealpha', .1, 'edgecolor', 'none');
        
        max_lat = max(tower_pt.y);
        min_lat = min(tower_pt.y);
        max_long = max(tower_pt.x);
        min_long = min(tower_pt.x);
        
        
        % For each tract
        for n = 1:length(tract_info)
            
            % Overlap logic: http://www.rgrjr.com/emacs/overlap.html
            if (~((tract_info(n).min_lat < max_lat) && (min_lat < tract_info(n).max_lat)) || ...
                    ~((tract_info(n).min_long < max_long) && (min_long < tract_info(n).max_long)));
                continue;
            end
            
            
            
            idcs = [0 find(isnan(tract_info(n).longs))];
            
            % For each polygon within the tract
            for m = 1:length(idcs)-1
                idcs2 = idcs(m)+1:idcs(m+1)-1;
                clear tract_poly
                tract_poly.y = tract_info(n).lats(idcs2);
                tract_poly.x = tract_info(n).longs(idcs2);
                tract_poly.hole = 0;
                
                % Find the overlap
                overlap_poly = PolygonClip(tower_pt, tract_poly, 1);
                
                % If no overlap, skip to the next polygon
                if (isempty(overlap_poly))
                    continue;
                end
                
                % Add up the "area" of the overlap
                poly_area = 0;
                for k = 1:length(overlap_poly)
                    poly_area = poly_area + ...
                        polyarea(overlap_poly(k).x, overlap_poly(k).y);
                end
                
                % Find the percentage of the total area
                total_area = polyarea(tract_poly.x, tract_poly.y);
                perc_area = poly_area / total_area;
                
                % Add the portion of the population in that tract that
                % should be in this pixel
                populations(i) = populations(i) + tract_info(n).pop * perc_area;
                
                
            end
        end
        
        
        
        
    end
    
    pop_densities = populations ./ areas;
    
    clear tract_info
    save(filename);
end


load(filename, 'populations', 'pop_densities', 'areas');
% populations = file.populations;
% pop_density = file.pop_density;
% areas = file.areas;

end