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

% Generate tables with multipath. 
% process_path_loss_wmpath(freq, target_prob_time, vname, fname, fmpath_name)
% This function combines the ITU CCDF tables with multipath PDF tables to generate new F(50, x) tables.
% freq - frequency in MHz
% target_prob_time - between 0 and 1
% vname - variable name for new table 
% fname - filename for new table
% fmpath_name - Name of file containing multipath pdf

function process_path_loss_wmpath(freq, target_prob_time, vname, fname, fmpath_name)

if ((target_prob_time < 0) || (target_prob_time > 1))
    error('Target prob of time should be between 0 and 1 (0 and 1 inclusive)');
end;
    
load 'ITU_F_50_10_FREQ100.mat';
load 'ITU_F_50_50_FREQ100.mat';
load 'ITU_F_50_10_FREQ600.mat';
load 'ITU_F_50_50_FREQ600.mat';
load 'ITU_F_50_10_FREQ2000.mat';
load 'ITU_F_50_50_FREQ2000.mat';

switch (freq)
    case {100}
        ITU_F_50_50 = ITU_F_50_50_FREQ100;
        ITU_F_50_10 = ITU_F_50_10_FREQ100;
    case {600}
        ITU_F_50_50 = ITU_F_50_50_FREQ600;
        ITU_F_50_10 = ITU_F_50_10_FREQ600;
    case {2000}
        ITU_F_50_50 = ITU_F_50_50_FREQ2000;
        ITU_F_50_10 = ITU_F_50_10_FREQ2000;
    otherwise    
        error('Supported frequencies - 100MHz, 600MHz, 2000MHz');
end;
    
S = load(fmpath_name); % Change based on K value 
pdf_val = S.pdf;
val = S.val;
delta = val(2) - val(1);

dist   = [.01 * [1:10] .1 * [2:10] [2:20] [25:5:100] [110:10:200] [225:25:1000]]; % km
height = [10 20 37.5 75 150 300 600 1200]; % m

prob_time = [.999:-.0001:.0001];

target_differ = .0001;
target = target_prob_time; 

for n=1:length(dist)
    disp(strcat('Now generating PDF for distance = ', num2str(dist(n)), 'km'));
    for m=1:length(height)    
        A  = ITU_F_50_50(n, m); 
        B  = max(ITU_F_50_10(n, m), ITU_F_50_50(n, m)); 
        E  = A + ((B-A) * (qfuncinv(prob_time)/qfuncinv(.1)));
        Ee = [min(E)-10:.001:max(E)+5];

        mid_idx = floor(length(Ee)/2);
        min_idx = 1;
        max_idx = length(Ee);

        s = calc_sum_ccdf(prob_time, E, pdf_val, val, Ee(mid_idx));
        a_differ = s - target;
        f = 100;

        while((abs(a_differ) > target_differ) && (f > 1))                
            if (sign(a_differ) > 0)
                min_idx = mid_idx;
                mid_idx = floor((max_idx + min_idx)/2);
            else
                max_idx = mid_idx;
                mid_idx = floor((max_idx + min_idx)/2);
            end;
            s = calc_sum_ccdf(prob_time, E, pdf_val, val, Ee(mid_idx));
            a_differ = s - target;
            f = max(diff([min_idx mid_idx max_idx]));
        end;

        ITU_F_50_q_mpath(n, m) = Ee(mid_idx); 
    end;
end;

eval(strcat(vname, '= ITU_F_50_q_mpath'));
save(fname, vname);