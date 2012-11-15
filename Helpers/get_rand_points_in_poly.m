function [xp yp xv yv] = get_rand_points_in_poly(num_points, varargin)
%   This function can be called in two ways:
%
%   [xp yp] = get_rand_points_in_poly(num_points, vertices)
%       Specify the vertices of your polygon as a cell array, e.g.
%           get_rand_points_in_poly(100, {xv,yv})
%
%   [xp yp] = get_rand_points_in_poly(num_points, poly_type, area)
%       Specify the desired shape (options: 'square', 'circle') and its
%       area.
%
%   xp is an array of x-locations for the points and yp specifies the
%   y-locations.
%
%   xv is an array of the x vertices of the polygon and yv is an array of
%   the y vertices of the polygon.
%
%
%   Note: There is minimal error-checking so please call this function
%   properly.


switch(nargin)
    case 2, % user-specified polygon
        xv = varargin{1}{1};
        yv = varargin{1}{2};
    case 3, % choose from default polygons
        area = varargin{2};
        switch(lower(varargin{1}))
            case 'square',
                xv = [0 0 1 1 0] * sqrt(area);
                yv = [0 1 1 0 0] * sqrt(area);
            case 'circle',
                TH=linspace(0,2*pi,100);
                R=ones(1,length(TH))*sqrt(area/pi);
                [xv, yv] = pol2cart(TH,R);
            otherwise,
                error(['Invalid polygon option: ' varargin{1} ...
                    '; valid choices are: square, circle']);
        end
    otherwise, error('Invalid number of arguments.');
end


np = 0;
in = logical(zeros([num_points 1]));
while (np < num_points)
    np_left = num_points - np;
    xp(~in) = uniform_rand(min(xv), max(xv), [np_left 1]);
    yp(~in) = uniform_rand(min(yv), max(yv), [np_left 1]);
    
    in = inpolygon(xp, yp, xv, yv);
    
    np = sum(in);
end


end