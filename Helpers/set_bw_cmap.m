function [] = set_bw_cmap(varargin)
%   [] = set_bw_cmap([jet_size])
%
%   Edits the colormap so that the lowest value is black and the highest
%   value is white. Uses the current figure's colormap unless [jet_size] is
%   specified in which case it uses the colormap jet(jet_size).
%
%   See also: jet


% Set up the colormap
% cmap = jet(2^20);
if nargin < 1
    cmap = colormap;    % get the colormap of th current figure
else
    cmap = jet(varargin{1});
end
cmap(end, :) = [1 1 1];    % infinity is white
cmap(1, :) = [0 0 0];               % zero is black
colormap(cmap);


end