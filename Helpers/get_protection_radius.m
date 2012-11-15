function [ rp ] = get_protection_radius( tx_power_W, chan_no, haat, fade_margin, noise_level )
%GET_PROTECTION_RADIUS Finds the protection radius for a tower with the
%given characteristics. NOTE that this function makes assumptions about
%sigma, prob_time, prob_loc, w_mpath, K_dB (defined in get_E).
%
%   [ rp ] = get_protection_radius( tx_power_W, chan_no, haat, fade_margin, noise_level )
%
%   tx_power_W = transmission power (ERP) of the tower (in Watts)
%   chan_no = channel number for transmission
%   HAAT = height above average terrain for tower (in meters)
%   fade_margin = fade margin in dB
%   noise_level = ambient noise in W
%
%   rp = protection radius for the tower

error('This function is buggy. Please switch to get_AD_protection_radius.m.');


% Make some assumptions about our path loss model
sigma = 5.5;        % Frequency variation in meters
prob_time = 0.9;
prob_loc = 0.5;
with_mpath = 0;     % 0 = without multipath fading; 1 = with
K_dB = 6;           % value of gain for Ricean multipath in dB


% P_t
% EIRP_W = tx_power_W * 10^(2.15/10); % Add 2.15 dB to obtain isotropic radiated power
ERP_kW = tx_power_W/1e3;   % in kW

noise_level_dBm = get_W_to_dBm(noise_level);

% Delta
target_SINR_dB = 15;    % This is the reception threshold for TV


target_power_in_dBm = fade_margin + noise_level_dBm + target_SINR_dB;
target_power_in_dBu = get_dBm_to_dBu(target_power_in_dBm, chan_no);


% Compute the protection radius
rp = get_rp(ERP_kW, chan_no, haat, sigma, target_power_in_dBu, prob_time, prob_loc, with_mpath, K_dB);


end

