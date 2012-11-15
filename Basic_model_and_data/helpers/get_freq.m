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
% Usage [l h] = get_freq(chan_no)
% chan_no = Integer between 2 and 69.
% l - lower frequency in MHz
% h - upper frequency in MHz

function [l h] = get_freq(chan_no)

switch(chan_no)
    case{2, 3, 4}
        l = (chan_no - 2) * 6 + 54;
        h = (chan_no - 2) * 6 + 60;
    case{5, 6}
        l = (chan_no - 5) * 6 + 76;
        h = (chan_no - 5) * 6 + 82;
    otherwise    
    if ((chan_no >= 7) & (chan_no <=13))
        l = (chan_no - 7) * 6 + 174;
        h = (chan_no - 7) * 6 + 180;    
    elseif ((chan_no >= 14) & (chan_no <=69))
        l = (chan_no - 14) * 6 + 470;
        h = (chan_no - 14) * 6  + 476;
    elseif ((chan_no <= 1) || (chan_no > 69))
        error('Incorrect channel number');
    end;
end;    