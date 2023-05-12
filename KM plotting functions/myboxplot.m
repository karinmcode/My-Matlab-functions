function [hBO,varargout]=myboxplot(X,Y,pX,pXNames, varargin)
% hBO=myboxplot(X , Y, pX, pXNames varargin);
% hBO=myboxplot(X , Y, pX, pXNames, [sorting],[stats],[sort_dir]);

% or
% hBO=myboxplot(cellData,[],[],pXNames,varargin);

% 4 required inputs
% X : group ids
% Y : values
% pX : possible group ids sorted by order of appearance on plot. Leave
% empty if not sorting needed
% pXNames : possible group names
% optional inputs:
% 'sorting','on'
%
% supports sorting without having to do annoying categorical variable
% supports cell input
% add stats
% adapt for string and numeric values

ax = gca;

% if data input is a cell with columns = groups
if iscell(X)
    if isnumeric(X{1})
        nX = numel(X);
        n4X = cellfun(@(x) numel(x),X);
        cellData = X;
        pX = 1:nX;
        Y = [];
        X = [];
        for ix = 1:nX
            Y= vertcat(Y,cellData{ix});
            X = vertcat(X,ix*ones(n4X(ix),1));
        end
    end
end

params=checkInputArguments(varargin);



[i4x] = findgroups(X);
nX = numel(pX);
dataCell = cell(1,nX);
hold on;

% compute median for sorting
if isfield(params,'sorting')
    Y_med_xgr = nan(1,nX);
    for i = 1:nX
        thi_ty = pX(i);
        if isnumeric(thi_ty)
            i4 = X==thi_ty;
        else
            i4 = strcmp(X,thi_ty);
        end
        Y_med_xgr(i) = mymedian(Y(i4));
    end
    if isfield(params,'sort_dir')
        sort_dir = params.sort_dir;
    else
        sort_dir ='descend';
    end
    % sorting
    [~,isort]=sort(Y_med_xgr,sort_dir);
    CAT = categorical(X,pX(isort),pXNames(isort));

    hBO_lame=boxplot(Y,CAT,"Orientation",params.orientation);
    %hBO=boxchart(CAT,Y);% cannot deal with line in the background
elseif ~isfield(params,'sorting') & ~isempty(pX) & ~isempty(pXNames)
    CAT = categorical(X,pX,pXNames);
    hBO_lame=boxplot(Y,CAT,"Orientation",params.orientation);
    %hBO=boxchart(CAT,Y);% cannot deal with line in the background
else
    hBO_lame=boxplot(Y,X,"Orientation",params.orientation);
    %hBO=boxchart(X,Y);% cannot deal with line in the background
end
hBO_lame = handle(hBO_lame);
%tags = get(hBO_lame(:,1),'tag');
% make boxplot handles properly
hBO = struct();% hwhisker;hbox;hmedian;houtliers;hnotch
hBO.WhiskerMax = hBO_lame(1,:);
hBO.WhiskerMin = hBO_lame(2,:);% hwhisker;hbox;hmedian;houtliers;hnotch
hBO.Whiskers = hBO_lame(1:2,:);% hwhisker;hbox;hmedian;houtliers;hnotch

hBO.UpperAdjacentValue = hBO_lame(3,:);
hBO.LowerAdjacentValue = hBO_lame(4,:);
hBO.Box = hBO_lame(5,:);
hBO.Median = hBO_lame(6,:);
hBO.Outliers = hBO_lame(7,:);

try
    hBO.Notch = hBO_lame(8,:);
end
%

set(hBO.Box,'color',[1 1 1]*0.001);
co = [1 1 1]*0.49;
set(hBO.Outliers,'color',[1 1 1]*0.002,'marker','.','color',co,'markerfacecolor',co,'markeredgecolor',co)
set(hBO.UpperAdjacentValue,'color',[1 1 1]*0.003,'linestyle','-')
set(hBO.LowerAdjacentValue,'color',[1 1 1]*0.005)
set(hBO.Median,'color',[1 0 0]*0.99,'linewidth',1.5)
set(hBO.Whiskers,'linestyle','-')

% add patch
for i=1:numel(hBO.Box)
    hBO.Patch(i) = patch(hBO.Box(i).XData,hBO.Box(i).YData,'k','FaceAlpha',0.5);
end
set(hBO.Patch,'FaceAlpha',0.2)

% store in userdata
UD.h_boxplot = hBO;

if isfield(params,'stats')

    stats=KMStats(gca,1:nX,Y,X,'groupOrder',pX,'doPlot',true,'plotbars',true);
    UD.stats = stats;
    varargout{1} = stats;
end

if isfield(params,'effectsize')

    [MEANS,group_names,cnt] = groupsummary(Y,X,"mean");
    [~,i4min] = mymin(MEANS);
    [~,i4max] = mymax(MEANS);
    if iscell(group_names)
        stats.effectSize = meanEffectSize(Y(strcmp(X,group_names{i4max})),Y(strcmp(X,group_names{i4min})),'effect','robustcohen');
    else
        stats.effectSize = meanEffectSize(Y(X==i4max),Y(X==i4min),'effect','robustcohen');
    end
    UD.stats = stats;

    varargout{1} = stats;
end


% add userdata
ax.UserData = UD;
end


%% params=checkInputArguments(varargin);
function params=checkInputArguments(varargin)
params = struct();
varargin = varargin{1};
if isempty(varargin)
    return
end
p = inputParser;
p.KeepUnmatched = true;
parse(p,varargin{:})%p.Results
params0 = p.Unmatched;
f = fieldnames(params0);
for i = 1:numel(f)

    params.(lower(f{i}))=params0.(f{i});
end

if ~isfield(params,'orientation')
    params.orientation = 'vertical';
end

end