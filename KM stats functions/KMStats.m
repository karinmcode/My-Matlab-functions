function stats=KMStats(varargin)
% stats=KMStats(ax,Xloc,Values,Groups,['groupOrder'],['relevantComp'],['isPaired'],['Orientation'],['doplot'],['plotbars'])
% old function stats=KMStats(ax,Xloc,Y,Groups,groupOrder,relevantComp,isPaired,Orientation,varargin)
% REQUIRED INPUTS:
% ax: axes or empty if no plotting
%
% OPTIONAL INPUTS:
% X: x location for each group on plot
% Values: vertical vector with all data points
% Groups: vertical vector with all data points groups
%
% PARAMETER INPUTS:
% groupOrder: groupOrder on plot
% relevantComp: relevant group statistical comparisons to plot
% isPaired: is data paired
% Orientation: horizontal or vertical errorbars plot
% PlotNonSig:
% PlotTestName:
% PlotTestResults:
% DispTestResults: in command window
% plot test name
% extractDataFromCurrentAxe
% postHocTestName
% forceTestType
% doplot
% plotbars: only add 1 star above group that is sig diff from other

% OUTPUTS:
% stats.



params = CheckKMStatsInputs(varargin);
struct2var(params,'params');

Alphas = [0.05 1E-2 1E-3 ];
ngr = numel(groupOrder);


%% First test if data isParametric
isParametric =testIfParametric(Y,Groups);
stats.isParametric = isParametric;

%% 2 GROUPS
if ngr==2
    c = nan(1,3);
    c(1,1:2)=X;
    [g1, g2]=get2groups(Y,Groups,groupOrder);


    if isParametric==0
        if isPaired==0
            c(1,3) = ranksum(g1,g2);
            testName = 'ranksum';
        else
            c(1,3) = signrank(g1,g2);
            testName = 'signrank';
        end
    else
        if isPaired==0
            [~,c(1,3)] = ttest2(g1,g2);
            testName = 't-test';
        else
            [~,c(1,3)] = ttest(g1,g2);
            testName = 'paired t-test';
        end
    end
    stats.pval = c(1,3);
    stats.testName = testName;
    ncomp = size(c,1);

    %% MORE THAN 2 GROUPS
else
    isHomoscedastic = testIfHomoscedasticity(Y,Groups);

    %  Box-Cox transformation to make data normaly distributed, src: https://stats.stackexchange.com/questions/192369/box-cox-transformation-for-repeated-measures-anova-ranova-in-r
    % with linear mixed models: here are relevant paper and post .
    % https://www.jstor.org/stable/3559673?seq=1#page_scan_tab_contents;

    %postHocTestName= 'tukey-kramer' ;%'bonferroni'
    if strcmpi(forceTestType,'anova')
        isPaired = 0;
        isParametric =1;
        isHomoscedastic = 1;
    end
    if isParametric==1  && isHomoscedastic==1

        if isPaired==0
            testName = 'anova';
            [stats.pval,stats.table,stats.multcomp_stats] = anova1(Y,Groups,'off');
            [c,stats.table] = multcompare(stats.multcomp_stats,'CType',postHocTestName,'display','off');
        else
            % do do
            testName = 'ranova';
            isnonan = ~isnan(Y);
            Y = Y(isnonan);
            Groups = Groups(isnonan);
            [stats.pval,stats.table,c] = ranovaKM(Y,Groups);
            % https://www.mathworks.com/matlabcentral/answers/348647-how-to-make-all-possible-pairwise-comparisons-for-the-three-way-repeated-measures-anova
        end

    else % non parametric
        if isPaired==0
            [stats.pval,stats.table,stats.multcomp_stats] = kruskalwallis(Y,Groups,'off');%or ANOVA that is robust to large deviations from normality
            [c,stats.table] = multcompare(stats.multcomp_stats,'CType',postHocTestName,'display','off');
            testName = 'kruskalwallis';
        else
            testName = 'ranova';
            [stats.pval,stats.table,c] = ranovaKM(Y,Groups);
        end

    end

    %% get groups sorting after anova or other test
    try
        try
            all_grp = stats.multcomp_stats.gnames;
        catch err
            disp( stats.multcomp_stats.gnames);
            rethrow(err);
            keyboard;
        end
    catch
        all_grp = groupOrder;
    end

    %% sort groups as imposed by groupOrder

    % make sure groupOrder and anogr
    if iscell(all_grp) && isa(groupOrder,'double')
        groupOrder = cellfun(@(x) num2str(x),num2cell(groupOrder),'uniformoutput',0);
    end


    ntotalgr = size(all_grp,1);
    gridx = nan(ntotalgr,1);
    for igr=1:ntotalgr
        thisgr = all_grp(igr);
        try
            grpos=find(strcmp(thisgr,groupOrder));
        catch
            grpos=find(thisgr==groupOrder);
        end
        if ~isempty(grpos)
            gridx(igr) = grpos;
        end
    end


    % correct group ids in comparison matrix
    ncomp = size(c,1);
    for icomp =1:ncomp
        newids = gridx(c(icomp,1:2));
        if ~any(isnan(newids))
            c(icomp,1:2)=gridx(c(icomp,1:2));
        else
            c(icomp,1:2)=nan;
        end
    end
    c = c(~isnan(c(:,1)),:);
    ncomp = size(c,1);
    %% BONFERONNI CORRECTION
    Alphas = [0.05 1E-2 1E-3 ]/ncomp;
    stats.Alphas=Alphas;
    %% select comparisons to show on graph
    if ~isempty(relevantComp)
        i4keep = ismember(c(:,1:2),relevantComp,'rows');
        c = c(i4keep,:);
        ncomp = size(c,1);
    end



