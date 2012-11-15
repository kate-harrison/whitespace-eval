function [r] = uniform_rand(a,b,varargin)
%   [r] = uniform_rand(a,b, [dims])
%
%   This function is simply a wrapper for the following line:
%
%       r = a + (b-a).*rand([1,1]);
%
%   The optional third argument specifies the dimensions of the output. For
%   example, rand(0, 1, [2 2]) creates a 2x2 matrix with values taken
%   independently from unif(0,1).

if (nargin < 3)
    dims = [1 1];
else
    dims = varargin{1};
end

r = a + (b-a).*rand(dims);

end