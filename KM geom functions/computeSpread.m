function spread = myComputeSpread(points)
    % Compute the centroid of the points
    centroid = mean(points);
    
    % Compute the Euclidean distance between each point and the centroid
    distances = sqrt(sum((points - centroid).^2, 2));
    
    % Compute the standard deviation of the distances
    spread = std(distances);
end