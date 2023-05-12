function [clusterIdentifiers,Radius,MinPoints,nclu]=mydbscan(xy,pMinPoints,pRadius)
%[iclu,minPoints,Radius]=mydbscan(xy,minPoints,Radius)
% finds best params if Radius is nan
% TO FINISH
%%

DEBUG = 1;
if DEBUG
    URLxy = 'G:\My Drive\code\GUIs\bentoMAT-master\data\ExptKM\proc_data\CAM1_m943_220413_003_motion_speed__vidmotion___HOG_CellSize_20__PCA_nPCs_100__uMAP_min_dist_0o06_n_neighbors_199_template_0.mat'
    TargetNCLU = 16;
    thresholdNCluPlot = 3;
    load(URLxy,'XYclusters','clusterIdentifiers');
    idx = randsample(numel(XYclusters(:,1)),1000);
    XYclusters = XYclusters(idx,:);
    clusterIdentifiers = clusterIdentifiers(idx);
    x= XYclusters(:,1);
    y = XYclusters(:,2);
    xy = [x y];
    pRadius = nan;
    pMinPoints = 16;
end
n= numel(x);

FINDBESTPARAMS = isnan(pRadius);
if FINDBESTPARAMS
    TargetNCLU = pMinPoints;
else
    TargetNCLU = nan;
end

if FINDBESTPARAMS
    iniMinPoints = 5;
    BiggestRadius = mymax([round(range(y)/TargetNCLU)  round(range(y)/TargetNCLU) ]);
    StepDown = -0.05*BiggestRadius;
    bestRadius=clusterDBSCAN.estimateEpsilon(xy,iniMinPoints,10);
    KeepGoing = 1;
    while KeepGoing

        clusterIdentifiers = dbscan(XYclusters,Radius,MinPoints);% (Radius,minpoints)
        if ismember(-1,clusterIdentifiers)
            clusterIdentifiers(clusterIdentifiers==-1)=mymax(clusterIdentifiers)+1;
        end
        pclu = unique(clusterIdentifiers);
        nclu = numel(pclu)
        Radius = Radius+0.01
    end




end

[order,reachdist] = clusterDBSCAN.discoverClusters(xy,bestRadius,iniMinPoints)

    allD = pdist2(xy,xy,'euc','Smallest',iniMinPoints);% look for the beggining of the knee
    smallestDist = sort(allD(end,:));

    figure
    cla
    plot(smallestDist);
    hold on;

    dSmallestDist = diff(smallestDist);
    dSmallestDist  = dSmallestDist/mymax(dSmallestDist)*mymax(smallestDist);

    plot(dSmallestDist);
    thresholdDiff = 0.1*mymax(smallestDist);% vary between 0.01 - 0.1 ; low means more clusters

    i4 = find(dSmallestDist>thresholdDiff,1);
    Radius = smallestDist(find(i4,1));
end

SmallestRadius = mymin(smallestDist)/2;

mymax(smallestDist);
iclu = 1

bestRadius=clusterDBSCAN.estimateEpsilon(xy,5,10);



end