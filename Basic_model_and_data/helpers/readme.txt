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
m Files
-------

These files are small routines that are used in other routines

apply_erp_limits.m                - Apply ERP limits for ATSC signals   
find_dist_from_lat_long.m         - compute distances from lat longs 
find_pop_density.m		    - compute the population desnity at a given lat long	
find_zips_near_lat_long.m	    - find list of zip codes near a given lat long 	
gen_rand_lat_long_by_area.m 	    - Generate list of random latitudes and longitudes within the continental US
					      This assumes a uniform population desnity
gen_rand_lat_long_by_pop.m	    - Generate list of random latitudes and longitudes within the continental US
					      This takes into account the actual population desnity 	
get_adj.m				    - get list of adjacent channels for channels between 2 and 69	
get_ATSC_target_E.m		    - Get ATSC target Electric Field for a given channel based on the OET 69 bulletin
get_ATSC_target_E_FCC08_260.m	    - Get ATSC target Electric Field for a given channel based on the FCC report of Nov 14th - FCC 08-260)	
get_dBm_to_dBu.m			    - Convert from dBm to dBu	(based on the OET 69 magazine).
get_dBu_to_dBm.m			    - Convert from dBu to dBm	(based on the OET 69 magazine).	
get_freq.m                        - Get lower and upper frequencies for a given channel
get_operational_SINR.m		    - Find operational SINR for each channel based on FCC 08-260 
is_in_continental_us.m		    - Determine if a give latitude/longitude is in the continental US	
latlong_from_deg_to_rad.m	    - Convert lat/long from degrees to radians
lat_from_rad_to_deg.m		    - Convert lat from radians to degrees	
long_from_rad_to_deg.m		    - Convert long from radians to degrees
