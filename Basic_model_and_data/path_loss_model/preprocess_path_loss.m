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
% pre process path loss files

get_pl_height_file(50, 50, 0, 0, 'pl_height_50_50.mat');
get_pl_height_file(50, 10, 0, 0, 'pl_height_50_10.mat');
get_pl_height_file(50, 90, 0, 0, 'pl_height_50_90.mat');
get_pl_height_file(50, 50, 1, -inf, 'pl_height_50_50_mpath_Kminusinf.mat');
get_pl_height_file(50, 10, 1, -inf, 'pl_height_50_10_mpath_Kminusinf.mat');
get_pl_height_file(50, 90, 1, 6, 'pl_height_50_90._mpath_K6dB.mat');