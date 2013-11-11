function [] = save_plot( format, plot_filename, varargin )
%SAVE_PLOT Saves the plot with the given filename and format.
%
%   [  ] = save_plot( format, plot_filename, varargin )
%
%   format - (vector/eps) or (bitmap/jpeg)
%   plot_filename - The desired filename (omit extensions).
%
%   The third input is optional; if it is given and evaluates to true, then
%   the plot will be saved with dimensions as seen on the screen.

format = lower(format);

load 'plot_parameters.mat'

%% Format the axes, title, legend, and colorbar
axes_list = findall(gcf,'type','axes');
for a = 1:length(axes_list)
    ax = axes_list(a);

    % Format the axis
    set(ax, 'fontsize', font_size);
    set(ax, 'fontname', font_name);
    
    % X-axis label
    xlhand = get(ax,'xlabel');
    set(xlhand, 'fontsize',font_size);
    set(xlhand, 'fontname', font_name);
    
    % Y-axis label
    ylhand = get(ax,'ylabel');
    set(ylhand, 'fontsize',font_size);
    set(ylhand, 'fontname', font_name);

    % Format the title
    try
        thand = get(ax, 'title');
        set(thand, 'fontname', font_name);
        set(thand, 'fontsize', font_size);
    catch % do nothing
    end
    
    % Format the legend
    try
        lhand = legend(ax);
        set(lhand, 'fontsize', font_size);
        set(lhand, 'fontname', font_name);
    catch % do nothing
    end
    
    % Format the colorbar
    try
        chand = get(ax, 'colorbar');
        set(chand, 'fontname', font_name);
    catch % do nothing
    end
end


% Format the legend label if one exists
try
    hl = findobj(gcf,'Tag','legend');
    hl_t = get(hl,'Title');
    set(hl_t, 'fontsize', font_size);
catch
end



if (nargin >= 3 && varargin{1})
    set(gcf,'PaperPositionMode','auto');
end


%% Save the plot
base_filename = [get_simulation_value('output_dir') '/' plot_filename];

switch(format)
    case {'png'},
        print('-dpng', [base_filename '.png']);
    case {'vector', 'eps'},
        print('-depsc', [base_filename '.eps']);
        
    case {'bitmap', 'jpeg'},
        print('-djpeg', [base_filename '.jpeg']);
end

end