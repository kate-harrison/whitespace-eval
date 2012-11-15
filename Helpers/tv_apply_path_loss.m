function [ output_power ] = tv_apply_path_loss( input_power, channel_number, haat, distance )
%APPLY_PATH_LOSS Calculates the resulting power when the path loss is taken
%into account.
%
%   [ output_power ] = tv_apply_path_loss( input_power, channel_number, haat, distance )
%
%   input_power = Power (without path loss) in Watts
%   channel_number = The TV channel being used for transmission
%   haat = Height above average terrain for the transmitter (meters)
%   distance = Distance from the transmitter (kilometers)
%
%   output_power = Power after path loss in Watts

% Assume the following things...
sigma = 5.5;    % Frequency variation in meters
prob_time = 0.9;
prob_loc = 0.5;
with_mpath = 0; % Without multipath fading
K_dB = 6;       % Arbitrary, more or less


% Use instead of get_path_loss(...) to decrease error
% Usage E = get_E(erp, chan_no, tx_height, sigma, target_dist, prob_time, prob_loc, with_mpath, K_dB)
% E = get_E(...)

E = get_E( input_power/1000, channel_number, haat, sigma, distance, prob_time, ...
    prob_loc, with_mpath, K_dB);
% Translate from dBu to dBm
% get_dBu_to_dBm(E, chan_no)
dBm = get_dBu_to_dBm(E, channel_number);
output_power = get_dBm_to_W(dBm);


end

