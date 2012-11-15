function [ r ] = get_rn_minus_rp( erp, chan_no, haat, erosion_margin, baseline_noise )
%GET_RN_MINUS_RP Given a transmitter and its characteristics, what is its
%r_n - r_p? PLEASE NOTE THE UNITS.
%
%   [ r ] = get_rn_minus_rp( erp, chan_no, haat, erosion_margin,
%   baseline_noise )
%
%   ERP = effective radiated power (in kW)
%   chan_no = channel number the tower is transmitting on
%   HAAT = the tower's height above average terrain (in m)
%   target_power = the "given power" mentioned above (in W) (may be a
%   vector)
%   erosion_margin = in dB
%   baseline_noise = thermal noise power in W (for now we load it in)
%
%   r = distance from the transmitter (in km)
%
% This function makes assumptions about the values of prob_time, prob_loc,
% with_mpath, and K_dB (for explanations of these variables, refer to the
% function get_E).
% This is the path loss inverse function ln^(-1)


erosion_percentage = 10^(erosion_margin/10);
if (erosion_percentage <= 1)
    r = inf;
    return;
end

r = get_effective_radius(erp, chan_no, haat, baseline_noise*(erosion_percentage - 1));


end

