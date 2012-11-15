function [erp] = get_eirp_to_erp(eirp)

erp = eirp/(10^(2.15/10));

end