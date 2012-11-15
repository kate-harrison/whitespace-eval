function [dist] = polar_distance(r1, r2, theta1, theta2)
% function [dist] = polar_distance(r1, r2, theta1, theta2)

dist = sqrt( r1.^2 + r2.^2 - 2*r1.*r2.*cos(theta1-theta2) );

end