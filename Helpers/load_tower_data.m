function [chan_data chan_no_idx lat_idx long_idx haat_idx erp_idx fcc_rp_idx dist_th_idx] = load_tower_data(tower_data_year)
%   [chan_data chan_no_idx lat_idx long_idx haat_idx erp_idx fcc_rp_idx dist_th_idx] 
%           = load_tower_data(tower_data_year)
%
%   This function is deprecated. Use get_tower_data.m instead.
%
%   See also: get_tower_data


warning('Use fuction load_chan_data() instead.');

switch(tower_data_year)
    case '2011',
        load([get_simulation_value('data_dir') '/chan_data2011.mat']);
        % Variables within
        %   chan_data	<8705x7 double>
        % 	chan_no_idx	1
        % 	lat_idx	2
        % 	long_idx	3
        % 	haat_idx	4
        % 	erp_idx	5
        % 	dist_th_idx	6
        % 	fcc_rp_idx	7
%     case '2008',
%         load 'chan_data_extra.mat'
%         % Variables within
%         % 	amsl_idx	7
%         % 	asrn_idx	3
%         % 	chan_data	<8071x10 double>
%         % 	chan_no_idx	1
%         % 	dist_th_idx	9
%         % 	erp_idx	8           % kw
%         % 	fac_id_idx	2
%         % 	fcc_rp_idx	10
%         % 	haat_idx	6       % m
%         % 	lat_idx	4
%         % 	long_idx	5
    otherwise,
        error('Bad tower data year');
end


end