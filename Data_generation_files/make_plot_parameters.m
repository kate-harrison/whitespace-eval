function [] = make_plot_parameters()
% Standardize plot parameters by defining some of them here


filename = 'Data/plot_parameters.mat';

% If we don't need to compute, exit now
if (get_compute_status(filename) == 0)
    return;
end

font_size = 16;
font_size_shift = 4;
font_name = 'computermodern';

save_data(filename);
end
