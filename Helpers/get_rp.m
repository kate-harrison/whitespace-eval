% NOTE: THIS IS A MODIFIED VERSION OF MUBARAQ'S ORIGINAL GET_RP
%
% Mubaraq provided this file to Kate under the original name get_rp4Kate.m
%
% Rather than producing an error when the target path loss is too large or
% too small, it defaults to certain maximum and minimum values (namely, 1m
% and 5000 km (the largest distance the function can handle).
%
%
%
%
% Usage rp = get_rp(erp, chan_no, tx_height, sigma, target_fs, prob_time, prob_loc, with_mpath, K_dB)
% Erp  - Effective Radiater Power (kWatts) - can be a vector
% chan_no - Chan Number (2-69)
% tx_height - in meters
% sigma - frequency variation in meters
% with_mpath  = 1 if path loss files with multipath are to be used
% K_dB - value of gain for Ricean multipath in dBs
% target_fs - can be a vector
%  
% rp is a matrix of size length(target_fs) x length(erp)  

function rp = get_rp(erp, chan_no, tx_height, sigma, target_fs, prob_time, prob_loc, with_mpath, K_dB)

cLargeDist = 5000;  % in km

chan_list  = [[2:36] [38:69]];

if (size(target_fs, 1) < size(target_fs, 2))
    target_fs = target_fs';
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

for n=1:length(erp)
    path_loss_needed(:, n) = (10 * log10(erp(n))+30 +2.15 ) - 10 * log10(4 * pi) - (target_fs - 145.8);
end;

% path_loss_needed = (10 * log10(erp) + 60 + 2.15) + 104.8 - target_fs;

if (tx_height <= min(height))
    error('TX height is too small');
end;

if tx_height > max(height)
    error('TX height is too large');
end;

hi_l = find(height <= tx_height);
if (length(hi_l) == 0)
    error('TX height is too small');
else
    hi_l = hi_l(length(hi_l));
end;

hi_h = find(height > tx_height);

if (length(hi_h) == 0)
    error('TX height is too large');
else
    hi_h = hi_h(1);
end;

freq_id = find(chan_list == chan_no);

if (length(freq_id) == 0)
    error('Invalid Chan number');
end;

pl_height_l = reshape(pl_height(freq_id, hi_l, :), 1, length(dist));
pl_height_h = reshape(pl_height(freq_id, hi_h, :), 1, length(dist));

%%%%%%%%%%%%%%%%%%%%%%%
% for a smaller height
%%%%%%%%%%%%%%%%%%%%%%%

rp = zeros(length(target_fs), length(erp));
for n=1:length(erp)
    for m=1:length(target_fs)
        tooLarge = 0; tooSmall = 0;
        I = find(pl_height_l <= path_loss_needed(m, n));
        if (length(I) == 0)
            tooSmall = 1;
        else
            I = I(length(I));
            pl_l_l = pl_height_l(I);
            pl_l_l_idx = I;
        end;

        I = find(pl_height_l > path_loss_needed(m, n));
        if (length(I) == 0)
            tooLarge = 1;
        else
            I = I(1);
            pl_l_h = pl_height_l(I);
            pl_l_h_idx = I;
        end;

        %%%%%%%%%%%%%%%%%%%%%%%
        % for a larger height
        %%%%%%%%%%%%%%%%%%%%%%%

        I = find(pl_height_h <= path_loss_needed(m, n));
        if (length(I) == 0)
            tooSmall = 1;
        else
            I = I(length(I));
            pl_h_l = pl_height_h(I);
            pl_h_l_idx = I;
        end;

        I = find(pl_height_h > path_loss_needed(m, n));
        if (length(I) == 0)
            tooLarge = 1;
        else
            I = I(1);
            pl_h_h = pl_height_h(I);
            pl_h_h_idx = I;
        end;

        if tooSmall
            rp(m, n) = .001;
            warning('Cannot find path loss match, target path loss is too small, defaulting to 1m');
        elseif tooLarge
            rp(m, n) = cLargeDist;
            warning(strcat('Cannot find path loss match, target path loss is too large, defaulting to: ', num2str(cLargeDist), ' km'));
        else
            pl_l = 10^((path_loss_needed(m, n) - pl_l_h) * log10(dist(pl_l_l_idx))/(pl_l_l - pl_l_h) + (path_loss_needed(m, n) - pl_l_l) * log10(dist(pl_l_h_idx))/(pl_l_h - pl_l_l));
            pl_h = 10^((path_loss_needed(m, n) - pl_h_h) * log10(dist(pl_h_l_idx))/(pl_h_l - pl_h_h) + (path_loss_needed(m, n) - pl_h_l) * log10(dist(pl_h_h_idx))/(pl_h_h - pl_h_l));
            rp(m, n) = (log10(tx_height) - log10(height(hi_h))) * pl_l/(log10(height(hi_l)) - log10(height(hi_h))) + (log10(tx_height) - log10(height(hi_l))) * pl_h/(log10(height(hi_h)) - log10(height(hi_l)));
        end;    
    end;     
end;    