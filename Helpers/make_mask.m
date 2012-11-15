function [] = make_mask(label)
%   [] = make_mask(label)

switch(label.label_type)
    case 'fcc_mask',
        make_fcc_mask(label);
    case 'fm_mask',
        make_fm_mask(label);
end
end