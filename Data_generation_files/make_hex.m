function [] = make_hex(hex_label)
%   [] = make_hex(hex_label)
%
%   Make hexagon data.

switch(hex_label.label_type)
    case 'hex',
    otherwise,
        error(['Unsupported mode: tried to run make_hex() with ' ...
            'label of type ' hex_label.label_type]);
end

wifi = strcmpi(hex_label.type, 'hotspot');
% wifi = isfield(hex_label, 'wifi') & hex_label.wifi == 1;
% if(wifi)
%     display('Wifi version!');
% end

height = hex_label.char_label.height;
hex_label.char_label.power = 1;
power = 1;  % we will correct for actual power in load_hex


filename = generate_filename(hex_label);

% If we don't need to compute, exit now
if (get_compute_status(hex_label) == 0)
    return;
end

global num_points
num_points = 250;   % 100


chan_list = get_simulation_value('chan_list');


% It is fine to use that cap it at 100km radius cells. That way, even the
% far away interferer will be within your 1000km.
% For small cells, do the same. Make the cell radius not go smaller than
% 50m.
area_array = logspace(log10(pi*(.05)^2), log10(pi*(100)^2), 65);


% Preallocate
% How to access the data in these arrays:
%   signals(channel_index, area_index, point_index)
%   noises(channel_index, area_index, point_index)
noises = zeros(length(chan_list), length(area_array), num_points);
signals = zeros(length(chan_list), length(area_array), num_points);



for a = 1:length(area_array)
    if (mod(a, 10) == 0)
        display(['Working on tower area ' num2str(a) ' out of ' num2str(length(area_array))]);
    end

    tower_area = area_array(a);
    
    hexagon_area = tower_area;   % km^2
    hexagon_side_length = sqrt(hexagon_area * 2/(3*sqrt(3)));
    hexagon_height = sqrt(3)*hexagon_side_length;
    hexagon_width = 2*hexagon_side_length;
    
%     xv = [ -(hexagon_width/2-hexagon_side_length/2)  (hexagon_width/2-hexagon_side_length/2)  hexagon_width/2  (hexagon_width/2-hexagon_side_length/2)  -(hexagon_width/2-hexagon_side_length/2)  -hexagon_width/2 ];
%     yv = [ hexagon_height/2 hexagon_height/2 0 -hexagon_height/2 -hexagon_height/2 0 ];
%     xv = [xv xv(1)];
%     yv = [yv yv(1)];
    
    grid_size = 8;  % 5
    hexagons = get_hexagon_grid([0,0], tower_area, hexagon_width*grid_size, hexagon_height*grid_size);
    %     hexagons.power = power*ones(size(hexagons));
    hex_center_x = [hexagons.center_x];
    hex_center_y = [hexagons.center_y];
    num_towers = length(hexagons);
    tx_idx = ceil(num_towers/2);
    
%         figure; hold on;
%         for i = 1:length(hexagons)
%             fill(hexagons(i).xv, hexagons(i).yv, 'g');
%         end
%         fill(hexagons(tx_idx).xv, hexagons(tx_idx).yv, 'r');
    
    
    tx_center_x = hexagons(tx_idx).center_x;
    tx_center_y = hexagons(tx_idx).center_y;
    
    if (wifi)
        [x_pts y_pts] = get_hexagon_points(.1^2*pi);
    else
        [x_pts y_pts] = get_hexagon_points(tower_area);
    end
    num_points = length(x_pts);
    
    % Translate to our hexagon
    x_pts = x_pts + tx_center_x;
    y_pts = y_pts + tx_center_y;
    
    
