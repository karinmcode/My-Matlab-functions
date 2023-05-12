function [h, img] = my_plot_density(x, y, varargin)
% my_plot_density: plot density of x,y coordinates
%
% Inputs:
%   - x: vector of x coordinates
%   - y: vector of y coordinates
%   - xbins (optional): number of bins in x direction (default: 100)
%   - ybins (optional): number of bins in y direction (default: 100)
%   - xbin_edges (optional): vector of x bin edges
%   - ybin_edges (optional): vector of y bin edges
%   - color (optional): color of density image, can be a string or RGB vector (default: 'red')
%   - alpha (optional): transparency of density image (default: 0.5)
%   - centroid (optional): transparency of density image (default: 0.5)

%
% Outputs:
%   - h: handle to the image object
%   - img: matrix of density values used to create the image object
%
% Example usage:
%   x = randn(1000,1);
%   y = randn(1000,1);
%   my_plot_density(x, y, 'color', [0, 0, 1], 'alpha', 0.3);

    % Set default values for optional inputs
    default_xbins = 100;
    default_ybins = 100;
    default_color = 'red';
    default_alpha = 0.8;
    
    % Parse optional inputs
    p = inputParser;
    addOptional(p, 'xbins', default_xbins);
    addOptional(p, 'ybins', default_ybins);
    addOptional(p, 'xbin_edges', []);
    addOptional(p, 'ybin_edges', []);
    addOptional(p, 'color', default_color);
    addOptional(p, 'alpha', default_alpha);
    parse(p, varargin{:});
    xbins = p.Results.xbins;
    ybins = p.Results.ybins;
    xbin_edges = p.Results.xbin_edges;
    ybin_edges = p.Results.ybin_edges;
    color = p.Results.color;
    alpha = p.Results.alpha;
    
    % Create histogram2D of x and y coordinates
    if isempty(xbin_edges) || isempty(ybin_edges)
        [N, xbin_edges, ybin_edges] = histcounts2(x, y, xbins, ybins);
    else
        [N, ~, ~] = histcounts2(x, y, xbin_edges, ybin_edges);
    end
    
    % Normalize histogram2D by maximum count value
    N = N / max(N(:));
    
    % Create white-to-color gradient
    cmap = my_color_gradient(color, 256);
    
    % Interpolate density values using the gradient
    img = ind2rgb(round(N*255)+1, cmap);
    
    % Create image object and set properties
    x_centers = (xbin_edges(1:end-1) + xbin_edges(2:end)) / 2;
    y_centers = (ybin_edges(1:end-1) + ybin_edges(2:end)) / 2;
    h = imagesc(x_centers, y_centers, img);
    set(h, 'AlphaData', alpha,'CDatamapping','direct');
    set(gca, 'YDir', 'normal');

end
