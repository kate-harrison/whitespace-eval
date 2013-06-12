function [power_map adj_restrictions] = apply_power_map_exclusions(power_map)
%   function [power_map adj_restrictions] = apply_power_map_exclusions(power_map)


chan_list = get_simulation_value('chan_list');

dB_leak = get_simulation_value('dB_leak');
boost = 10^(dB_leak/10);

% Make sure that the power map is 0 within r_p (technically this is a map
% of places where TV is received under the FCC rules, but those are
% equivalent to areas inside of r_p; adjacent channel exclusions are
% enforced below)
%   Actually, this is done just before this function is called but we do it
%   again below just to be sure -- nevermind, there's no point
% adj_restrictions = fcc_cochannel_only_excl_mask * 0; % Keep track of where we're restricted just on the adjacent channels
% power_map = power_map .* fcc_cochannel_only_excl_mask;   % zero out those places we are always disallowed (cochannel inside r_p)


adj_restrictions = zeros(size(power_map));
power_map_adj = power_map * boost;

ones_map = ones(size(power_map(1,:,:)));

for i = 1:length(chan_list)
    up = has_frequency_neighbor(i, 'up');
    down = has_frequency_neighbor(i, 'down');
    
    if (up)
        up_map = power_map_adj(i+1,:,:);
    else
        up_map = inf * ones_map;
    end
    
    if (down)
        down_map = power_map_adj(i-1,:,:);
    else
        down_map = inf * ones_map;
    end
    
    min_map = cat(1, power_map(i,:,:), up_map, down_map);
    
    [Y,I] = min(min_map, [], 1);
    power_map(i,:,:) = squeeze(Y);
    
    adj_restrictions(i,:,:) = squeeze(I ~= 1) * chan_list(i);
    
    if ~all(size(power_map) == size(power_map_adj))
        error('Dimensions were not preserved');
    end
    
end


end