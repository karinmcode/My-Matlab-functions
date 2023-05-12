function spread = myComputeSpread(points)
% Computes the spread of the input points with (x,y) coordinates using the
% Euclidean distance from each point to the centroid, ignoring NaN values.
%
% Inputs:
% - points: an N-by-2 matrix of points with (x,y) coordinates. NaN values
%   are allowed.
%
% Output:
% - spread: a scalar value that represents the spread of the non-NaN points.
%
% Note: If the input data contains NaN values, rows containing NaN values
% will be deleted before computing the spread.

% Delete rows containing NaN values
points(any(isnan(points), 2), :) = [];

% Compute the centroid of the points
centroid = mean(points);

% Compute the Euclidean distance between each point and the centroid
distances = sqrt(sum((points - centroid).^2, 2));

% Compute the standard deviation of the distances
spread = std(distances);
end
