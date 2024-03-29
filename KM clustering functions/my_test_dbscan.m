function [figs,data]=my_test_dbscan(URLxy)
% % my_test_dbscan(url)
% opt.dbscan.MinPoints = 10;% Minimum number of neighbors for a core point ndim+1
% opt.dbscan.Radius =0.1;% irrelevant because set later
% opt.dbscan.nclusters = 16;
% youtube video : https://www.google.com/search?q=dbscan+explained+in+5+min&tbm=vid&sa=X&ved=2ahUKEwj8goKD9uz7AhUMEVkFHUicBW0Q0pQJegQIDBAB&biw=1512&bih=833&dpr=2#fpstate=ive&vld=cid:5ec633c0,vid:RDZUdRSDOok
% MinPoints 
% https://www.mathworks.com/help/radar/ref/clusterdbscan.clusterdbscan.estimateepsilon.html


URLxy = 'G:\My Drive\code\GUIs\bentoMAT-master\data\ExptKM\proc_data\CAM1_m943_220413_003_motion_speed__vidmotion___HOG_CellSize_20__PCA_nPCs_100__uMAP_min_dist_0o06_n_neighbors_199_template_0.mat'
GoalNClusters = 16;
thresholdNCluPlot = 3;

load(URLxy,'XYclusters','clusterIdentifiers');

% idx = randsample(numel(XYclusters(:,1)),1000);
% XYclusters = XYclusters(idx,:);
% clusterIdentifiers = clusterIdentifiers(idx);

x= XYclusters(:,1);
y = XYclusters(:,2);
xy = [x y];
n= numel(x);
if n>30000
    s = x*0+5;
else
    s = x*0+20;
end
X =x';
Y = y';
mytestdata = xy;
cluURL = replace(URLxy,'.mat','for_clustering.dat');

save('mytestdata.mat','mytestdata', '-v7.3');

findcluster(cluURL)
findcluster('mytestdata.mat')
load('mytestdata.dat')
%% define inputs to dbscan
ParamDefinition = 'compute radius for all MinPoints';
switch ParamDefinition
    case '2 vectors'
        pMinPoints = 5:5:10;
        pRadius = 0.3:-0.05:0.2;
    case 'vectors'
        pMinPoints = 5:5:10;
        BiggestRadius = round(range(y)/GoalNClusters);
        StepDown = -0.1*BiggestRadius;
        SmallestRadius = 0.1;
        pRadius = BiggestRadius:StepDown:SmallestRadius;
        pRadius = 0.3:-0.05:0.2;
        
    case 'compute radius for all MinPoints'% fastest
        pMinPoints = 5:5:20;
        pRadius =  clusterDBSCAN.estimateEpsilon(xy,min(pMinPoints),max(pMinPoints));
    case 'compute radius for each MinPoints'
        pMinPoints = 5:5:20;
        pRadius = nan;

end
nmp =numel(pMinPoints);
nr = numel(pRadius);
NCLU=nan(nmp,nr);

%% FIGURE
figs = makegoodfig('my_test_dbscan','slide');
isub = 0;
nrow = nmp;
ncol = nr;

rowNames = cell(nrow,1);
colNames  = cell(ncol,1);
xOff = 0.3/ncol;
yOff = 0.3/nrow;


AX=mysubplot([],nrow,ncol,'xOffset',xOff,'yOffset',yOff);
sz=0;
plotRadius = nan(nrow,ncol);
for imp=1:nmp
    irow = imp;
    thisMinPoints = pMinPoints(imp);
    rowNames{irow} = sprintf('minPoint = %g',thisMinPoints);

    for ir = 1:nr
        icol = ir;
        thisRadius = pRadius(ir);
        if isnan(thisRadius)
            tic% takes 30 sec for 30000
            thisRadius =  clusterDBSCAN.estimateEpsilon(xy,thisMinPoints,thisMinPoints+5);
            toc
            plotRadius(imp,ir) = thisRadius;
        else
            plotRadius(imp,ir) = thisRadius;
        end
        colNames{icol} = sprintf('Radius = %.3f',thisRadius);

        % display progress
        cleanline(sz);
        sz=fprintf('\n %s  ,   %s',rowNames{irow},colNames{icol});

