function [] = make_map(varargin)
% [] = MAKE_MAP(data, options)
%
% This function accepts both name-value pairs or a structure as input to
% specify the mapping options. See below for details and examples.
%
% USING NAME-VALUE PAIRS TO SPECIFY OPTIONS
%   The list of option names and default values is:
%    o map_type - Data scaling [ {linear} | log | atan ]
%    o title - Title of the plot [ {''} | string ]
%    o colorbar_title - Title for the colorbar [ {''} | string ]
%    o filename - Name for saved figure (if 'save' is 'on') [ {timestamp} |
%       string ]
%    o save - Save the plot [ {on} | off ]
%    o scale - Colorbar scale; if a scalar, this is the maximum plot value.
%       If an array, these are the values to be plotted (scale_div will be
%       ignored). [ {max(max(data))} | double | double array ]
%    o scale_div - Number of tick marks on the colorbar (0 = Matlab
%       default) [ {0} | integer ]
%    o autolabel - If 'on', automatically sets the colorbar scale and title
%       based on the maximum finite value of your data [ {off} | on ]
%    o integer_labels - If 'on', makes sure that the colorbar labels are
%       integers only. [ {off} | on ]
%    o state_outlines - If 'on', draws the outlines of the states on top of
%       the data [ {off} | on ]
%    o state_outline_color - Color for state outlines (if on) [ {'k'} | *]
%       (accepts any valid color in Matlab format (see plot() for details))
%    o no_background - If 'on', ensures that areas outside of the US are
%       white [ {off} | on ]
%    o visibility - If 'off', does not output to the screen (still saves if
%       instructed to do so) [ {on} | off ]
%    o auto_cap - If 'on', makes any non-infinite values greater than
%       [scale] equal to 0.98*[scale]. This prevents white patches when
%       some data points exceed the scale. [ {off} | on ]
%
% EXAMPLE
%               make_map(data, 'map_type', 'log', 'scale', 42);
%
%
%
% USING A STRUCTURE TO SPECIFY OPTIONS
%   The function also accepts an 'options' structure as the second (and
%       last) argument of the form 
%               options_struct.option_name = option_value
%   Note that the defaults are as listed above.
%
% EXAMPLE
%               options.map_type = 'log';       % Set an option
%               options.scale = 42;             % Set another option
%               make_map(data, options);        % Call the function
%
%
%
% NOTES:
%    + Plots are not titled if 'save' is 'on'.
%    + Infinite values are plotted as white; zero values are black.

load 'plot_parameters.mat';


if (nargin < 1)
    error('Not enough inputs to make_map().');
end

data = varargin{1};

if (ndims(data) ~= 2)
    error(['Need a matrix with exactly two dimensions to make a map. Your ' ...
        'input data had ' num2str(ndims(data)) ' dimensions.']);
end

time_string = regexprep(datestr(now, 31), ':', '-');
default_map_scale = max(data(isfinite(data))) * 1.1;

% Set up the defaults
options = struct('map_type', 'linear', ...
                 'title', '', ...
                 'colorbar_title', '', ...
                 'filename', time_string, ...
                 'save', 'on', ...
                 'scale', default_map_scale, ...
                 'scale_div', 8, ...
                 'integer_labels', 'off', ...
                 'state_outlines', 'off', ...
                 'no_background', 'off', ...
                 'state_outline_color', 'k', ...
                 'visibility', 'on', ...
                 'auto_cap', 'off', ...
                 'autolabel', 'off' ...
             );
                 
 
map_size = determine_map_size(size(data));

