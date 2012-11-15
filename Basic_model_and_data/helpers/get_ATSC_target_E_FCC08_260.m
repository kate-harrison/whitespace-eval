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
% Get target electric file for chan_no (FCC 08-260) 
function E = get_ATSC_target_E_FCC08_260(chan_no)

if ((chan_no >= 2) & (chan_no <= 6)) 
    E = 28;
elseif  ((chan_no >= 7) & (chan_no <= 13))   
    E = 36;
elseif  ((chan_no >= 14) & (chan_no <= 69))
    E = 41;
else
    error('Channel number is not in the specified range');
end;    