function [f,AXlist,i4row,i4col,xpos,ypos,ANN,i4fig,AXrcf]=preplotXfigs(nrow,ncol,Nplots,varargin)
% [f,AXlist,i4row,i4col,xpos,ypos,ANN,i4fig,AXrcf]=preplotXfigs(nrow,ncol,Nplots,varargin)
% varargin{1} = groupedAxes = [group_type group_n]
nplot = ncol*nrow;
nfig = ceil(Nplots/nplot);
if ncol ==1
    xpos = 0.15;
else
    xpos = linspace(0.10,1-1.1/ncol,ncol);
end
ypos = linspace(1-1.1/nrow,0.05,nrow);

if ~isempty(varargin)
    group = char(varargin{1});
    group_type=group(1);
    group_n=str2double(group(2));
    switch group_type
        case {'v' 'r'}
            Nplots=nfig*nplot;
        case 'h'
            Nplots=nfig*nplot;
    end
end


W = 0.65/ncol;
H = 0.65/nrow;
cnt=1;
f= gobjects(nfig,1);
AXlist = gobjects(Nplots,1);
AXrcf = gobjects(nrow,ncol,nfig);
ANN = gobjects(nfig,1);
i4row = nan(Nplots,1);
i4col = nan(Nplots,1);
i4fig = nan(Nplots,1);
for ifig = 1:nfig
    f(ifig)= makegoodfig(sprintf('fig%g_%g',ifig,nfig),'slide');
    set(f(ifig),'visible','off');
    
    for irow = 1:nrow
        for icol = 1:ncol
            if cnt<=Nplots
                AXlist(cnt)=axes('position',[xpos(icol) ypos(irow) W H]);
                AXrcf(irow,icol,ifig)=AXlist(cnt);
                i4row(cnt) = irow;
                i4col(cnt) = icol;
                i4fig(cnt) = ifig;
                cnt=cnt+1;
            end

        end

    end
    Opt.fig = sprintf(' %g/%g',ifig,nfig);
    ann =add_analysis_params(f(ifig),Opt);
    ANN(ifig)=ann;
end
set(f,'visible','on');
end
