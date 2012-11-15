function [eirp] = get_erp_to_eirp(erp)

eirp = erp * 10^(2.15/10);

end