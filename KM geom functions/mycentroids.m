function [Centroids, ErrorBars] = mycentroids(x, y, id)
% mycentroids - computes the centroids of clusters and the vertical and horizontal error bars using quartiles instead of maximum and minimum values
% USAGE:
%   [Centroids, ErrorBars] = mycentroids(x, y, id)
% INPUTS:
%   x - a column vector of x-coordinates for each data point
%   y - a column vector of y-coordinates for each data point
%   id - a column vector indicating the cluster membership for each data point
% OUTPUTS:
%   Centroids - a matrix containing the (x,y) coordinates of the centroids for each cluster
%   ErrorBars - a 3D array containing the vertical and horizontal error bars for each cluster

% Find the unique values in the input `id` vector, which correspond to the cluster labels.
pclu = unique(id);
% Calculate the number of clusters as the number of unique values in `id`.
nclu = numel(pclu);
% Create a matrix `xy` containing the (x,y) coordinates for all data points.
xy = [x y];
% Initialize the output variables.
Centroids = nan(nclu, 2);
ErrorBars = nan(nclu, 2, 2);
% Loop over each unique cluster and calculate the centroid and error bars.
for iclu = 1:nclu
    % Create a logical index that selects the coordinates of data points belonging to the current cluster.
    i4clu = pclu(iclu) == id;
    % Select the (x,y) coordinates of data points belonging to the current cluster.
    xy_clu = xy(i4clu, :);
    % Calculate the median of the selected coordinates, which is assigned to the corresponding row of the `Centroids` matrix.
    Centroids(iclu, :) = median(xy_clu, 1, 'omitnan');
    % Calculate the vertical and horizontal error bars for the current cluster.
    ErrorBars(iclu, 1, :) = [Centroids(iclu, 2) - prctile(xy_clu(:, 2), 25), prctile(xy_clu(:, 2), 75) - Centroids(iclu, 2)];
    ErrorBars(iclu, 2, :) = [Centroids(iclu, 1) - prctile(xy_clu(:, 1), 25), prctile(xy_clu(:, 1), 75) - Centroids(iclu, 1)];
end
% Return the `Centroids` matrix containing the (x,y) coordinates of the centroids for each cluster and the `ErrorBars` array containing the vertical and horizontal error bars for each cluster.
end
