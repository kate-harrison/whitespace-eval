function [ filename ] = generate_filename( label )
% [ filename ] = generate_filename( label )
% Generates the filename based on the label

if (ischar(label))
    filename = label;
    return;
end

switch(label.label_type)
    case 'capacity',
        filename = generate_capacity_filename(label);
    case 'ccdf_points',
        filename = generate_ccdf_points_filename(label);
    case 'char',
        filename = generate_char_filename(label);
    case 'fcc_mask',
        filename = generate_fcc_mask_filename(label);
    case 'fm_mask',
        filename = generate_fm_mask_filename(label);
    case 'jam',
        filename = generate_jam_filename(label);
    case 'hex',
        filename = generate_hex_filename(label);
    case 'mac_table',
        filename = generate_mac_table_filename(label);
    case 'noise',
        filename = generate_noise_filename(label);
    case 'pl_squares',
        filename = generate_pl_squares_filename(label);
    case 'region_outline',
        filename = generate_region_outline_filename(label);
    case 'none',
        filename = 'none';
        
end



end


% -------------------------------------------------------------------------
%     CAPACITY
% -------------------------------------------------------------------------
function [capacity_filename] = generate_capacity_filename( capacity_label )
%   [capacity_filename] = generate_capacity_filename( capacity_label )

% Generate the other parts of the filename
mac_table_filename = generate_filename(capacity_label.cell_model_label);
char_filename = generate_filename(capacity_label.char_label);
noise_filename = generate_filename(capacity_label.noise_label);

% Generate the filename itself
capacity_filename = ['CAPACITY type=' capacity_label.capacity_type ' ' ...
    capacity_label.range_type '=' num2str(capacity_label.range_value) ...
    ' pop_type=' capacity_label.population_type ' (' char_filename ') (' ...
    noise_filename ') (' mac_table_filename ')'];

end


% -------------------------------------------------------------------------
%     CCDF points
% -------------------------------------------------------------------------
function [filename] = generate_ccdf_points_filename(ccdf_points_label)
%   [filename] = generate_ccdf_points_label(ccdf_points_label)

capacity_filename = generate_filename(ccdf_points_label.capacity_label);
filename = ['CCDF_POINTS variable=' ccdf_points_label.variable ' mask_type=' ...
    ccdf_points_label.mask_type ' (' capacity_filename ')'];

end


% -------------------------------------------------------------------------
%     CHAR(acteristics)
% -------------------------------------------------------------------------
function [filename] = generate_char_filename(char_label)
%   [filename] = generate_char_label(char_label)

filename = ['CHAR height=' num2str(char_label.height) ' power=' num2str(char_label.power)];

end


% -------------------------------------------------------------------------
%     FCC mask
% -------------------------------------------------------------------------
function [filename] = generate_fcc_mask_filename(fcc_mask_label)
%   [filename] = generate_mask_label(fcc_mask_label)

filename = ['FCC_MASK device_type=' fcc_mask_label.device_type ' map_size=' fcc_mask_label.map_size];


end


% -------------------------------------------------------------------------
%     F(ade) M(argin) mask
% -------------------------------------------------------------------------
function [filename] = generate_fm_mask_filename(fm_mask_label)
%   [filename] = generate_mask_filename(fm_mask_label)

if (regexpi(fm_mask_label.device_type, 'cr'))   % CR of any type
    char_filename = generate_filename(fm_mask_label.char_label);
else
    char_filename = 'none';
end
filename = ['FM_MASK device_type=' fm_mask_label.device_type ' map_size=' fm_mask_label.map_size ...
    ' margin_value=' num2str(fm_mask_label.margin_value) ' (' char_filename ')'];
end


% -------------------------------------------------------------------------
%     JAM model
% -------------------------------------------------------------------------
function [filename] = generate_jam_filename(jam_label)
%   [filename] = generate_jam_filename(jam_label)

if (jam_label.model ~= 0)
    jam_label.char_label.power = 0;
end
char_filename = generate_filename(jam_label.char_label);

switch(jam_label.stage)
    case {'chan_data', 'power_map'},
        % Models 1 and 2 are the same at chan_data, power_map stages
        % Models 3 and 4 ...
        switch(jam_label.model)
            case {0},       p = jam_label.p;
            case {1,2},     jam_label.model = 1;
                            p = 0;
            case {3,4},     jam_label.model = 3;
                            p = jam_label.p;
            case {5},       p = jam_label.p;
        end
        
        switch(jam_label.hybrid)
            case true,      p = jam_label.p1;     % Hybrid uses p1 for the chan_data, power_map stages
            case false,     % nothing
        end
        
        
        p_string = num2str(p);
        jam_label.power_type = 'none';
        
    
%     case 'power_map',
        
    case 'rate_map',
        switch(jam_label.hybrid)
            case true,
                p_string = jam_label.p_string;
            case false,
                p_string = num2str(jam_label.p);
        end
        
        
end




noise_filename = generate_filename(jam_label.noise_label);


filename = ['JAM ' jam_label.stage ' model=' num2str(jam_label.model) ...
    ' power=' jam_label.power_type ' tax=' num2str(jam_label.tax) ...
    ' p=' p_string ' pop_type=' jam_label.population_type ...
    ' tower_year=' jam_label.tower_data_year ...
    ' (' char_filename ') (' noise_filename ')'];

end


% -------------------------------------------------------------------------
%     HEX(agon) cell model
% -------------------------------------------------------------------------
function [filename] = generate_hex_filename(hex_label)
%   [filename] = generate_hex_filename(hex_label)

% switch(hex_label.label_type)
%     case 'none', filename = 'none';
%     otherwise,
        char_filename = generate_filename(hex_label.char_label);
        filename = ['HEX type=' hex_label.type ' (' char_filename ')'];
% end

end


% -------------------------------------------------------------------------
%     MAC table
% -------------------------------------------------------------------------
function [filename] = generate_mac_table_filename(mac_table_label)
%   [filename] = generate_mac_table_filename(mac_table_label)

% switch(mac_table_label.label_type)
%     case 'none', filename = 'none';
%     otherwise,
        char_filename = generate_filename(mac_table_label.char_label);
        filename = ['MAC_TABLE channels=' mac_table_label.channels ' (' char_filename ')'];
% end

end


% -------------------------------------------------------------------------
%     NOISE
% -------------------------------------------------------------------------
function [filename] = generate_noise_filename( noise_label )
%   [filename] = generate_noise_filename( noise_label )

filename = ['NOISE cochannel=' noise_label.cochannel ' size=' noise_label.map_size ...
    ' channels=' noise_label.channels ' leakage=' noise_label.leakage_type];

end


% -------------------------------------------------------------------------
%     PL_SQUARES
% -------------------------------------------------------------------------
function [filename] = generate_pl_squares_filename( pl_squares_label )
%   [filename] = generate_pl_squares_filename( pl_squares_label )

filename = ['PL_SQUARES type=' pl_squares_label.type ' width=' ...
    num2str(pl_squares_label.width) ' p=' num2str(pl_squares_label.p) ...
    ' pop_type=' pl_squares_label.population_type ...
    ' size=' pl_squares_label.map_size ' (' ...
    generate_filename(pl_squares_label.char_label) ')'];

end


% -------------------------------------------------------------------------
%     REGION_OUTLINE
% -------------------------------------------------------------------------
function [filename] = generate_region_outline_filename( region_outline_label )
%   [filename] = generate_region_outline_filename( region_outline_label )

filename = ['REGION_OUTLINE map_size=' region_outline_label.map_size];

end



