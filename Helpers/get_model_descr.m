function [str] = get_model_descr(model_num)
%   [str] = get_model_descr(model_num)
%
%   Outputs a text description of the jam model (e.g. 'Hotspot rules,
%   cellular usage').


switch(model_num)
    case 1, str = 'Hotspot rules, cellular usage';
    case 2, str = 'Hotspot rules, hotspot usage';
    case 3, str = 'Cellular rules, cellular usage';
    case 4, str = 'Cellular rules, hotspot usage';
end

end