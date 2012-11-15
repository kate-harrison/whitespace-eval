function [] = make_area_graph(type, varargin)
%   [] = make_area_graph(type, varargin)
%
%   Plots the data given in varargin as an area graph. If type == 'add', it
%   makes a stacked graph instead.
%
%
%   EXAMPLES:
%     Set:       x = 1:10; y1 = rand(size(x)); y2 = rand(size(x));
%
%     Plot (x,y1) and (x,y2) as area graphs with (x,y1) in front of (x,y2):
%       make_area_graph('', {x, y1}, {x, y2})
%
%
%     Plot (x,y1) and (x,y2) as a stacked graph with (x,y1) in front of (x,y2):
%       make_area_graph('add', {x, y1}, {x, y2})
%
%
%     Label the plots for (x,y1) and (x,y2):
%       make_area_graph('add', {x, y1, 'Data 1'}, {x, y2, 'Data 2'})
%
%
%     Specify the colors for (x,y1) and (x,y2):
%       make_area_graph('add', {x, y1, 'Data 1', 'b'}, {x, y2, 'Data 2', 'r'})


if (nargin < 2)
    error('No input data');
end

labels = {};
running_total = 0;


figure; hold all;
colors = jet(nargin-1);
% colors = get(0,'DefaultAxesColorOrder');
for i = 1:nargin-1
    if (iscell(varargin{i}))
        if (length(varargin{i}) >= 2)
            x_data = varargin{i}{1};
            y_data = varargin{i}{2};
        else

            error(['Not enough inputs for data set ' num2str(i)]);
        end
        
        if (length(varargin{i}) >= 3)
            labels{i} = varargin{i}{3};
        else
            labels{i} = '';
        end
        
        
        if (length(varargin{i}) >= 4)
            facecolor = varargin{i}{4};
        else
            facecolor = colors(i,:);
        end
    else
        varargin{i}
    end
    
    h(i) = area(x_data, y_data + running_total, 'facecolor', facecolor, ...
        'edgecolor', 'k', 'linewidth', 1.25);
    
    if (string_is(type, 'add'))
        running_total = running_total + y_data;
    end

end

for i = nargin-1:-1:1
    uistack(h(i), 'top');
end


grid on;
set(gca,'Layer','top')
    
if ~all(string_is(labels, ''))
    ax = axis;
    axis([ax(1:3) (1+.03*nargin)*ax(4)]);
    legend(labels, 'location', 'best');
end


end