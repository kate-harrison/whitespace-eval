% NOTE: THIS IS A MODIFIED VERSION OF MUBARAQ'S ORIGINAL GET_E
%
% Rather than return an error when the target distance is out of bounds, it
% snaps to the nearest valid distance.
%
% Also replaced calls of length(...) == 0 to isempty(...) to improve speed.
%
%
%
% White Space Evaluation Software 0.1
% Copyright (c) 2008, 2009, Regents of the University of California.
% All rights reserved.
%
% Author: Mubaraq Mishra (smm@eecs.berkeley.edu)
% Nov 2008
%
% Use and copying of this software and preparation of derivative works
% based upon this software are permitted.  However, any distribution of
% this software or derivative works must include the above copyright
% notice.
%
% This software is made available AS IS, and neither the Berkeley Wireless
% Research Center or Wireless Foundations or the University of California 
% make any warranty about the software, its performance or its conformity 
% to any specification.
%
% Suggestions, comments, or improvements are welcome and should be
% addressed to:
%
%   smm@eecs.berkeley.edu
%
% Usage E = get_E(erp, chan_no, tx_height, sigma, target_dist, prob_time, prob_loc, with_mpath, K_dB)
% erp         - Effective Radiated Power (kWatts) - can be a vector
% chan_no     - Chan Number (2-69)
% tx_height   - in meters
% dist        - in km
% sigma       - standard variation in meters
% with_mpath  - 1 if path loss files with multipath are to be used
% K_dB        - value of gain for Ricean multipath in dBs
% target_dist - can be a vector
%  
% E is a matrix of size length(target_dist) x length(erp)  

function E = get_E(erp, chan_no, tx_height, sigma, target_dist, prob_time, prob_loc, with_mpath, K_dB)

chan_list  = [[2:36] [38:69]];

if (size(erp, 1) > size(erp, 2))
    erp = erp';
end;

if (with_mpath == 0)
    if ((prob_time == .5) & (prob_loc == .5))
        load 'pl_height_50_50.mat' -MAT;
    elseif ((prob_time == .999) & (prob_loc == .5))
        load 'pl_height_50_999.mat' -MAT;
    elseif ((prob_time == .90) & (prob_loc == .5))
        load 'pl_height_50_90.mat' -MAT;
    elseif ((prob_time == .10) & (prob_loc == .5))
        load 'pl_height_50_10.mat' -MAT;
    else
        error(strcat('No Pl height file for prob time = ', num2str(prob_time), ' and prob loc = ', num2str(prob_loc)));
    end;
else
    switch(K_dB)
        case 6
            if ((prob_time == .9) & (prob_loc == .5))
                load 'pl_height_50_90_mpath_K6dB.mat' -MAT;
            else
                error(strcat('No Pl height file for K = ', num2str(K_dB), ' prob time = ', num2str(prob_time), ' and prob loc = ', num2str(prob_loc)));
            end;
        case -inf       
            if ((prob_time == .5) & (prob_loc == .5))
                load 'pl_height_50_50_mpath_Kminusinf.mat' -MAT;
            elseif ((prob_time == .1) & (prob_loc == .5))
                load 'pl_height_50_10_mpath_Kminusinf.mat' -MAT;
            else
                error(strcat('No Pl height file for K = ', num2str(K_dB), ' prob time = ', num2str(prob_time), ' and prob loc = ', num2str(prob_loc)));
            end;
        otherwise
            error(strcat('Value of K = ', num2str(K_dB), ' not supported'));
    end;
end;

if (sigma ~= 5.5)
    error(strcat('Preprocessed file not available for sigma = ', num2str(sigma)));
end;

dist   = [.01 * [1:10] .1 * [2:10] [2:20] [25:5:100] [110:10:200] [225:25:1000]]; % km
height = [10 20 37.5 75 150 300 600 1200]; % m


