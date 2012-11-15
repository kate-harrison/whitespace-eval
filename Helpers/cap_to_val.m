function [data] = cap_to_val(data, val)

idcs = (data > val) & isfinite(data);
data(idcs) = val;



end