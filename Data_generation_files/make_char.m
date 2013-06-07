function [] = make_char(char_label)
%   [] = make_char(char_label)


% If we don't need to compute, exit now
if (get_compute_status(char_label) == 0)
    return;
end

height = char_label.height;
power = char_label.power;


save_data(save_filename(char_label), 'height', 'power');


end