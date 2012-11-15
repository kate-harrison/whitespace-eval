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
% Usage: function E = get_dBu_to_dBm(pow_dBm, chan_no)
% converts Power in dBm to Electric field in dBu
% pow_dBm - Vector/Scalar of powers
% chan_no - Vector/Scalar of electric fields
%
% If chan_no is scalar and pow_dBm is a vector, then chan_no is used for all pow_dBm
% If chan_no is vector, then pow_dBm must be a vector of the same length as chan_no 

function E = get_dBm_to_dBu(pow_dBm, chan_no)

if (length(chan_no) == 1)

    if ((chan_no >= 2) & (chan_no <= 6)) 
        E = pow_dBm + 111.8;
    elseif  ((chan_no >= 7) & (chan_no <= 13))   
        E = pow_dBm + 120.8;
    elseif  ((chan_no >= 14) & (chan_no <= 69))
        [l h] = get_freq(chan_no);
        E = pow_dBm + 130.8 - 20 * log10(615/((l+h)/2));
    else
        error('Channel number is not in the specified range');
    end;    
    
else
    if (length(chan_no) ~= lengt(pow_dBm))
        error('chan_no (Channel number) and pow_dBm (power) must have the same vector length');
    end;
    
    if ((chan_no(n) >= 2) & (chan_no(n) <= 6)) 
        E(n) = pow_dBm(n) + 111.8;
    elseif  ((chan_no(n) >= 7) & (chan_no(n) <= 13))   
        E(n) = pow_dBm(n) + 120.8;
    elseif  ((chan_no(n) >= 14) & (chan_no(n) <= 69))
        [l h] = get_freq(chan_no);
        E(n) = pow_dBm(n) + 130.8 - 20 * log10(615/((l+h)/2));
    else
        error('Channel number is not in the specified range');
    end;    
end;