end

stats.testName=testName;

%% Make groups cell array for sigstar function input
stats.sigdata.grp_pairs = cell(ncomp,1);% groups cell array
stats.sigdata.pval = nan(ncomp,1);% p values
stats.sigdata.comparisons = c;
for icomp = 1:ncomp
    stats.sigdata.grp_pairs{icomp} = c(icomp,1:2);
    stats.sigdata.pval(icomp) = c(icomp,end);
end

%% Only display significant pairs
if params.plotNonSig == false
    isSig=stats.sigdata.pval<=Alphas(1);%alphas(end);
    stats.sigdata.grp_pairs = stats.sigdata.grp_pairs(isSig);
    stats.sigdata.pval = stats.sigdata.pval(isSig);
end
%% ----------
%% PLOTTING

if params.doplot
    axes(ax);


    if params.plotbars
        %% - plot significance bars

        H=sigstar(stats.sigdata.grp_pairs , stats.sigdata.pval , Alphas);

        if params.plotNonSig
            for ih =1:numel(H)
                h = H(ih);
                if isa(h,'matlab.graphics.primitive.Text')%class(h)
                    if isempty(h.String)
                        h.String = 'n.s.';
                    else

                    end
                end
            end
        end

        % fix height of bars
        YData=get(H(:,1),'ydata');
        if iscell(YData)
            inonan = cellfun(@(x) ~any(isnan(x)),YData);
            YData = cell2mat(YData(inonan,:));
        end

        oldYLim=ax.YLim(2);
        newYLim = max(YData(:));
        if newYLim>oldYLim
            ax.YLim(2)=newYLim;
        end
        stats.sigbars=H;
    else
        %% - plot stars without bars
        issig = false(ngr,1);

        nSTD = 1;
        gr_means=groupsummary(Y,Groups,'mean');
        gr_std=groupsummary(Y,Groups,'std');
        thSTD = nSTD*std(gr_means)+mymean(gr_means);
        aboveThreshold = gr_means>=thSTD;
        for igr=1:ngr
            i4gr = any(c(:,1:2)==igr,2);
            pvals = c(i4gr,end);
            if any(pvals<Alphas(1))
            issig(igr)=true;
            gr_mean = gr_means(igr);
            end
        end
        i4stars = issig&aboveThreshold;
        Xstars = find(i4stars);
        vOff  = (max(Y(:))-min(Y(:)))*0.05;
        ChTypes = get(ax.Children,'Type');
        if ~iscell(ChTypes)
            ChTypes = {ChTypes};
        end
        
        ONLY_ERRORBAR= ismember('errorbar',ChTypes) & ~ismember('line',ChTypes);
        if ONLY_ERRORBAR
            err = ax.Children(ismember(ChTypes,'errorbar'));
            errYpos = err.YData+err.YPositiveDelta;
            vOff = min([max([range(err.YData)*0.05 range(ylim)*0.10]) max(ylim)]);
            Ystars = errYpos(i4stars)+vOff;
        else% individuals plots
            Ystars = repmat(max(Y(:))+vOff,numel(Xstars),1);
        end
        hold(ax,'on');
        hstars = text(ax,Xstars,Ystars,'*','fontsize',16,'BackgroundColor','none','HorizontalAlignment','center','VerticalAlignment','middle','color','k','tag','hstars');
        stats.hstars = hstars;

    end

else
    if params.plotbars==0
        nSTD = 1;

        issig = false(ngr,1);
        gr_means=groupsummary(Y,Groups,'mean');
        thSTD = nSTD*std(gr_means)+mymean(gr_means);
        aboveThreshold = gr_means>=thSTD;
        for igr=1:ngr
            i4gr = any(c(:,1:2)==igr,2);
            pvals = c(i4gr,end);
            if any(pvals<Alphas(1))
            issig(igr)=true;
            end
        end
        stats.sigdata.issig_xgrp=issig;
        try
            stats.sigdata.issig_and_AboveTh_xgrp = issig&aboveThreshold;
        end
      
    end