%     scatter(x_pts, y_pts, 'k.')

    hex_center_x(tx_idx) = [];
    hex_center_y(tx_idx) = [];
    
    
    % % Add more points outside
    inner_radius = logspace(log10(sqrt(max(hex_center_x)^2 + max(hex_center_y)^2)), log10(900), 10);
    outer_radius = [inner_radius(2:end) 1000];
    ring_width = outer_radius - inner_radius;
    
    outer_area = pi*outer_radius.^2;
    inner_area = pi*inner_radius.^2;
    ring_area = outer_area - inner_area;
    
    ring_avg_dist_to_primary = outer_radius - ring_width/2;
    
    % For a person between the tower and r_p km away
    num_angle_points = 10;
    angle_array = 0:2*pi/(num_angle_points):2*pi;   % replace with linspace(0, 2*pi, num_angle_points)
    angle_array = angle_array(1:end-1);             % also included in replacement
    
    radius = repmat(ring_avg_dist_to_primary, [num_angle_points 1]);
    radius = radius(:);
    angle = repmat(angle_array', [length(outer_radius) 1]);
    ring_area = repmat(ring_area, [num_angle_points 1]);
    ring_power = ((ring_area(:)/num_angle_points) / tower_area);
    
    [x y] = pol2cart(angle, radius);
%     scatter(x,y,'k*');

    % Actually add in these extra points
    hex_center_x = [hex_center_x x'];
    hex_center_y = [hex_center_y y'];
    powers = [ones(1, length(hexagons)-1) ring_power'];



    dist_to_center =  sqrt( (tx_center_x - x_pts).^2 + (tx_center_y - y_pts).^2 );
    for pt = 1:num_points
%         pt
        distances = sqrt( (hex_center_x - x_pts(pt)).^2 + (hex_center_y - y_pts(pt)).^2 );
        for c = 1:length(chan_list)
            noises(c, a, pt) = sum(apply_path_loss(1, chan_list(c), height, distances)' .* powers);
            signals(c, a, pt) = apply_path_loss(1, chan_list(c), height, dist_to_center(pt));
            
%             Difference to the first point (c = 1, a = 1, pt = 1) with
%             grid_size = 100

%             noises(c,a,pt)
%             perc_diff = (1.8378e-4 - noises(c,a,pt))/1.8378e-4 * 100
%             return;
        end
        
    end
    
    
filename = save_temp_filename(hex_label, ['checkpoint=' num2str(a)]);
save_data(filename, 'noises', 'signals', 'num_points');

end


% Save the final data
save_data(save_filename(hex_label), 'noises', 'signals', 'num_points', 'area_array');
add_extended_info_to_file(save_filename(hex_label), 'get_hexagon_grid');

end


function [x_pts y_pts] = get_hexagon_points(tower_area)

global num_points
% num_points = 100;
points_filename = ['Data/hexagon_points' num2str(num_points) '.mat'];

if (exist(points_filename, 'file') == 2)
%     display('Loading user points');
    load(points_filename);
else
    display('Generating user points');
    x_points = zeros(1, num_points);
    y_points = zeros(1, num_points);
    hexagon_area = 1;   % km^2
    hexagon_side_length = sqrt(hexagon_area * 2/(3*sqrt(3)));
    hexagon_height = sqrt(3)*hexagon_side_length;
    hexagon_width = 2*hexagon_side_length;
    
    % Make our cell (note that it is centered at (0,0) and we will shift the
    % generated points accordingly)
    xv = [ -(hexagon_width/2-hexagon_side_length/2)  (hexagon_width/2-hexagon_side_length/2)  hexagon_width/2  (hexagon_width/2-hexagon_side_length/2)  -(hexagon_width/2-hexagon_side_length/2)  -hexagon_width/2 ];
    yv = [ hexagon_height/2 hexagon_height/2 0 -hexagon_height/2 -hexagon_height/2 0 ];
    xv = [xv xv(1)];
    yv = [yv yv(1)];
    x_max = hexagon_width/2;
    x_min = -hexagon_width/2;
    y_max = hexagon_height/2;
    y_min = -hexagon_height/2;
    
    
    % Make the points
    % For each sample point in our cell
    for pt = 1:num_points
        
        % Pick the point
        in_poly = 0;
        while (in_poly == 0)
            x_pt = uniform_rand(x_min, x_max);
            y_pt = uniform_rand(y_min, y_max);
            in_poly = inpolygon(x_pt, y_pt, xv, yv);
        end
        
        x_points(pt) = x_pt;
        y_points(pt) = y_pt;
        
    end
    
    x_points = x_points / hexagon_width;
    y_points = y_points / hexagon_height;
    
    save_data(points_filename, 'x_points', 'y_points');
end


hexagon_side_length = sqrt(tower_area * 2/(3*sqrt(3)));
hexagon_height = sqrt(3)*hexagon_side_length;
hexagon_width = 2*hexagon_side_length;

x_pts = x_points * hexagon_width;
y_pts = y_points * hexagon_height;


end
