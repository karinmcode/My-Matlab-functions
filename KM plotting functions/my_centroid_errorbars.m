function [cx, cy, ex, ey, h] = my_centroid_errorbars(x, y, plot_errorbars, varargin)
% Calculates the centroid and error bars of x-y coordinates
% INPUTS:
%   x - vector of x-coordinates
%   y - vector of y-coordinates
%   plot_errorbars - (optional) flag to indicate whether to plot error bars (default = false)
%   varargin - (optional) variable-length input argument list
%     'errorbar_color', followed by the color of the error bars (default = 'k')
%     'errorbar_method', followed by the method to calculate error bars ('median' or 'mean'; default = 'median')
% OUTPUTS:
%   cx - x-coordinate of centroid
%   cy - y-coordinate of centroid
%   ex - error bar in x-direction
%   ey - error bar in y-direction
%   h - handle to the error bars

% Set default values for optional parameters
errorbar_color = 'k';
errorbar_method = 'median';

% Check if optional parameters are specified
if nargin > 3
    for i = 1:2:length(varargin)
        if strcmpi(varargin{i}, 'errorbar_color')
            errorbar_color = varargin{i+1};
        elseif strcmpi(varargin{i}, 'errorbar_method')
            errorbar_method = varargin{i+1};
        else
            error('Invalid optional parameter.');
        end
    end
end

% Calculate centroid
if strcmp(errorbar_method, 'median')
    cx = median(x);
    cy = median(y);
elseif strcmp(errorbar_method, 'mean')
    cx = mean(x);
    cy = mean(y);
else
    error('Invalid error bar method. Choose "median" or "mean".')
end

% Calculate error bars based on chosen method
if strcmp(errorbar_method, 'median')
    ex = [(median(x) - quantile(x, 0.25)), (quantile(x, 0.75) - median(x))];
    ey = [(median(y) - quantile(y, 0.25)), (quantile(y, 0.75) - median(y))];
elseif strcmp(errorbar_method, 'mean')
    ex = std(x)/sqrt(length(x));
    ey = std(y)/sqrt(length(y));
    ex = [ex ex];
    ey = [ey ey];
end

% Plot error bars if flag is true
if nargin > 2 && plot_errorbars
    hold on
    % Plot vertical error bar
    h(1) = errorbar(cx, cy, ey(1), ey(2), 'vertical', 'k','Color',errorbar_color);
    % Plot horizontal error bar
    h(2) = errorbar(cx, cy, ex(1), ex(2), 'horizontal','k','Color',errorbar_color);

else
    h = [];
end

end
