function  H=mysubplotsheaders(AX,rowNames,colNames )
%  H=mysubplotsheaders(AX,rowNames,colNames )
% for debug:
% delete(H.col);
% delete(H.COL)
nrow = size(AX,1);
ncol = size(AX,2);
w =0.3;
h = 0.1;



%% COLUMNS HEADERS

%check if common prefix
prefix=mygetprefix(colNames);
if ~isempty(prefix)
    NAME = prefix;
else
    NAME = '';
end


ax = AX(1);
axp = ax.OuterPosition;
YcolHead = mymin([axp(2)+axp(4)*1.5 1-h]);

H.col = gobjects(ncol,1);
for icol = 1:ncol
    ax = AX(1,icol);
    p = ax.OuterPosition;
    xpos = max([p(1) 0.001]);
    ypos = YcolHead ;
    t= annotation('textbox',[xpos ypos min([p(3) 1]) h]);
    thisName = colNames{icol};
    if contains(thisName,NAME)
        thisName = replace(thisName,NAME,'');
    end
    set(t,'linestyle','none','fontsize',14,'color',[1 1 1]*0.001,'FontWeight','bold','String',thisName,'VerticalAlignment','top','HorizontalAlignment','center',...
        'position',[xpos ypos p(3) h],'tag','columnHeaders');
    H.col(icol) =t;
end

% delete(findall(gcf,'type','textboxshape'))

% add left corner annotation
H.COL= annotation('textbox',[0 ypos 0.5 h],'String',NAME,'tag','columnHEADER');
set(H.COL,'linestyle','none','fontsize',14,'color',[1 1 1]*0.001,'FontWeight','bold','VerticalAlignment','top','HorizontalAlignment','left')

%% ROW HEADERS

%check if common prefix
prefix=mygetprefix(rowNames);
if ~isempty(prefix)
    NAME = prefix;
else
    NAME = '';
end

% add prefix in left corner below column header annotation
H.ROW= annotation('textbox',[0 H.COL.Position(2) 0.5 h],'String',NAME,'tag','columnHEADER');
set(H.ROW,'position',[0 H.COL.Position(2) 0.5 h],'linestyle','none','fontsize',14,'color',[1 1 1]*0.001,'FontWeight','bold','VerticalAlignment','bottom','HorizontalAlignment','left')

%      delete(findall(gcf,'type','textboxshape'))

FONTSIZE = 0.02;% provisory
ax = AX(1);
axp = ax.Position;
XHead = mymax([axp(1)-0.8*axp(3) 0.0001]);

H.row = gobjects(nrow,1);
for irow = 1:nrow
    ax = AX(irow,1);
    p = ax.Position;
    xpos = XHead;
    ypos = p(2)+p(4)/2-FONTSIZE ;

    t= annotation('textbox',[xpos ypos axp(1) 0.01]);
    thisName = rowNames{irow};
    if contains(thisName,NAME)
        thisName = replace(thisName,NAME,'');
    end
    set(t,'linestyle','none','fontsize',14,'color',[1 1 1]*0.001,'FontWeight','bold','String',thisName,'VerticalAlignment','bottom','HorizontalAlignment','right',...
        'position',[xpos ypos axp(1) h],'tag','columnHeaders');
    H.row(irow) =t;
end

% delete(findall(gcf,'type','textboxshape'))


