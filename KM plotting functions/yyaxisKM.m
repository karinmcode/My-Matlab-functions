function [pL,leg]=yyaxisKM(ax,xxdata,yydata,sides,colors,Xlabel , ylabels)

axes(ax)
yyaxis 'left'
cla;
yyaxis 'right'
cla;


hold on;
ii =0;
n = numel(sides);
pL = gobjects(n,1);

for iside = 1:2
    if iside==1
        yyaxis 'left'
        i4=find(sides==-1);
    else
        yyaxis 'right'
        i4=find(sides==1);
    end
    
    
    for i=i4(:)'
        ii=ii+1;
        pL(ii)=plot(xxdata,yydata(:,i),'-','color',colors(i));
        set(gca,'ycolor',colors(i))
        ylabel(ylabels{i});
        
    end
    MIN = nanmin(yydata(:,i4),[],'all');
    MAX = nanmax(yydata(:,i4),[],'all');
    dM = MAX-MIN;
    if iside==1
    YLIM=[MIN MIN+dM*2];
    else
    YLIM=[MAX-dM*2 MAX];
    end
    ylim(gca,YLIM);
end
xlabel(Xlabel);
if any([sum(sides==-1) sum(sides==1)>1])
    leg=legend(pL,ylabels);
else
    leg=nan;
end