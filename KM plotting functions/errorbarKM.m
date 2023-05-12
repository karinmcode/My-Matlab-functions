function [err,stats,varargout]=errorbarKM(x,y,varargin)
%% function [err,stats,[hInd]]=errorbarKM(x,y,{'horizontal', 'stats','ind'})
% variable input arguments order matters
stats=[];
nobs= size(y,1);
ngrp = numel(x);

Orientation = 'horizontal';
if ~isempty(varargin)
if contains(varargin{1},'horizontal')
    Orientation = 'horizontal';
elseif contains(varargin{1},'vertical')
    Orientation = 'vertical';
end
end

if isempty(varargin)
    se = myste(y,1);
    err=errorbar(x,mean(y,1,'omitnan'),se,'linewidth',2,'color','k');
    return;
end

if isempty(varargin{1})
    se = myste(y,1);
    err=errorbar(x,mean(y,1,'omitnan'),se,'linewidth',2,'color','k')
else
    ax = gca;
    hold(ax,'on')
    if  any(contains(varargin{1},{'individuals' 'ind'}))
        hInd = gobjects(nobs,1);
        for i=1:nobs
            hInd(i)=plot(ax,x,y(i,:),'-','color',[1 1 1]*0.5);
           
        end
        if nargout>0
            varargout(1)={hInd};
        end
    end
    
    switch Orientation
        case 'horizontal'
            err=errorbar(x,mean(y,1,'omitnan'),myste(y,1),'vertical','linewidth',2,'color','k');
        case 'vertical'
            err=errorbar(mean(y,1,'omitnan'),x(:),myste(y,1),'horizontal','linewidth',2,'color','k');
    end
    
    
    if any(contains(varargin{1},'stats'))
        Groups = repmat(x(:)',nobs,1);
        inonan = ~any(isnan(y),2);
        y = y(inonan,:);
        Groups = Groups(inonan,:);
        Y=y(:);
        Groups=Groups(:);
        pGroups = x;
        
        isPaired= any(contains(varargin{1},'paired'));
        
        stats=KMStats(gca,x,Y,Groups,'groupOrder',pGroups,'isPaired',isPaired,'Orientation','vertical');
        
     end
    hold(ax,'off')
end


end
