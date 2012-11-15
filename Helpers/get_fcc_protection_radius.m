function [ rp ] = get_fcc_protection_radius( tx_power_W, chan_no, haat )
%GET_FCC_PROTECTION_RADIUS Finds the protection radius for a tower with the
%given characteristics. NOTE that this function makes assumptions about
%sigma, prob_time, prob_loc, w_mpath, K_dB (defined in get_E).
%
%   [ rp ] = get_protection_radius( tx_power_W, chan_no, haat )
%
%   tx_power_W = transmission power (ERP) of the tower (in Watts)
%   chan_no = channel number for transmission
%   haat = height above average terrain for tower (in meters)
%
%   rp = radius of protection for the tower

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

% N_0
% Find the thermal noise power
% load 'TNP.mat'
TNP = get_simulation_value('TNP');

% Delta
% target_power_in_dBu = get_ATSC_target_E(chan_no);    % This is the reception threshold for TV
% New way
target_power_in_dBu = get_ATSC_target_E_FCC08_260(chan_no);


% Compute the protection radius
rp = get_rp(ERP_kW, chan_no, haat, sigma, target_power_in_dBu, prob_time, prob_loc, with_mpath, K_dB);


end

