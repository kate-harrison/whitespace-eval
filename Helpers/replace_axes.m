function [] = replace_axes(axis, scale, scale_text, varargin)
%   [] = replace_axes(axis, scale, scale_text, [large_font])
%
%   Adjusts the tickmarks on [axis] ('x' or 'y') to [scale] with
%   corresponding labels [scale_text]. If a third argument is provided
%   (regardless of value), sets the font to a larger, printable size.

switch(lower(axis))
    case {'x'}, modify = 'xtick'; label = 'xticklabel';
    case {'y'}, modify = 'ytick'; label = 'yticklabel';
    otherwise, error(['Unknown option: ' axis ' (must be ''x'' or ''y'')']);
end

if (scale_text(end)/scale_text(1) > 999) % log scale
% display('log scale');
    if (log10(scale_text) ~= round(log10(scale_text))) % if not powers of 10
    a = round(log10(scale_text(1)));
    b = round(log10(scale_text(end)));
    exponents = unique(round(linspace(a,b,5)));
    set(gca, modify, 10.^exponents);
    else
        
        set(gca, modify, scale, label, {num2str(scale_text')});
    end

else    % linear scale
%     set(gca, modify, scale, label, n);
    set(gca, modify, scale, label, {num2str(scale_text')});
end


if (nargin > 3)
    load('plot_parameters');
else
    font_size = 10;
end

set(gca, 'fontsize', font_size);


end