% path_loss_needed = (10 * log10(erp)+30 +2.15 ) - 10 * log10(4 * pi) - (target_fs - 145.8);
% path_loss_needed = (10 * log10(erp) + 60 + 2.15) + 104.8 - target_fs;

if (tx_height <= min(height))
    error('TX height is too small');
end;

if tx_height > max(height)
    error('TX height is too large');
end;

hi_l = find(height <= tx_height);
if (isempty(hi_l))
    error('TX height is too small');
else
    hi_l = hi_l(length(hi_l));
end;

hi_h = find(height > tx_height);

if (isempty(hi_h))
    error('TX height is too large');
else
    hi_h = hi_h(1);
end;

freq_id = find(chan_list == chan_no);

if (isempty(freq_id))
    error('Invalid Chan number');
end;

for n=1:length(target_dist)
    dist_l = find(dist <= target_dist(n));

    if (isempty(dist_l))
%         warning('Target distance is too small');
        dist_l = 1;
        target_dist(n) = dist(1);
    else
        dist_l = dist_l(length(dist_l));
    end;

    dist_h = find(dist > target_dist(n));

    if (isempty(dist_h))
%         warning('Target distance is too large');
        dist_h = length(dist)-1;
        target_dist(n) = dist(end-1)-1;
    else
        dist_h = dist_h(1);
    end;

    pl_height_l_l = pl_height(freq_id, hi_l, dist_l);
    pl_height_l_h = pl_height(freq_id, hi_l, dist_h);
    pl_height_h_l = pl_height(freq_id, hi_h, dist_l);
    pl_height_h_h = pl_height(freq_id, hi_h, dist_h);

    % pl_height_h = reshape(pl_height(freq_id, hi_h, :), 1, length(dist));
    % 
    % %%%%%%%%%%%%%%%%%%%%%%%
    % % for a smaller height
    % %%%%%%%%%%%%%%%%%%%%%%%
    % 
    % I = find(pl_height_l <= path_loss_needed);
    % if (length(I) == 0)
    %     error('Cannot find path loss math, target path loss is too small');
    % else
    %     I = I(length(I));
    % end;
    % pl_l_l = pl_height_l(I);
    % pl_l_l_idx = I;
    % 
    % I = find(pl_height_l > path_loss_needed);
    % if (length(I) == 0)
    %     error('Cannot find path loss math, target path loss is too large');
    % else
    %     I = I(1);
    % end;
    % pl_l_h = pl_height_l(I);
    % pl_l_h_idx = I;
    % 
    % %%%%%%%%%%%%%%%%%%%%%%%
    % % for a larger height
    % %%%%%%%%%%%%%%%%%%%%%%%
    % 
    % I = find(pl_height_h <= path_loss_needed);
    % if (length(I) == 0)
    %     error('Cannot find path loss math, target path loss is too small');
    % else
    %     I = I(length(I));
    % end;
    % pl_h_l = pl_height_h(I);
    % pl_h_l_idx = I;
    % 
    % I = find(pl_height_h > path_loss_needed);
    % if (length(I) == 0)
    %     error('Cannot find path loss math, target path loss is too large');
    % else
    %     I = I(1);
    % end;
    % pl_h_h = pl_height_h(I);
    % pl_h_h_idx = I;

    pl_l = pl_height_l_l +  (pl_height_l_h - pl_height_l_l)  * log(target_dist(n)/dist(dist_l))/log(dist(dist_h)/dist(dist_l));
    pl_h = pl_height_h_l +  (pl_height_h_h - pl_height_h_l)  * log(target_dist(n)/dist(dist_l))/log(dist(dist_h)/dist(dist_l));

    pl = pl_l + ( pl_h - pl_l) * log(tx_height/height(hi_l))/log(height(hi_h)/height(hi_l));
    E(n, :) = (10 * log10(erp)+30 +2.15 ) - 10 * log10(4 * pi) - (pl - 145.8);
end;    