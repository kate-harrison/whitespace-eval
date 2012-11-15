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
% Usage pl = get_path_loss(freq, prob_time, prob_loc)
% freq : freq in MHz
% prob_loc : number between 0 and 1
function pl = get_path_loss(freq, prob_time, with_mpath, K_dB)

if (with_mpath == 0)
    load 'ITU_F_50_10_FREQ100.mat';
    load 'ITU_F_50_50_FREQ100.mat';
    load 'ITU_F_50_10_FREQ600.mat';
    load 'ITU_F_50_50_FREQ600.mat';
    load 'ITU_F_50_10_FREQ2000.mat';
    load 'ITU_F_50_50_FREQ2000.mat';
else
    switch(K_dB)
        case 6
            load 'ITU_F_50_10_FREQ100_mpath_K6dB.mat';
            load 'ITU_F_50_50_FREQ100_mpath_K6dB.mat';
            load 'ITU_F_50_10_FREQ600_mpath_K6dB.mat';
            load 'ITU_F_50_50_FREQ600_mpath_K6dB.mat';
            load 'ITU_F_50_10_FREQ2000_mpath_K6dB.mat';
            load 'ITU_F_50_50_FREQ2000_mpath_K6dB.mat';
        case -inf
            load 'ITU_F_50_10_FREQ100_mpath_Kminusinf.mat';
            load 'ITU_F_50_50_FREQ100_mpath_Kminusinf.mat';
            load 'ITU_F_50_10_FREQ600_mpath_Kminusinf.mat';
            load 'ITU_F_50_50_FREQ600_mpath_Kminusinf.mat';
            load 'ITU_F_50_10_FREQ2000_mpath_Kminusinf.mat';
            load 'ITU_F_50_50_FREQ2000_mpath_Kminusinf.mat';
        otherwise
            error(strcat('Value of K =', num2str(K), ' not supported'));
    end;
end;    
        
dist   = [.01 * [1:10] .1 * [2:10] [2:20] [25:5:100] [110:10:200] [225:25:1000]]; % km
height = [10 20 37.5 75 150 300 600 1200]; % m

F1 = 100;
F2 = 600;
F3 = 2000;

lg_F1 = log10(F1);
lg_F2 = log10(F2);
lg_F3 = log10(F3);
lg_f  = log10(freq);

if (freq < 600)
    A = ((lg_F2 - lg_f) * ITU_F_50_50_FREQ100 + (lg_f - lg_F1) * ITU_F_50_50_FREQ600)/(lg_F2 - lg_F1);
    B = ((lg_F2 - lg_f) * ITU_F_50_10_FREQ100 + (lg_f - lg_F1) * ITU_F_50_10_FREQ600)/(lg_F2 - lg_F1);
else   
    A = (((lg_F3 - lg_f) * ITU_F_50_50_FREQ600) + ((lg_f - lg_F2) * ITU_F_50_50_FREQ2000))/(lg_F3 - lg_F2);
    B = (((lg_F3 - lg_f) * ITU_F_50_10_FREQ600) + ((lg_f - lg_F2) * ITU_F_50_10_FREQ2000))/(lg_F3 - lg_F2);
end;

E = A + ((B-A) * (qfuncinv(prob_time)/qfuncinv(.1)));
% E1 = E + sigma * Qinv(prob_loc);
E1 = E;
pl = (30+2.15) - 10 * log10(4 * pi) + 145.8 - E1;
%pl2 = -(( A+ (B-A)*(Qinv(prob_time)/Qinv(.1))- Qinv(prob_loc)*sigma-(30+2.15))+10*LOG10(4*pi)-145.8);
%pl - pl2
