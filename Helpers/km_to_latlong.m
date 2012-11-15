function [ lat2 long2 ] = km_to_latlong( lat1, long1, dist, dir )
%
%   [ lat2 long2 ] = km_to_latlong( lat1, long1, dist, dir )
%
% KM_TO_LATLONG Finds the latitude and longitude (in degrees) coordinates
% of the point *dist* km away from (*lat1*, *long1*) (in degrees) in
% direction *dir* clockwise from North (in degrees);
%
% Source: http://www.movable-type.co.uk/scripts/latlong.html

R = 6371;   % Earth's mean radius

lat1 = lat1 * pi/180;
long1 = long1 * pi/180;

dir = dir * pi/180;


lat2 = asin( sin(lat1)*cos(dist/R) + cos(lat1)*sin(dist/R)*cos(dir) );
long2 = long1 + atan2( sin(dir)*sin(dist/R)*cos(lat1), cos(dist/R)-sin(lat1)*sin(lat2) );

lat2 = lat2 * 180/pi;
long2 = long2 * 180/pi;



end

