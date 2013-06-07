function [] = make_colors()
% Make standard colors for the plots


% If we don't need to compute, exit now
% if (get_compute_status('Data/colors.mat') == 0)
%     return;
% end


% Use UISETCOLOR to make new colors

dark_blue = [0.1529    0.2275    0.3725];
dark_green = [0.0706    0.2118    0.1412];
dark_purple = [0.3490    0.2000    0.3294];
dark_red = [0.4000         0         0];
dark_orange = [0.6000    0.2000         0];


bright_blue = [0    0.2000    1.0000];
bright_green = [0    0.4980         0];
bright_purple = [0.4784    0.0627    0.8941];
bright_red = [0.8471    0.1608         0];
bright_orange = [1.0000    0.6000         0];


almost_black = [1 1 1]*.15;
dark_gray = [1 1 1]*.3;
medium_gray = [1 1 1]*.5;
light_gray = [1 1 1]*.9;



save_data('Data/colors.mat');
end
