function [ dist ] = latlong_to_km( lat1, long1, lat2, long2 )
%LATLONG_TO_KM Finds the distance between two latitude and longitude points
%   [ dist ] = latlong_to_km( lat1, long1, lat2, long2 )
%   Inputs are self-explanatory and in degrees
%   Output is the distance in km

% Source: http://www.movable-type.co.uk/scripts/latlong.html

R = 6371;   % Earth's mean radius

% Convert to radians
lat1 = lat1 * pi/180;
lat2 = lat2 * pi/180;
long1 = long1 * pi/180;
long2 = long2 * pi/180;

d_lat = (lat2 - lat1);
d_long = (long2 - long1);
a = sin(d_lat/2).^2 + cos(lat1) .* cos(lat2) .* sin(d_long/2).^2;
c = 2 * atan2(sqrt(a), sqrt(1-a));
dist = R*c;





end

