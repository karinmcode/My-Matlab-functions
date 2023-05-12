function [err,stats]=errorbarXgrps(x,Y,Groups,varargin)
%% function [err,stats]=errorbarKM(x,y,{'horizontal', 'stats'})
stats=[];
ngrp = numel(x);
M = nan(ngrp,1);
S = nan(ngrp,1);
for igr=1:ngrp
    i4gr=Groups==igr;
    nobs = sum(i4gr);
    y = Y(i4gr);
    M(igr)=nanmean(y);
    if nobs>10000
        S(igr) = nanstd(y,1);
    else
        S(igr) = nanstd(y,1)/sqrt(nobs);
    end
end
if isempty(varargin)
    err=errorbar(x,M,S,'linewidth',2,'color','k');
else
    if any(contains(varargin{1},'horizontal'))
        err=errorbar(x,M,S,'horizontal','linewidth',2,'color','k');
    else
        err=errorbar(M,x(:),S,'vertical','linewidth',2,'color','k');
    end
    
    
    if any(contains(varargin{1},'stats'))
        Y=Y(:);
        Groups=Groups(:);
        pGroups = unique(Groups);
        stats=KMStats(gca,x,Y,Groups,pGroups,[],1,'vertical');
        
    end
end


end
