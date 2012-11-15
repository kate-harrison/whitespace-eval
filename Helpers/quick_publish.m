function [] = quick_publish(varargin)
%   [] = kate_publish(filename, format)
%
% (format argument is optional)
%
%   Quick publishing for your files!

clc; close all;
filename = varargin{1};
filename = regexprep(filename, ' ', '_');
if (length(varargin) > 1)
    opts.format = varargin{2};
else
    opts.format = 'html';
end

opts.showCode = false;
publish(filename, opts)

end