end
end
function    [g1, g2]=get2groups(Y,Groups,pGroups)
if iscell(pGroups)
    i4gr1 = strcmp(Groups,pGroups{1});
    i4gr2 = strcmp(Groups,pGroups{2});
else
    i4gr1 = ismember(Groups,pGroups(1));
    i4gr2 = ismember(Groups,pGroups(2));
end
g1 = Y(i4gr1);
g2 = Y(i4gr2);
end

%% isParametric: Test for normality : One-sample Kolmogorov-Smirnov test
function isParametric =testIfParametric(Y,Groups)

[ind4grp,grp_ids]=findgroups(Groups);
ngrp = numel(grp_ids);
pval = nan(1,ngrp);

for ig=1:ngrp
    i4g = ind4grp==ig;
    n4g = sum(i4g);
    if n4g ==0 || all(isnan(Y(i4g)))
        continue;
    end
    [~,pval(ig)] = kstest(Y(i4g));
end

isParametric =all(pval<=0.05);
end

%% isHomoscedastic
function isHomoscedastic = testIfHomoscedasticity(Y,Groups)
%% Homoscedasticity : Multiple-sample tests for equal variances
% returns a summary table of statistics and a box plot for a Bartlett test of the null hypothesis that the columns of data vector x come from normal distributions with the same variance. The alternative hypothesis is that not all columns of data have the same variance.
pval = vartestn(Y(:),Groups,'display','off');%p should be >alpha
isHomoscedastic =pval<=0.05;
end


%% ranova
function [pval,stats_table,c] = ranovaKM(Y,Groups)
% organize the data in a table
[Groups_num,ugrp] = findgroups(Groups);

ngrp = numel(ugrp);
nrow = ngrp;
ncol = ceil(numel(Y)/ngrp);
grpmat = nan(nrow,ncol);
for igr=1:ngrp
    i4g = Groups_num==igr;
    grpmat(igr,:)=Y(i4g);