%% If the options are input as a structure...
if (nargin >= 2 && isstruct(varargin{2}))
    input_options = varargin{2};
    options_names = fieldnames(options);
    input_names = fieldnames(input_options);
    for i = 1:length(input_names)
        pname = input_names{i};
        ind = strcmpi(pname,options_names);
        if isempty(ind)
            error(['invalid parameter: ''' pname '''.']);
        end
        
        % Set the option
        options.(pname) = input_options.(pname);
    end
    
    
else
    %% Process the input options
    parameter_list = {varargin{2:end}};
    if (mod(nargin,2) == 0)
        error('Invalid parameter pairs.');
    end
    % Get the list of valid option names
    options_names = fieldnames(options);
    for i=1:2:length(parameter_list)
        pname = parameter_list{i};
        pvalue = parameter_list{i+1};
        
        % Check to make sure this parameter is part of our list
        ind = strcmpi(pname,options_names);
        if isempty(ind)
            error(['Invalid parameter: ''' pname '''.']);
            % 	elseif length(ind) > 1
            % 		error(['Ambiguous parameter: ''' pname '''.']);
        end
        
        % Set the option
%         options = setfield(options, pname, pvalue);
        options.(pname) = pvalue;
    end
end


switch(options.no_background)
    case 'on',
        is_in_us = get_us_map(map_size);
        if (options.scale == default_map_scale)
            default_scale = 1;
        else
            default_scale = 0;
        end
        data(~is_in_us) = inf;
        
        if (default_scale)
            options.scale = default_map_scale;
        end
end


% If no filename was supplied, use the title (if supplied) instead of the
% default timestamp string
if (~isempty(options.title) && strcmp(options.filename, time_string))
    options.filename = options.title;
end


% Set the automatic labels
if (strcmpi(options.autolabel, 'on'))
    max_capacity = default_map_scale;
    if (max_capacity > 1e9)
        scale = 1e9;
        label = 'Gbps';
    else if (max_capacity > 1e6)
        scale = 1e6;
        label = 'Mbps';
    else if (max_capacity > 1e3)
        scale = 1e3;
        label = 'kbps';
    else
        scale = 1;
        label = 'bps';
    end
    end
    end
    
    data = data / scale;
    options.scale = max_capacity / scale;
    options.colorbar_title = label;
    clear scale label;
end



if (string_is(options.auto_cap, 'on'))
    data(data >= max(options.scale) & ~isinf(data)) = max(options.scale) * 0.98;
end

      

% Choose the map type  
options.map_type = lower(options.map_type);
switch(options.map_type)
    case 'linear',   % y = x
        plot_fcn = inline('x', 'x');
        plot_fcn_inv = inline('y', 'y');
    
    case 'log',     % y = log1p(x)/log(6)
        plot_fcn = inline('log1p(x)/log(6)', 'x');
        plot_fcn_inv = inline('expm1(y*log(6))', 'y');
        
    case 'atan',    % y = atan(x/20)/(pi/2)
        plot_fcn = inline('atan(x/20)/(pi/2)', 'x');
        plot_fcn_inv = inline('tan(y * (pi/2))*20', 'y');
        
    otherwise,      % y = x
        warning(['Invalid map type: ' map_type ' -- defaulting to linear']);
end





% Make the figure
F = figure('visible', options.visibility); hold on;

% Plot the data
imagesc(plot_fcn(data));
colorbar; axis image; axis off;

switch(options.state_outlines)
    case 'on',
        
        % Make sure that we don't mess up the figure when we save it
        % From http://www.mathworks.com/help/techdoc/ref/print.html:
        %   Black and white devices convert colored lines and text to black
        %   or white to provide the best contrast with the background and
        %   to avoid dithering.
        set(gcf, 'color', 'white');
        set(F,'InvertHardcopy','off');
        
        % Plot the state outlines
        load(['state_outlines' map_size '.mat'], 'lats', 'longs');
        patch(longs, lats, 'w', 'linewidth', 1, 'facecolor', 'none', ...
            'edgecolor', options.state_outline_color);
    case 'off', % do nothing
end


% % Put the image in the right place
TI = get(gca,'TightInset');
TI(1) = TI(1) - .01;
TI(2) = TI(2) + .1;
OP = get(gca,'OuterPosition');
Pos = OP + [ TI(1:2), -TI(1:2)-TI(3:4) ];
Pos = Pos * .83;
set( gca,'Position',Pos);

% Set up the colormap
cmap = jet(2^20);
cmap(end, :) = [1 1 1];    % infinity is white
cmap(1, :) = [0 0 0];               % zero is black
colormap(cmap);

% Set up the colormap scale
max_plot_value = max(plot_fcn(options.scale));
% if (max_plot_value > 0)
    caxis([0 max_plot_value]);
% else
%     caxis([-inf max_plot_value]);
% end    

% Label the colorbar
if (length(options.scale) == 1) % scalar input
    if (options.scale_div > 0)
        scale = 0:max_plot_value/(options.scale_div-1):max_plot_value;
    else
        scale = 0;
    end
else                            % vector input
    scale = plot_fcn(options.scale);    
end

if (length(scale) > 1)
    switch(options.integer_labels)
        case 'off',    labels = round(plot_fcn_inv(scale)*10)/10;
        case 'on',     labels = unique(round(plot_fcn_inv(scale)));
    end
    scale = plot_fcn(labels);
    h=colorbar('YTick', scale, 'YTickLabel', {num2str(labels')});
    set(h, 'FontSize', font_size);
end

% Title the colorbar
% cb = colorbar;
colorbar_label = [options.colorbar_title ' '];
% text(675, 160, colorbar_label, 'Units', 'pixels', 'Rotation', 90, 'FontSize', font_size);
yl = ylabel(h, colorbar_label);
set(yl, 'FontSize', font_size, 'FontName', font_name);
set(h, 'FontSize', font_size, 'FontName', font_name);

options.save = lower(options.save);
switch(options.save)
    case 'on',
        save_plot('png', options.filename);
        display(['Saving ' options.filename '...']);
        
    case 'off',
        t = title(options.title);
        set(t, 'FontSize', font_size);
    otherwise,
        error(['Invalid save option: ' options.save]);
end

% display(['Figure ' num2str(F) ': ' options.title]);
set(F, 'OuterPosition', [440   296   809   555]);


end


% function [scale_val] = get_scale(data)
% 
% max_val = get_max_val(data);
% 
% % if (max_val < 1e3)
% %     scale_val = max_val + 1;
% % else
%     scale_val = max_val * 1.1;
% % end
% 
% 
% % max(data(isfinite(data)))*1.5;
% 
% 
% end






% function [] = save_plot( format, plot_filename )
% %SAVE_PLOT Saves the plot with the given filename and format.
% %
% %   [  ] = save_plot( format, plot_filename )
% %
% %   format - (vector/eps) or (bitmap/jpeg)
% %   plot_filename - The desired filename (omit extensions).
% 
% format = lower(format);
% 
% load 'plot_parameters.mat'
% 
% xlhand = get(gca,'xlabel');
% set(xlhand, 'fontsize',font_size);
% ylhand = get(gca,'ylabel');
% set(ylhand, 'fontsize',font_size);
% 
% 
% switch(format)
%     case {'png'}
%         print('-dpng', ['Output/' plot_filename '.png']);
%     case {'vector', 'eps'},
%         print('-depsc', ['Output/' plot_filename '.eps']);
%         
%     case {'bitmap', 'jpeg'},
%         print('-djpeg', ['Output/' plot_filename '.jpeg']);
% end
% 
% end