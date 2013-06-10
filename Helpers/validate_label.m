function [] = validate_label(label)
%   [] = validate_label(label)
%
%   Checks the fields to make sure they're valid (according to filename
%   guide documentation)
%
%   See also: generate_label, get_simulation_value, validate_flags


switch(label.label_type)
    case 'capacity',
        validate_capacity_label(label);
    case 'ccdf_points',
        validate_ccdf_points_label(label);
    case 'char',
        validate_char_label(label);
    case 'fcc_mask',
        validate_fcc_mask_label(label);
    case 'fm_mask',
        validate_fm_mask_label(label);
    case 'jam',
        validate_jam_label(label);
    case 'hex',
        validate_hex_label(label);
    case 'mac_table',
        validate_mac_table_label(label);
    case 'noise',
        validate_noise_label(label);
    case 'pl_squares',
        validate_pl_squares_label(label);
    case 'population',
        validate_population_label(label);
    case 'region_areas',
        validate_region_areas_label(label);
    case 'region_mask',
        validate_region_mask_label(label);
    case 'region_outline',
        validate_region_outline_label(label);
    case 'none',
    otherwise,
        accepted_values = get_simulation_value('labels');
        error(['Invalid label type: ' label.label_type '. Accepted types: ' accepted_values]);    
end


end








% -------------------------------------------------------------------------
%     CAPACITY
% -------------------------------------------------------------------------
function [] = validate_capacity_label(capacity_label)
% 	[] = validate_capacity_label(capacity_label)

validate_flags('capacity', 'capacity_type', capacity_label.capacity_type);
validate_flags('capacity', 'range_type', capacity_label.range_type);
validate_flags('capacity', 'range_value', str2double(capacity_label.range_value));
validate_flags('capacity', 'population_type', capacity_label.population_type);
validate_label(capacity_label.char_label);
validate_label(capacity_label.noise_label);
switch(lower(capacity_label.cell_model_label.label_type))
    case {'mac_table', 'hex', 'none'}   % Do nothing
    otherwise
        error(['Invalid cell model label: ' capacity_label.cell_model_label.label_type]);
end
validate_label(capacity_label.cell_model_label);

end

% -------------------------------------------------------------------------
%     CCDF points
% -------------------------------------------------------------------------
function [] = validate_ccdf_points_label(ccdf_points_label)
%   [] = validate_ccdf_points_label(ccdf_points_label)

validate_flags('ccdf_points', 'variable', ccdf_points_label.variable);
validate_flags('ccdf_points', 'mask_type', ccdf_points_label.mask_type);
validate_label(ccdf_points_label.capacity_label);

end


% -------------------------------------------------------------------------
%     CHAR(acteristics)
% -------------------------------------------------------------------------
function [] = validate_char_label(char_label)
%   [] = validate_char_label(char_label)

validate_flags('char', 'height', str2double(char_label.height));
validate_flags('char', 'power', str2double(char_label.power));

end


% -------------------------------------------------------------------------
%     FCC mask
% -------------------------------------------------------------------------
function [] = validate_fcc_mask_label(fcc_mask_label)
%   [] = validate_fcc_mask_label(fcc_mask_label)

validate_flags('fcc_mask', 'device_type', fcc_mask_label.device_type);
validate_flags('fcc_mask', 'map_size', fcc_mask_label.map_size);
validate_flags('fcc_mask', 'apply_wireless_mic_exclusions', ...
    fcc_mask_label.apply_wireless_mic_exclusions);

end


% -------------------------------------------------------------------------
%     F(ade) M(argin) mask
% -------------------------------------------------------------------------
function [] = validate_fm_mask_label(fm_mask_label)
%   [] = validate_fm_mask_label(fm_mask_label)

validate_flags('fm_mask', 'device_type', fm_mask_label.device_type);
validate_label(fm_mask_label.char_label);

end


% -------------------------------------------------------------------------
%     JAM model
% -------------------------------------------------------------------------
function [] = validate_jam_label(jam_label)
%   [] = validate_jam_label(jam_label)


validate_flags('jam', 'stage', jam_label.stage);
validate_flags('jam', 'model', jam_label.model);
validate_flags('jam', 'power_type', jam_label.power_type);
validate_flags('jam', 'population_type', jam_label.population_type);
validate_flags('jam', 'tower_data_year', jam_label.tower_data_year);
validate_flags('jam', 'tax', jam_label.tax);
validate_flags('jam', 'p', jam_label.p);

validate_label(jam_label.char_label);

end



% -------------------------------------------------------------------------
%     HEX(agon) cell model
% -------------------------------------------------------------------------
function [] = validate_hex_label(hex_label)
%   [] = validate_hex_label(hex_label)

validate_flags('hex', 'type', hex_label.type);
validate_label(hex_label.char_label);

end


% -------------------------------------------------------------------------
%     MAC table
% -------------------------------------------------------------------------
function [] = validate_mac_table_label(mac_table_label)
%   [] = validate_mac_table_label(mac_table_label)

validate_flags('mac_table', 'channels', mac_table_label.channels);
validate_label(mac_table_label.char_label);

end


% -------------------------------------------------------------------------
%     NOISE
% -------------------------------------------------------------------------
function [] = validate_noise_label(noise_label)
%   [] = validate_noise_label(noise_label)

validate_flags('noise', 'cochannel', noise_label.cochannel);
validate_flags('noise', 'map_size', noise_label.map_size);
validate_flags('noise', 'channels', noise_label.channels);
validate_flags('noise', 'leakage_type', noise_label.leakage_type);

end


% -------------------------------------------------------------------------
%     PL_SQUARES
% -------------------------------------------------------------------------
function [] = validate_pl_squares_label(pl_squares_label)
%   [] = validate_noise_label(noise_label)

validate_flags('pl_squares', 'type', pl_squares_label.type);
validate_flags('pl_squares', 'width', pl_squares_label.width);
validate_flags('pl_squares', 'p', pl_squares_label.p);
validate_flags('pl_squares', 'population_type', pl_squares_label.population_type);
validate_flags('pl_squares', 'map_size', pl_squares_label.map_size);
validate_label(pl_squares_label.char_label);

end


% -------------------------------------------------------------------------
%     POPULATION
% -------------------------------------------------------------------------
function [] = validate_population_label(population_label)
%   [] = validate_population_label(population_label)

validate_flags('population', 'type', population_label.type);
validate_flags('population', 'population_type', population_label.population_type);
validate_flags('population', 'map_size', population_label.map_size);

end


% -------------------------------------------------------------------------
%     REGION_AREAS
% -------------------------------------------------------------------------
function [] = validate_region_areas_label(region_areas_label)
%   [] = validate_region_areas_label(region_areas_label)

validate_flags('region_areas', 'map_size', region_areas_label.map_size);
validate_flags('region_areas', 'type', region_areas_label.type);

end


% -------------------------------------------------------------------------
%     REGION_MASK
% -------------------------------------------------------------------------
function [] = validate_region_mask_label(region_mask_label)
%   [] = validate_region_mask_label(region_mask_label)

validate_flags('region_mask', 'map_size', region_mask_label.map_size);

end


% -------------------------------------------------------------------------
%     REGION_OUTLINE
% -------------------------------------------------------------------------
function [] = validate_region_outline_label(region_outline_label)
%   [] = validate_region_outline_label(region_outline_label)

validate_flags('region_outline', 'map_size', region_outline_label.map_size);

end
