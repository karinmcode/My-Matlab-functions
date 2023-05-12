function [f,pExplained]= mypcaplots(obs,explained,GrpIds,GrpNames,coeff,score,varnames)
%  f= mypcaplots(S,explained,grp,coeff,score,varnames)
%{

%}
ntopvar = 5;


if ~iscell(varnames)
    varnames = mynum2str(varnames,'i%g','cellstr');
end

f=makegoodfig('PCA analysis','slide');

ncol = 3;
nrow = 2;
ax=subplot(nrow,ncol,5,'replace');
if ~isempty(obs)
    obs_S = zscore(obs,0,1);
    [U,S,V] = svd(obs_S,'econ');
    semilogy(diag(S),'k-o')
    ylabel('singular values');xlabel('PC#');title('Singular values')

    subplot(nrow,ncol,6,'replace')
    pExplained =cumsum(diag(S))./sum(diag(S));
    plot(pExplained ,'k-o')
    ylabel('percent of variance captured');xlabel('PC#');title('Cumulative singular values')
     
else
    nPCs = size(score,2);
    hold(ax,'on');
    bar(explained(1:nPCs))
    ylabel('Variance Explained (%)')
    yyaxis right
    pExplained = cumsum(explained(1:nPCs));
    pl=plot(1:nPCs, cumsum(explained(1:nPCs)), '.-', 'MarkerFaceColor', 'r');
    h = gca;
    h.YAxis(1).Limits = [0 max(explained(1:nPCs))];
    h.YAxis(2).Limits = [0 100];
    h.YAxis(2).Color = pl.Color;
    h.YAxis(2).TickLabel = strcat(h.YAxis(2).TickLabel, '%');
    xlabel('Principal Component')
end

%% 2 PCAs
sz=fprintf('plotting PCAs ...');


%% biplot 2D
comp = [1 2; 2 3; 1 3];
ncomp = size(comp,1);
axnb = 1:3;
ObsLabels = num2str(GrpIds);
nobs = size(score,1);
i4obs =1:nobs;

for icomp = 1:ncomp

    sub=subplot(nrow,ncol,axnb(icomp),'replace');
    hold on;

    [bestVar,i4bestVar]=sort(coeff(:,comp(icomp,1)),'descend');
    i4var = i4bestVar(1:ntopvar);%top 10 var

    % coeff: nvar x nPCs
    % scores: nobs x nPCs
    % varLabels = 1 x nvar
    % obslabels = 1 x nobs
    h=biplot(coeff(i4var,comp(icomp,:)),'Scores',score(i4obs,comp(icomp,:)),'VarLabels',varnames(i4var),'ObsLabels',ObsLabels(i4obs));
   
    
    hPt = findobj(h,'tag','obsmarker');
    grpObs = findgroups(ObsLabels(i4obs));    %r2015b or later - leave comment if you need an alternative
%     grp(isnan(grp)) = max(grp(~isnan(grp)))+1;
    grpID = 1:max(grpObs);
    % assign colors and legend display name
    ngrp = length(unique(grpObs));
    clrMap = lines(ngrp);   % using 'lines' colormap
    if ngrp ==1
        grpObs = 1:nobs;
        ngrp = nobs;
        clrMap = turbo(nobs);   % using 'lines' colormap
        colorIsInd = 1;
        colormap(sub,clrMap)
    else
        colorIsInd = 0;
    end

    % color dots with group color
    for i = 1:ngrp
        set(hPt(grpObs(i4obs)==i), 'Color', clrMap(i,:))
    end
    
    % add legend/colorbar to identify cluster 
    if colorIsInd
        if icomp==ncomp
        p=sub.Position;
        set(sub,'PositionConstraint','InnerPosition')
        cb=colorbar(sub);
        set(sub,'position',p)
        caxis(sub,[0 nobs])
        set(cb,'limits',[0 nobs])
        title(cb,{'obs' 'ind'})
        end
    else
        if icomp ==1
            [~, unqIdx] = unique(grpObs);
            legend(hPt(unqIdx),GrpNames,'location','best')
        end
    end

    % xy labels
    [pexplained,i4var]=max(coeff(:,comp(icomp,1)));
    xlabel(sprintf('PC%d (%.0f %% expl. by %s)',comp(icomp,1),pexplained*100,varnames{i4var}));
    [pexplained,i4var]=max(coeff(:,comp(icomp,2)));
    ylabel(sprintf('PC%d (%.0f %% expl. by %s)',comp(icomp,2),pexplained*100,varnames{i4var}));
    
    drawnow;
    pause(0.01);
end

%% get back to data to see what matters to PC1 and PC2
sub=subplot(nrow,ncol,4,'replace');
hold on;

if ~isempty(obs)
[pexplained,i4PC1]=max(coeff(:,1));
PC1 = obs(:,i4PC1);
[pexplained,i4PC2]=max(coeff(:,2));
PC2 = obs(:,i4PC2);

grpCo = nan(nobs,3);
for ich =1:3
grpCo(GrpIds==1,ich)=clrMap(1,ich);
grpCo(GrpIds==2,ich)=clrMap(2,ich);
end
sc=scatter(PC1,PC2,GrpIds*0+10,grpCo,'o');
colormap(gca,clrMap);
[rho,pval] = corr(PC1,PC2);
pf=polyfit(PC1,PC2,1);
x = [min(PC1) max(PC1)];
y = polyval(pf,x);
plot(x,y,'-r');

xlabel(varnames{i4PC1})
ylabel(varnames{i4PC2})
title(sprintf('[rho,pval]= %.2f , %.3f',rho,pval))
if strcmp(varnames{i4PC2},'Depth')
   set(gca,'ydir','reverse') 
end
end

end