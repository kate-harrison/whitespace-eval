function [] = make_char(char_label)
%   [] = make_char(char_label)

switch(char_label.label_type)
    case 'char',
    otherwise,
        error(['Unsupported mode: tried to run make_char() with ' ...
            'label of type ' char_label.label_type]);
end

% If we don't need to compute, exit now
if (get_compute_status(char_label) == 0)
    return;
end

height = char_label.height;
power = char_label.power;


save_data(save_filename(char_label), 'height', 'power');


end