function [meanProb, distGroup,pSameGroup] = compute_pba_same_group(X, Y, Group, distVector)
    % Combine X and Y coordinates into a single matrix
    points = [X(:), Y(:)];
    nPoints = size(points, 1);

    % Calculate pairwise distances between all points
    distMatrix = pdist(points, 'euclidean');
    
    % Create distance bins
    edges = [-inf, distVector(2:end) - diff(distVector)/2, inf];
    
    % Bin the distances in distMatrix
    [~,~,binIdx] = histcounts(distMatrix, edges);
    
    % Initialize the probability vector
    pSameGroup = cell(numel(distVector), 1);

    % For each bin in distVector, calculate the probability of points being in the same group
    for i = 1:numel(distVector)
        % Get the indices of point pairs within the current bin
        withinBinIdx = find(binIdx == i);
        
        % Convert the indices to subscripts (row and column indices)
        [rowIdx, colIdx] = ind2sub([nPoints, nPoints-1], withinBinIdx);
        
        % Get the group labels of the points in those pairs
        groupLabels1 = Group(rowIdx);
        groupLabels2 = Group(colIdx);
        
        % Calculate individual probability points for the current bin
        sameGroup = (groupLabels1-groupLabels2)<=4;
        % Calculate the mean distance in group value
        distGroup(i) = mean(abs(groupLabels1-groupLabels2));

        % Calculate the mean probability of points being in the same group
        meanProb(i) = mean(sameGroup);%figure;plot(meanProb)
        
       
    end
end