%         tic%takes 10 times longer
%         clusterer= clusterDBSCAN('MinNumPoints',thisMinPoints,'Epsilon',thisRadius, 'EnableDisambiguation',true);
%         clu = clusterer(xy,myminmax(xy(:)));
%         toc

        tic
        clu = dbscan(xy,thisRadius,thisMinPoints);% (Radius,minpoints)
        TOC=toc;
        cleanline(sz);
        sz=fprintf('\n %s  ,   %s >>> %g seconds elapsed.',rowNames{irow},colNames{icol},TOC);  

        if all(clu==0)
            break
        end
        if ismember(-1,clu)
            clu(clu==-1)=mymax(clu)+1;
        end

        if any(clu==0)
            clu = clu+1;
        end


        pclu = unique(clu);
        nclu = numel(pclu);
        NCLU(imp,ir) =nclu;

        cleanline(sz);
        sz=fprintf('\n %s  ,   %s >>> %g seconds elapsed. >>> found %g clusters',rowNames{irow},colNames{icol},TOC,nclu);   

        %% if nclu is close to goal clu
        if nclu>GoalNClusters-3 &&  nclu<GoalNClusters+3
        % colormaps
        CM = jet(nclu);
        c = CM(clu,:);
        % plotting

        ax=AX(irow,icol);
        axes(ax);
        cla;
        h=scatter(x,y,s,clu,'marker','.');

        colormap(ax,CM);

        h=goodax(ax,'colorbar',{'colormap',CM},'title',{sprintf('nclu = %g',nclu),'fontsize',10},'xycolor','w');
        end

        if nclu==1 || ((nclu>thresholdNCluPlot*GoalNClusters) && (icol>2))
            break;
        end
    end


end
goodax(AX,'xycolor','none');

%% make 
for irow = 1:nrow
    rowNames{irow} = sprintf('minPoint: %g',pMinPoints(irow));
end

for icol = 1:ncol
    colNames{icol} = sprintf('Radius: %.3f',plotRadius(irow,icol));
end
mysubplotsheaders(AX,rowNames,colNames );


%% FIG 2 summmary
figs(2)=makegoodfig('my_test_dbscan_summary','square');

AX2 = mysubplot([],2,2,'xOffset',0.15,'yOffset',0.15);

%%
ax = AX2(1,1);
axes(ax);
try
    c = clusterIdentifiers;
catch
    c = clu*0+1;
end
h=scatter(x,y,s,c,'marker','.');
nclu = numel(unique(c));
CM = jet(nclu);
goodax(ax,'colormap',CM,'axis',{'square' 'tight' },'colorbar',{'colormap',CM},'title',sprintf('nclu = %g',nclu));

%% Best dbscan results
tic;
ax = AX2(2,1);
axes(ax);
cla(ax);
[~,i4best] = min(abs(NCLU(:)-GoalNClusters));
[irow,icol] = ind2sub([nrow ncol],i4best);
bestRadius = plotRadius(icol(1));
bestMinPoints = pMinPoints(irow(1));

bestRadius = clusterDBSCAN.estimateEpsilon(xy,bestMinPoints,bestMinPoints+5);

clu = dbscan(xy,bestRadius,bestMinPoints);% (Radius,minpoints)

clu(clu==-1)=mymax(clu)+1;
if any(clu==0)
    clu = clu+1;
end
pclu = unique(clu);
h=scatter(x,y,s,clu,'marker','.');
nclu = numel(pclu);
CM = jet(nclu);
goodax(ax,'colormap',CM,'axis',{'square' 'tight' },'colorbar',{'colormap',CM},'title',sprintf('nclu = %g ,\n bestRadius = %.3f ,\n bestMinPoints = %g',nclu,bestRadius,bestMinPoints));
toc;

%%
ax = AX2(1,2);
axes(ax);
imagesc(plotRadius,pMinPoints,NCLU);
set(ax,'ydir','reverse')
CM = jet(thresholdNCluPlot*GoalNClusters);
ylab = sprintf('minnclu = %g , max nclu = %g',mymin(NCLU),mymax(NCLU));
goodax(ax,'colormap',CM,'axis',{'square' 'tight' },'ylabel','minPoints','xlabel','Radius','colorbar',{'colormap',CM,'ylabel',ylab},'title',sprintf('Goal nclusters = %g',GoalNClusters));

%% 

ax = AX2(2,2);
axes(ax);
keyboard

% 
% clusterer = clusterDBSCAN('MinNumPoints',bestMinPoints,'Epsilon',bestRadius,'EnableDisambiguation',false);
% [idx,cidx] = clusterer(xy);
% pclu = unique(idx);
% nclu = numel(pclu);
% plot(clusterer,xy,idx)