end
T = array2table(grpmat');
VariableNames = cellfun(@(x)['Y' num2str(x)] ,num2cell(ugrp),'uniformoutput',0);
T.Properties.VariableNames = VariableNames;
% create the within-subjects design
withinDesign = table(cellfun(@(x) ['Y' num2str(x)] ,num2cell(1:ngrp)','UniformOutput',0),'VariableNames',{'Conditions'});
withinDesign.Conditions = categorical(cellstr(withinDesign.Conditions));

% create the repeated measures model and do the anova
rm = fitrm(T,sprintf('Y1-Y%.0f ~ 1',numel(withinDesign.Conditions)) ,'WithinDesign',withinDesign);
stats_table = ranova(rm,'WithinModel','Conditions'); % remove comma to see ranova's table
pval = stats_table.pValue;
Table = anovaTable(stats_table, 'Measure (units)');
Multcomp_stats= nan;

multcomptable = multcompare(rm,'Conditions');
T =multcomptable;
c = [findgroups(T.Conditions_1) findgroups(T.Conditions_2) T.pValue];
% output a conventional anova table
% disp(anovaTable(AT, 'Measure (units)'));
end

%% ---------------------------------------------------------------------
% Scott's function to create a conventional ANOVA table from the
% overly-complicated and confusing anova table created by the ranova
% function.
function [s] = anovaTable(AT, dvName)
%% anovaTable(AT, 'Measure (units)')
c = table2cell(AT);
% remove erroneous entries in F and p columns
for i=1:size(c,1)
    if c{i,4} == 1
        c(i,4) = {''};
    end
    if c{i,5} == .5
        c(i,5) = {''};
    end
end
% use conventional labels in Effect column
effect = AT.Properties.RowNames;
for i=1:length(effect)
    tmp = effect{i};
    tmp = erase(tmp, '(Intercept):');
    tmp = strrep(tmp, 'Error', 'Participant');
    effect(i) = {tmp};
end
% determine the required width of the table
fieldWidth1 = max(cellfun('length', effect)); % width of Effect column
fieldWidth2 = 57; % field needed for df, SS, MS, F, and p columns
barDouble = sprintf('%s\n', repmat('=', 1, fieldWidth1 + fieldWidth2));
barSingle = sprintf('%s\n', repmat('-', 1, fieldWidth1 + fieldWidth2));
% re-organize the data
c = c(2:end,[2 1 3 4 5]);
c = [num2cell(repmat(fieldWidth1, size(c,1), 1)), effect(2:end), c]';
% create the ANOVA table
s = sprintf('ANOVA table for %s\n', dvName);
s = [s barDouble];
s = [s sprintf('%-*s %4s %11s %14s %9s %9s\n', fieldWidth1, 'Effect', 'df', 'SS', 'MS', 'F', 'p')];
s = [s barSingle];
s = [s, sprintf('%-*s %4d %14.3f %14.3f %10.3f %10.4f\n', c{:})];
s = [s, barDouble];
end


function [params,param_names] = CheckKMStatsInputs(varargin)
varargin = varargin{1};
p = inputParser();
p.CaseSensitive = true;
p.KeepUnmatched = true;
p.PartialMatching = true;
p.addRequired('ax');
p.addOptional('X',nan);
p.addOptional('Y',nan);

% Groups
p.addOptional('Groups',nan);
p.addParameter('groupOrder',nan);
p.addParameter('groupNames','NA');

% RelevantComp
% validRelevantComp= @(x) (isempty(x) || any(size(x)==2));
% autoRelevantComp = zeros(0,2);
% pos = 0;
% for igr =2:NGroups
%     for igr2 = 1:NGroups
%         pos = pos+1;
%         autoRelevantComp(pos,1:2) = [igr igr2];
%     end
% end
% autoRelevantComp = unique(autoRelevantComp,'rows');
p.addParameter('relevantComp',[]);

% IsPaired,
p.addParameter('isPaired',false);

% Orientation of data, not significance bars
p.addParameter('Orientation','Horizontal',@ischar);

% plot non significant
p.addParameter('plotNonSig',false);

% plot test name
p.addParameter('plotTestName',false);

% plotTestResults
p.addParameter('plotTestResults',true);
p.addParameter('extractDataFromCurrentAxe',false);
p.addParameter('dispTestResults',false);
p.addParameter('postHocTestName','tukey-kramer')
p.addParameter('forceTestType','nan')
p.addParameter('doplot',true');

p.addParameter('plotbars',false);
p.addParameter('plottest',false);

p.parse(varargin{:});
params = p.Results;%fieldnames(params)
param_names = p.Parameters;%disp(param_names')
%% ---------------
%% Correct inputs if not set


%% check input ax
if ~isa(params.ax,'matlab.graphics.axis.Axes')
    if isnan(params.ax)
        params.plotTestResults = false;
        params.ax= gca;
    elseif isempty(params.ax)
        params.ax= [];
        params.doplot = false;
    end
end



%% check input X
if any(isnan(params.X))
    pl = findobj(params.ax);
    params.extractDataFromCurrentAxe = all(isnan(params.X)) || all(isnan(params.Y));
    if numel(pl)>1 && params.extractDataFromCurrentAxe
        keyboard;
    end
    params.X = unique(pl.XData);
end
%% check input Y
if ~iscell(params.Y)
    if all(isnan(params.Y) )
        params.extractDataFromCurrentAxe = true;
        params.Y = pl.YData;
    end
end

% maker sure Groups is a numeric vector
Y = params.Y;
Groups = params.Groups;

if iscell(Y)
    cellY = Y;
    %cellGroups = Groups;
    sz = size(Y);
    ngr = numel(cellY);
    Y = [];
    Groups = [];
    for igr = 1:ngr
        Y=cat(1,Y,cellY{igr}(:));
        Groups = cat(1,Groups,igr*ones(numel(cellY{igr}),1));
    end

elseif ismatrix(Y) & ~isvector(Y) & isempty(Groups)

    matY = Y;

    Y = [];
    Groups = [];
    nobs = size(matY,1);
    ngr = size(matY,2);
    for igr = 1:ngr
        Y=cat(1,Y,matY(:,igr));
        Groups = cat(1,Groups,igr*ones(nobs,1));
    end
elseif isvector(Y)
     
   if iscell(Groups)
       if size(Groups,2)>1
        params.groupNames = unique(Groups,"rows","stable");
       else
        params.groupNames = unique(Groups,"stable");
       end
        Groups = findgroups(Groups);%
   else
       if isnan(Groups)% assumes same number of obs for 2 groups
           ngr = 2;
           nobs = size(Y,1)/ngr;
           if nobs ~=round(nobs)
               keyboard;
           end
           Groups = [];
           for igr = 1:ngr
               Groups = cat(1,Groups,igr*ones(obs,1));
           end
       elseif isnumeric(Groups)
           %do nothing
       end
    end
else


end
params.Groups=Groups;
params.Y = Y;

%% check input Groups

if any(isnan(params.Groups))

    keyboard;
    params.Groups = findgroups(params.Groups);
end

%% check input groupOrder
if isnumeric(params.groupOrder)

if any(isnan(params.groupOrder))
    params.groupOrder = findgroups(params.X);
end
else
    params.groupOrder = findgroups(params.X);
end
%% remove nans
inonan=~isnan(Y);
Y =Y(inonan);
Groups = Groups(inonan,:);
params.Y = Y;
params.Groups = Groups;


end