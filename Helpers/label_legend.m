function [] = label_legend(label)
%   [] = label_legend(label)
%
% Labels the current legend.

hl = findobj(gcf,'Tag','legend');
hl_t = get(hl,'Title');
set(hl_t,'String',label);

end