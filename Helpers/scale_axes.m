function [] = scale_axes(axis, scale, varargin)
%   [] = scale_axes(axis, scale, [large_font])
%
%   Adjusts the tickmarks on [axis] ('x' or 'y') to [scale]. If a third
%   argument is provided (regardless of value), sets the font to a larger,
%   printable size.

switch(lower(axis))
    case {'x'}, modify = 'xtick'; %label = 'xticklabel';
    case {'y'}, modify = 'ytick'; %label = 'yticklabel';
    otherwise, error(['Unknown option: ' axis ' (must be ''x'' or ''y'')']);
end

if (scale(end)/scale(1) > 999) % log scale

    if (log10(scale) ~= round(log10(scale))) % if not powers of 10
    a = round(log10(scale(1)));
    b = round(log10(scale(end)));
    exponents = unique(round(linspace(a,b,5)));
    set(gca, modify, 10.^exponents);
    else
        set(gca, modify, scale);
    end

else    % linear scale
    set(gca, modify, scale);
%     set(gca, modify, scale, label, {num2str(scale')});
end


if (nargin > 2)
    load('plot_parameters');
else
    font_size = 10;
end

set(gca, 'fontsize', font_size);


end