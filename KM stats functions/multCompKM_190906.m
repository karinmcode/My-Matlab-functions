function stats=multCompKM_190906(M,varargin)

%% stats = multCompKM(M,'paired','normalised')
% tests for normality, Homoscedasticity and chooses the right test to
% perform according to data input paired or not
% M = Matrix (# reps-by-#conditions) or Cell (1-by-#conditions)
% Nans are accepted
% Cell can contain a different number of repetitions
% Ctrl should be index 1.
% Output = Structure stats
% - pNorm : pvalues for normality of distribution
% - Normality : false or true
% - pHomo : p value for homoscedasticity test
% - Homoscedasticity : false or true
% - multcompTable : ngroups-by-6 matrix (last column for p values)
% - sigstarData : Make groups cell array for sigstar function input only
% for significant group compairison
% - sigstarDataAll : Make groups cell array for sigstar function input


%% Format data
if iscell(M) % If M is a cell make a matrix out of it
    
    % check if empty cells
    iE = cellfun('isempty',M);
    M(iE)={nan(2,1)};
    
    ngroups = numel(M);
    reps = cellfun(@(x) numel(x),M);
    maxreps = max(reps);
    testData = nan(maxreps,ngroups);
    for ig = 1:ngroups
        testData(1:reps(ig),ig)=M{ig};
    end
    M=testData;
end

%% General variables

alphas=[0.001 0.01 0.05];
if nargin<2
    ispaired =0;
    isnormalised = 0;% not normalised by columns 1
elseif nargin==2
    ispaired = ismember(varargin{1},{'paired'});
    isnormalised = 0;% not normalised by columns 1
else
    ispaired = ismember(varargin{1},{'paired'});
    isnormalised = ismember(varargin(2),{'norm','normalised','normalized'});% not normalised by columns 1
end

if isnormalised==1
    M = M(:,2:end);
end

reps = size(M,1);
ngroups = size(M,2);
stats = struct();


%% Test for normality : One-sample Kolmogorov-Smirnov test
stats.pNorm = nan(1,ngroups);
for ig=1:ngroups
    try
%     [~,stats.pNorm(ig)] = kstest(M(:,ig));
    [~,stats.pNorm(ig)] = lillietest(M(:,ig));
    catch
        continue
    end
end
stats.Normality = all(stats.pNorm<=alphas(end));

%% Homoscedasticity : Multiple-sample tests for equal variances
% returns a summary table of statistics and a box plot for a Bartlett test of the null hypothesis that the columns of data vector x come from normal distributions with the same variance. The alternative hypothesis is that not all columns of data have the same variance.
stats.pHomo = vartestn(M,'display','off');%p should be >alpha
stats.Homoscedasticity = stats.pHomo<=alphas(end);%p should be >alpha
stats.Parametric = stats.Normality&stats.Homoscedasticity;

%% PAIRED OR INDEPENDENT DATA

ispaired=0;
stats.Parametric = 1;

switch ispaired
    
    case 1 % Repeated measures
        
        switch stats.Parametric
            
            case 1 % %% Ranova test : a parametric repeated measures ANOVA test
                anoData = reshape(M,numel(M),1);
                foo = 'abcdefghijklmdopqrstuvwxyz';
                groups = repmat(foo(1:ngroups),reps,1);
                groups = reshape(groups,numel(groups),1);
                figure;
                % Friedman doesn't accept nans, exclude animal if nan
                FriedmanData = M;
                [r,c]=find(isnan(FriedmanData));
                FriedmanData(unique(r),:) = [];
                try
                [~,~,stats.friedman] = friedman(FriedmanData,1,'off');
                [stats.multcompTable,~,hFig] = multcompare(stats.friedman);
                close(hFig)
                catch
                    stats.multcompTable= nan(2,6);
                end
                
                
            case 0 %% Friedman test : a non-parametric repeated measures ANOVA test (ranking technique)
                anoData = reshape(M,numel(M),1);
                foo = 'abcdefghijklmdopqrstuvwxyz';
                groups = repmat(foo(1:ngroups),reps,1);
                groups = reshape(groups,numel(groups),1);
                figure;
                % Friedman doesn't accept nans, exclude animal if nan
                FriedmanData = M;
                [r,c]=find(isnan(FriedmanData));
                FriedmanData(unique(r),:) = [];
                try
                [~,~,stats.friedman] = friedman(FriedmanData,1,'off');
                [stats.multcompTable,~,hFig] = multcompare(stats.friedman);
                close(hFig)
                catch
                    stats.multcompTable= nan(2,6);
                end
        end
        
    case 0 % not paired, independent
        
        % Reshape data
        anoData = reshape(M,numel(M),1);
        foo = 'abcdefghijklmdopqrstuvwxyz';
        groups = repmat(foo(1:ngroups),reps,1);
        groups = reshape(groups,numel(groups),1);
        clear foo
        figure;
        
        switch stats.Parametric
            
            case 1 %% ANOVA1 : One-way analysis of variance
                [~,~,stats.anova1] = anova1(anoData,groups,'off');
                [stats.multcompTable,~,hFig] = multcompare(stats.anova1,'estimate','column');
                
            case 0 %% Kruskal-Wallis test (non parametric)
                if sum(isnan(anoData)==0)==1
                    stats.kruskalwallis = nan;
                    stats.multcompTable = nan(2,6);
                    hFig=figure;
                else
                    [~,~,stats.kruskalwallis] = kruskalwallis(anoData,groups,'off');
                    try
                    [stats.multcompTable,~,hFig] = multcompare(stats.kruskalwallis);
                    catch
                        hFig=gcf;
                        stats.multcompTable=nan(2,6);
                    end
                end
        end
        try
            close(hFig)
        end
        
end


%% Make groups cell array for sigstar function input
ngroups = size(stats.multcompTable,1);
stats.sigstarDataAll.input1 = cell(ngroups,1);% groups cell array
stats.sigstarDataAll.input2 = nan(ngroups,1);% p values


for i = 1:ngroups
    if isnan(stats.multcompTable)
        continue
    end
    switch isnormalised
        case {'default',0,'notnorm'}
            stats.sigstarDataAll.input1{i} = stats.multcompTable(i,1:2);
            stats.sigstarDataAll.input2(i) = stats.multcompTable(i,6);
        
        case {'norm',1,'normalised','normalized'}
            stats.sigstarDataAll.input1{i} = stats.multcompTable(i,1:2)+1;
            stats.sigstarDataAll.input2(i) = stats.multcompTable(i,6);
    end
end

%% Only display significant pairs
isSig=stats.sigstarDataAll.input2<=0.15;%alphas(end);
stats.sigstarData.input1 = stats.sigstarDataAll.input1(isSig);
stats.sigstarData.input2 = stats.sigstarDataAll.input2(isSig);