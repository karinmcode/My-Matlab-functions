function hCen = myPlotCentroidsErrorbars(ax, x, y)
% Plot centroids and error bars for data (x, y) on axes ax.
% Returns handle to the plotted centroids.

% Compute median and quartiles
x_med = median(x);
y_med = median(y);
x_q1 = quantile(x, 0.25);
x_q3 = quantile(x, 0.75);
y_q1 = quantile(y, 0.25);
y_q3 = quantile(y, 0.75);

% Plot vertical error bars
hErrX = errorbar(ax, x_med, y_q1, y_q3-y_med, y_med-y_q1, 'o');
hErrX.Color = 'k';

% Plot horizontal error bars
hErrY = errorbar(ax, x_q1, y_med, x_med-x_q1, x_q3-x_med, 'o');
hErrY.Color = 'k';

% Plot centroid
hCen = plot(ax, x_med, y_med, 'o');
hCen.MarkerFaceColor = 'r';
hCen.MarkerEdgeColor = 'k';
end
