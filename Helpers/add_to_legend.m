function [] = add_to_legend(plot_handle, string)
%   [] = add_to_legend(plot_handle, string)
%
%   plot_handle = the handle to the plot (e.g. the return value from
%       plot()); this is not to be confused with the figure handle
%   string = the string to be used in the legend
%
%   Gratefully stolen from
%   http://www.mathworks.com/support/solutions/en/data/1-181SJ/?solution=1-181SJ

if (plot_handle == 0)
    plot_handle = max(get(gca,'Children'));
end

% if LEGEND is not created in the figure, create default legend:
legend('show')

% Get object handles
[dummy1,dummy2,OUTH,OUTM] = legend;

% Add object with new handle and new legend string to legend
legend([OUTH;plot_handle],OUTM{:},string)

end