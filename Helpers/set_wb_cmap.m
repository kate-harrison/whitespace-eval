function [] = set_wb_cmap(varargin)
%   [] = set_wb_cmap([jet_size])
%
%   Edits the colormap so that the lowest value is white and the highest
%   value is black. Uses the current figure's colormap unless [jet_size] is
%   specified in which case it uses the colormap jet(jet_size).
%
%   See also: jet, set_bw_cmap


% Set up the colormap
if nargin < 1
    cmap = colormap;    % get the colormap of th current figure
else
    cmap = jet(varargin{1});
end
cmap(end, :) = [0 0 0];    % infinity is black
cmap(1, :) = [1 1 1];               % zero is white
colormap(cmap);


end