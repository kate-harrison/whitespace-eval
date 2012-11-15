% What clean SNR do we get at rp for each TV transmitter?

clc; clear all; close all;

% TNP = get_simulation_value('TNP');
% load('chan_data_extra');
% % Variables within
% % 	amsl_idx	7
% % 	asrn_idx	3
% % 	chan_data	<8071x10 double>
% % 	chan_no_idx	1
% % 	dist_th_idx	9
% % 	erp_idx	8           % kw
% % 	fac_id_idx	2
% % 	fcc_rp_idx	10
% % 	haat_idx	6       % m
% % 	lat_idx	4
% % 	long_idx	5
% 
% num_tx = size(chan_data, 1);
% SNRs = zeros(1, num_tx);
% 
% for i = 1:num_tx
%     if (mod(i,1000) == 0)
%         i
%     end
%     tv_power = chan_data(i, erp_idx) * 1e3;  % convert from kW to W
%     tv_haat = chan_data(i, haat_idx);
%     tv_rp = chan_data(i, fcc_rp_idx);
%     channel = chan_data(i, chan_no_idx);
%     
%     SNRs(i) = 10*log10(tv_apply_path_loss(tv_power, channel, tv_haat, tv_rp)/TNP);
%     
% end
% 
% save('tv_snrs_at_rp.mat');

close all;
load('tv_snrs_at_rp.mat');
figure; plot(SNRs, '.');
title('SNRs');

figure; plot(chan_data(:, chan_no_idx), '.');
title('Channels');

figure; plot(chan_data(:, erp_idx)*1e3, '.');
title('Power (W)');

figure; plot(chan_data(:, haat_idx), '.');
title('Height (m)');

figure; plot(chan_data(:, fcc_rp_idx), '.');
title('FCC r_p (km)');