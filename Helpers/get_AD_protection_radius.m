function [rp] = get_AD_protection_radius(power, channel, haat, AD, varargin)
%   [rp] = get_AD_protection_radius(power, channel, haat, AD, [fade_margin], [noise_level])
%
% Required arguments:
%   power - transmitter power in Watts
%   channel - transmitter channel (in [2,69])
%   haat - transmitter HAAT in meters
%   AD - analog vs. digital TV station ('A' vs. 'D')
%   
% Optional arguments (if none provided, uses FCC method):
%   fade_margin - fade margin in dB
%   noise_level - ambient noise in Watts (default: thermal noise)
%
% NOTE:
%   4 inputs => uses FCC method
%   5 inputs => fade margin method


% Convert to uppercase for consistency
AD = upper(AD);

% Digital TV stations are protected using the F(50,90) curves
% Analog TV stations are protected using the F(50,50) curves
switch(AD)
    case 'D', prob_time = 0.9;
    case 'A', prob_time = 0.5;
    otherwise, error(['Invalid input: ' AD]);
end
prob_loc = 0.5;

% Make some assumptions about our path loss model
sigma = 5.5;        % Frequency variation in meters
with_mpath = 0;     % 0 = without multipath fading; 1 = with
K_dB = 6;           % value of gain for Ricean multipath in dB

if (nargin == 6)
    noise_level = varargin{2};
else
    noise_level = get_simulation_value('TNP');
end
noise_level_dBm = get_W_to_dBm(noise_level);



% Set target power in dBu
if (nargin <= 4)     % Use defaults (FCC method)
    in_range = @(a,b,c)(a <= b & b <= c);
    switch(AD)
        case 'D',
            if in_range(2,channel,6)
                contour_dBu = 28;
            elseif in_range(7,channel,13)
                contour_dBu = 36;
            elseif in_range(14,channel,69)
                contour_dBu = 41;
            else
                error(['Channel out of range: ' num2str(channel)]);
            end
        case 'A',
            if in_range(2,channel,6)
                contour_dBu = 47;
            elseif in_range(7,channel,13)
                contour_dBu = 56;
            elseif in_range(14,channel,69)
                contour_dBu = 64;
            else
                error(['Channel out of range: ' num2str(channel)]);
            end
    end
else                % Calculate (fade margin method)
    fade_margin = varargin{1};
    target_SINR_dB = get_simulation_value('target_TV_SNR');
    target_power_in_dBm = fade_margin + noise_level_dBm + target_SINR_dB;
    contour_dBu = get_dBm_to_dBu(target_power_in_dBm, channel);
end



power_kW = power / 1e3;


rp = get_rp(power_kW, channel, haat, sigma, contour_dBu, prob_time, prob_loc, with_mpath, K_dB);
