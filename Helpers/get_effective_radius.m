function [ r ] = get_effective_radius( erp, chan_no, haat, target_power )
%GET_EFFECTIVE_RADIUS Given a transmitter and its characteristics, at what
%point is it below a given power? PLEASE NOTE THE UNITS.
%
%   [ r ] = get_effective_radius( erp, chan_no, haat, target_power )
%
%   ERP = effective radiated power (in kW)
%   chan_no = channel number the tower is transmitting on
%   HAAT = the tower's height above average terrain (in m)
%   target_power = the "given power" mentioned above (in W) (may be a
%   vector)
%
%   r = distance from the transmitter (in km)
%
% This function makes assumptions about the values of prob_time, prob_loc,
% with_mpath, and K_dB (for explanations of these variables, refer to the
% function get_E).
% This is the path loss inverse function ln^(-1)

% display(['Warning: get_effective_radius.m uses the F(50,50) curves -- '...
%     'is this appropriate for your application?']);
% beep

P_dBm = get_W_to_dBm(target_power);
E_dBu = get_dBm_to_dBu(P_dBm, chan_no);


% eirp = erp*10^(2.15/10);    % Add 2.15 dB
sigma = 5.5;
target_fs = E_dBu;
prob_time = 0.5;
prob_loc = 0.5;
with_mpath = 0;
K_dB = 6;

r = get_rp(erp, chan_no, haat, sigma, target_fs, prob_time, prob_loc, with_mpath, K_dB);


end
