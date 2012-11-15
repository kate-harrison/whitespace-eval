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
% Tick marks
set(gca, 'fontsize', font_size);
set(gca, 'fontname', font_name)

% X-axis label
xlhand = get(gca,'xlabel');
set(xlhand, 'fontsize',font_size);
set(xlhand, 'fontname', font_name)

% Y-axis label
ylhand = get(gca,'ylabel');
set(ylhand, 'fontsize',font_size);
set(ylhand, 'fontname', font_name)

% Legend
lhand = legend(gca);
set(lhand, 'fontsize', font_size);
set(lhand, 'fontname', font_name)

% Legend label
try
    hl = findobj(gcf,'Tag','legend');
    hl_t = get(hl,'Title');
    set(hl_t, 'fontsize', font_size);
catch error
end


% Title
thand = get(gca, 'title');
set(thand, 'fontname', font_name)

% Colorbar
try
    chand = get(gca, 'colorbar');
    set(chand, 'fontname', font_name);
end

if (nargin >= 3 && varargin{1})
    set(gcf,'PaperPositionMode','auto');
end


%% Save the plot
switch(format)
    case {'png'},
        print('-dpng', ['Output/' plot_filename '.png']);
    case {'vector', 'eps'},
        print('-depsc', ['Output/' plot_filename '.eps']);
        
    case {'bitmap', 'jpeg'},
        print('-djpeg', ['Output/' plot_filename '.jpeg']);
end

end