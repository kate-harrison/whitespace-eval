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
% Usage calc_sum_ccdf(A_ccdf, A_ccdf_val, B_pdf, B_pdf_val, x)
% To calculate the probability P(A + B > x);
% A_ccdf is P(A > x) and A_ccdf_val is the values at which these probabilities are calculated 
% B_pdf is f_B(y) and B_pdf_val is the values at which these probabilities are calculated 
function s = calc_sum_ccdf(A_ccdf, A_ccdf_val, B_pdf, B_pdf_val, x)

    s  = 0;
    for k=1:length(B_pdf_val)
        I = find(A_ccdf_val >= x - B_pdf_val(k));
        if (length(I) > 0)
            [min_val J] = min(A_ccdf_val(I));
            p = A_ccdf(I(J));
        else
            p = 0;
        end;
%         if (length(I) == length(A_ccdf_val))
%             p = 1;
%         elseif (length(I) > 0)
%             [min_val J] = min(A_ccdf_val(I));
%             p = A_ccdf(I(J));
%         else
%             p = 0;
%         end;
        s = s + p * B_pdf(k); 
    end;