function stats = anova1KM_190906(M,varargin)
%% stats = anova1KM(M,factorsCols,factorsRows)
% tests for normality, Homoscedasticity and chooses the right test to
% perform
% M # reps-by-#factorsCols
% factorsCols ={'Off' 'vib' 'del' 'ans'}
% factorsRows ={'PullTrials' 'PushTrials'}
alphas=[0.001 0.01 0.05];
reps = size(M,1);
ngroups = size(M,2);
stats = struct('cCols',[]);
%% Test for normality : One-sample Kolmogorov-Smirnov test
pValks = nan(1,ngroups);
for ig=1:ngroups
    [h,pValks(ig)] = kstest(M(:,ig));
end
%% Homoscedasticity : Multiple-sample tests for equal variances
% returns a summary table of statistics and a box plot for a Bartlett test of the null hypothesis that the columns of data vector x come from normal distributions with the same variance. The alternative hypothesis is that not all columns of data have the same variance.
stats.pvartestn = vartestn(M,'display','off');%p should be >alpha


if all(pValks>alphas(3)) || stats.pvartestn<=alphas(3)
    
    %% ANOVA1 : One-way analysis of variance
    anoData = reshape(M,numel(M),1);
    foo = 'abcdefghijklmdopqrstuvwxyz';
    groups = repmat(foo(1:ngroups),reps,1);
    groups = reshape(groups,numel(groups),1);
    figure;
    [p,stats.table,stats.AnoStats] = anova1(anoData,groups,'off');
    
    [stats.cCols,~,hFig] = multcompare(stats.AnoStats,'estimate','column');
    close(hFig)
    pVal = nan(1,ngroups-1);
    for ig=1:ngroups-1
        pVal(ig) = stats.cCols(ig,6);
    end
    nStars = nan(size(pVal));
    nStars(pVal<alphas(3))=1;
    nStars(pVal<alphas(2))=2;
    nStars(pVal<alphas(1))=3;
    stats.nStars = nStars;
    
    % if other comparaisons are significant
    if any(stats.cCols(ngroups:end,6)<=alphas(3))
        disp(stats.cCols(ngroups:end,[1:2 6]))
    end
    
else % use non parametric test
    %% Kruskal-Wallis test
    anoData = reshape(M,numel(M),1);
    foo = 'abcdefghijklmdopqrstuvwxyz';
    groups = repmat(foo(1:ngroups),reps,1);
    groups = reshape(groups,numel(groups),1);
    figure;
    [p,stats.table,stats.AnoStats] = kruskalwallis(anoData,groups,'off');
    [stats.cCols,~,hfig] = multcompare(stats.AnoStats);
    close(hfig)
    
    pVal = nan(1,ngroups-1);
    for ig=1:ngroups-1
        pVal(ig) = stats.cCols(ig,6);
    end
    
    nStars = nan(size(pVal));
    nStars(pVal<alphas(3))=1;
    nStars(pVal<alphas(2))=2;
    nStars(pVal<alphas(1))=3;
    stats.nStars = nStars;
    
    % if other comparaisons are significant
    if any(stats.cCols(ngroups:end,6)<=alphas(3))
        disp(stats.cCols(ngroups:end,[1:2 6]))
    end
    
end