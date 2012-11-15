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

% Generate all multiptha tables  

freq = 100;
target_prob_time = .1;
vname = 'ITU_F_50_10_FREQ100';
fname = 'ITU_F_50_10_FREQ100_mpath_Kminusinf.mat';
fmpath_name = 'multipath_distribution_Kminusinf.mat';
process_path_loss_wmpath(freq, target_prob_time, vname, fname, fmpath_name);

freq = 100;
target_prob_time = .5;
vname = 'ITU_F_50_50_FREQ100';
fname = 'ITU_F_50_50_FREQ100_mpath_Kminusinf.mat';
fmpath_name = 'multipath_distribution_Kminusinf.mat';
process_path_loss_wmpath(freq, target_prob_time, vname, fname, fmpath_name);

freq = 600;
target_prob_time = .1;
vname = 'ITU_F_50_10_FREQ600';
fname = 'ITU_F_50_10_FREQ600_mpath_Kminusinf.mat';
fmpath_name = 'multipath_distribution_Kminusinf.mat';
process_path_loss_wmpath(freq, target_prob_time, vname, fname, fmpath_name);

freq = 600;
target_prob_time = .5;
vname = 'ITU_F_50_50_FREQ600';
fname = 'ITU_F_50_50_FREQ600_mpath_Kminusinf.mat';
fmpath_name = 'multipath_distribution_Kminusinf.mat';
process_path_loss_wmpath(freq, target_prob_time, vname, fname, fmpath_name);

freq = 2000;
target_prob_time = .1;
vname = 'ITU_F_50_10_FREQ2000';
fname = 'ITU_F_50_10_FREQ2000_mpath_Kminusinf.mat';
fmpath_name = 'multipath_distribution_Kminusinf.mat';
process_path_loss_wmpath(freq, target_prob_time, vname, fname, fmpath_name);

freq = 2000;
target_prob_time = .5;
vname = 'ITU_F_50_50_FREQ2000';
fname = 'ITU_F_50_50_FREQ2000_mpath_Kminusinf.mat';
fmpath_name = 'multipath_distribution_Kminusinf.mat';
process_path_loss_wmpath(freq, target_prob_time, vname, fname, fmpath_name);