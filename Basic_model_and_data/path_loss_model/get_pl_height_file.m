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
% Usage get_pl_height_file(prob_time, prob_loc, wmpath, K, filename)
% prob_time - probability of time (1 - 99)
% prob_loc  - probability in locations (1 - 99)
% wmapth   - pl_height files with multipath, 0 with generate pl_height files without muitipath
% filenmae - pl_height file name

function get_pl_height_file(prob_loc, prob_time, wmpath, K, filename)

sigma = 5.5;
chan_list  = [[2:36] [38:69]];
dist   = [.01 * [1:10] .1 * [2:10] [2:20] [25:5:100] [110:10:200] [225:25:1000]]; % km
height = [10 20 37.5 75 150 300 600 1200]; % m
pl_height = zeros(length(chan_list), length(height), length(dist));

for n=1:length(chan_list)
    [l h] = get_freq(chan_list(n));
    pl = get_path_loss((l+h)/2, prob_time/100, wmpath, K);
    pl = pl - sigma * qfuncinv(prob_loc/100);
    pl_height(n, :, :) = pl';
end;

save(filename, 'pl_height', '-MAT');