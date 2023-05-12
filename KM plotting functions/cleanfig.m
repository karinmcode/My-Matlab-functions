function cleanfig

F=gcf;
% make figure nice
set(F,'color','w');
allFigs = findobj('type','figure');
FigNames = {allFigs.Name};
iFig = contains(FigNames,'GUI_');
GUI = allFigs(iFig);
F.Position(1) = GUI.Position(1)+GUI.Position(3);
F.Position(2) = GUI.Position(2);
% make axes nice
AX=findobj(F,'type','axes');
diground = @(x,d) round(x*10^d)/10^d;

for iax =1:numel(AX)
    ax = AX(iax);
    % font properties
    set(ax,'box','off','fontsize',12,'FontName','arial')
    
    %                 % make ax lim round
    %                 XLIM = xlim;
    %                 XTICK= get(AX(iax),'xtick');
    %                 STEP = round(mean(diff(XTICK)));
    %
    %                 set(AX(iax),'xlim',diground(XLIM,0) )
    
end

legs=findobj(F,'type','legend');
set(legs,'box','off')
try
if isempty(findobj(F,'Type','UIControl','String','SaveFig'))
    T.AddSaveButton;
end
end