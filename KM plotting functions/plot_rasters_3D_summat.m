function [fig,AXras,AXmat,AXgrp]=plot_rasters_3D_summat(D1,D2,Opt)
% ROWGRP=plot_raster_clusters_xGrp(X,Y,D1,D2,Opt,varargin)
%{
D1 = data for all types
D2 = cell with data for each type
Opt necessary fields:

Opt optional fields
- ColunmVar
- RowVar

%}
nrun = 2;
nrow_ras = 1;
ncol_ras = nrun;
pareas = unique(D1.AreaIds);
nareas = numel(pareas);
nrow_grp = nareas;

Opt.CMareas = hsv(nareas);
Opt.XLIM = myminmax(D1.PSTHs_time);

fig = myfig('plot_rasters_3D_summat','slide');
ncol_grp= 1;
[AXras,AXmat,AXgrp]=createAxes(nrow_ras,ncol_ras,nrow_grp,ncol_grp);

[Dras,Dmat,Dgrp]=collectData(D1, D2,Opt);

plotRasters(AXras,Dras,Opt);
plotMat(AXmat,Dmat,Opt);
Dgrp = Dmat;
plotGrp(AXgrp,Dgrp,Opt);

end


%% Get Peak times
function [RespOnsets,PeakTimes,PeakSizes,RespDurations] = GetTracesTimings(X,D)
%  [RespOnsets,PeakTimes] = GetTracesTimings(X,D)
% computes responses timing across 2 conditions only if responsive
wasNotCell = ~iscell(D);
if wasNotCell
    D = {D};
end
ncat = numel(D);
RespOnsets = cell(size(D));
PeakTimes = cell(size(D));
PeakSizes = cell(size(D));
RespDurations = cell(size(D));
th_nSTD = 10;
th_pval = 0.05;
binSz = 0.5;
i4pre = X<0 & X>=-binSz;
i4post = X>0;
th = 0.2;
bins = 0:binSz:X(end);
nbins = numel(bins)-1;
nsamp = numel(X);
i4bin = false(nbins,nsamp);
for ibin = 1:nbins
    i4bin(ibin,:) = X>bins(ibin) & X<=bins(ibin+1);
end
i40 = find(X>=0,1);
X_post = X(i4post);
for icat = 1:ncat
    d = D{icat};
    n4cat = size(d,1);
    peaks = nan(n4cat,1);
    locs = nan(n4cat,1);
    locs_on = nan(n4cat,1);
    tpeaks =  nan(n4cat,1);
    tonsets = nan(n4cat,1);
    for ice = 1:n4cat
        y = d(ice,:);

        % check if is resp : size above threshold
        y_bsl = y(i4pre);
        y_post = y(i4post)-mymean(y_bsl);
        th_size = mystd(y_bsl)*th_nSTD;
        isresp = any(y_post>th_size);%makegoodfig('temp');plot(X,y,'-k');
        if isresp
            for ibin =1:nbins%ibin=2 ibin=3
                d_bin = y(i4bin(ibin,:));
                [pval, isresp] = ranksum(y_bsl,d_bin,'alpha',th_pval/2,'tail','left');
                if isresp
                    break;
                end
            end
        else
            continue;
        end
        % if isresp compute timing
        if isresp
            % find peak
            [peak,loc]=findpeaks(y_post,'SortStr','descend','NPeaks',1);
            if ~isempty(peak)
                peaks(ice) = peak;
                locs(ice)=loc+i40;
                tpeaks(ice) = X(locs(ice)); 
            else
                continue;
            end
            
            % find onset using derivative
            dy = [diff(y_post) 0];
            dy =dy/mymax(dy);
            loc_on=find(dy>th,1);
%             makegoodfig('temp');plot(X_post,y_post,'-k',X_post,dy,'-r',X_post,X(i4post)*0+th,':r',...
%                 X_post(loc_on),y_post(loc_on),'>k',...
%                 X_post(loc)*[1 1],[-1 1],':r',...
%                 X_post,X(i4post)*0+th_size,':k',X_post(loc),peak,'^b');
%             title(num2str(ice));
%             ylim([-1 1])
            %pause()
            if ~isempty(loc_on)
                locs_on(ice)=loc_on+i40;
                tonsets(ice) = X(locs_on(ice));
            end
        end
    end

    PeakTimes{icat} =tpeaks;
    RespOnsets{icat}=tonsets;
    PeakSizes{icat} = peaks;
    Period = diff(X(1:2));
    RespDurations{icat}=sum(  d(:,i4post)>0.3,2)*Period;


end

if wasNotCell
    PeakTimes= PeakTimes{icat}(:) ;
    RespOnsets=RespOnsets{icat}(:);
    PeakSizes=PeakSizes{icat}(:);
    RespDurations=RespDurations{icat}(:);

end

end


%%     - SortFluoRas
function isort = SortFluoRas(X,F,ngrp, clu, clu_vec)
isort = [];
i4post=X>=0;
for iclu = 1:ngrp
    i4clu = find(clu==clu_vec(iclu));
    n4clu = numel(i4clu);
    clu_traces = F(i4clu,:);
    peaks = nan(n4clu,1);
    locs = nan(n4clu,1);
    for ice = 1:n4clu
        y = clu_traces(ice,i4post);
        [peak,loc]=findpeaks(y,'SortStr','descend','NPeaks',1);
        if ~isempty(peak)
            peaks(ice) = peak;
            locs(ice)=loc;
        else
            [peaks(ice), locs(ice)]=nanmin(y);
        end
    end
    [~,isort_peak] = sortrows([locs,peaks],{'ascend' 'descend'});
    isort = cat(1,isort,i4clu(isort_peak));

end
end



%% ---------------------------
%% FUNCTION modifyfig
function modifyfig(fig,ev)

U = fig.UserData;
struct2var(U,'U');
CODE_INPUT=numel(fieldnames(ev))==1;
switch ev.Key

    case 's'


            OPTsort_labels = {  'unsorted' ...1
                                'sorted by cluster and :::peak time' ...2
                                'sorted by cluster and :::peak time during rest' ...3
                                'sorted by response onsets,::: peak time and size during run' ...4
                                'sorted by response onsets,::: peak size and time during run'...5
                                'Xsorted by response density during run'...6
                                'sorted by response duration,::: onset and size during run'...7
                                'sorted by response duration,::: onset and size during rest'...8
                                'sorted by area and highest peak'...9
                                };
        if CODE_INPUT==0
            OPTsort = listdlg('ListString',OPTsort_labels,'ListSize',[600 300]);
        else
            OPTsort =Opt.sorting;%OPTsort=5
        end
        clu_vec =1:ngrp;
        for irow = 1:nrow
            for icol = 1:ncol
                % sort by cluster in coupled
                I = Y(:,:,icol);
                switch OPTsort
                    
                    case 1
                        isort = 1:nce;
                    case 2
                        isort = SortFluoRas(X,I,ngrp,grpID, clu_vec);
                    case 3
                        if irow==1
                            isort = SortFluoRas(X,I,ngrp, grpID, clu_vec);
                        end
                    case 4 % peak time row 2
                        if irow==1
                            [RespOnsets,PeakTimes,PeakSizes] = GetTracesTimings(X,D(2,icol));
                       
                            data2sort = [PeakTimes{1}(:),PeakSizes{1}(:)];
                            data2sort = [RespOnsets{1}(:),PeakTimes{1}(:),PeakSizes{1}(:)];
                            [data_sorted,isort] = sortrows(data2sort,{'ascend' 'ascend' 'descend'});
                        end
                    case 5 % peak time row 2
                        if irow==1
                            [RespOnsets,PeakTimes,PeakSizes] = GetTracesTimings(X,D(2,icol));
                       
                            data2sort = [RespOnsets{1}(:),PeakSizes{1}(:),PeakTimes{1}(:)];
                            [data_sorted,isort] = sortrows(data2sort,{'ascend' 'ascend' 'descend'});
                        end
                    case 6 % response density

                        X,D(2,icol)
                    case 7 % response durations during run
                        if irow==1
                            d4sort = D{2,icol};
                            [RespOnsets,PeakTimes,PeakSizes,RespDurations] = GetTracesTimings(X,d4sort);
                            RespDurations = sum(  d4sort>0.3,2);
                            data2sort = [RespDurations,RespOnsets,PeakSizes];
                            [data_sorted,isort] = sortrows(data2sort,{'ascend' 'ascend' 'descend'});
                        end
                    case 9 % 'sorted by area and highest peak'
                        if irow==1
                            i40 = X>0;
                            binsz_s = 0.2;
                            ibins=discretize(X(i40),0:binsz_s:X(end));
                            nbin = numel(ibins);
                            Ybin = Y(:,i40,:);
                            d4sort = nan(size(Ybin,1),nbin,2);
                            for ibin = 1:nbin
                                i4bin = ibins==ibin;
                                d4sort(:,ibin,:)=mymean(Ybin(:,i4bin,:),2);
                            end
                            d4sort = [d4sort(:,:,1) d4sort(:,:,2)];
                            [maxVal,maxInd] = mymax(d4sort,2);
                            data2sort = [grpID,maxInd,maxVal];
                            [data_sorted,isort] = sortrows(data2sort,{'ascend' 'ascend'  'ascend' });
                        end
                

                end
                fig.UserData.isort{irow,icol} = isort;

                im = findobj(AXras(irow,icol),'type','image','tag','raster');
                im.CData = I(isort,:);

                im = findobj(AXras(irow,icol),'type','image','tag','cb_clu');
                thoseColors = CMgrp(grpID,:);
                im.CData = permute(thoseColors(isort,:),[1 3 2]);

                YLAB = OPTsort_labels{OPTsort};
                if contains(YLAB,':::')
                    YLAB = strsplit(YLAB, ':::');
                end
                ax = AXras(irow,icol);
                p=ax.Position;
                ylabel(AXras(irow,icol),{'Cells',YLAB})
                ax.Position = p;
                if icol~=1
                    goodax(ax,'ylabel','','yticklabel','');
                end
            end
        end

        if OPTsort==9
        % add area names
        xgr =mean(t4clu)+0.1;
        sortedGrpID = grpID(isort);
        for igr = 1:ngrp
            i4gr = sortedGrpID==igr;
            ygr = mymean(find(i4gr));
            txt(igr)=text(xgr,ygr,IDnames{igr},'color',[1 1 1]*0.01,'fontweight','bold','horizontalalignment','center','verticalalignment','bottom','Rotation',90,'tag','areanames');
        end        
        end
        disp 'sorted'

    case 'v'% vs
        [RespOnsets,PeakTimes,PeakSizes,RespDurations] = GetTracesTimings(X,D(:,1));

        d.Resp_Onsets = RespOnsets;
        d.Peak_Times = PeakTimes;
        d.Resp_Durations= RespDurations;
        d.Resp_Size= PeakSizes;

        varnames = fieldnames(d);
        nvar = numel(varnames);

        for ivar1 = 1:nvar
                var1 = varnames{ivar1};
                v1 = d.(var1){1};
            for ivar2 = 1:nvar

                var2 = varnames{ivar2};
                v2 = d.(var2){2};
                fig_vs= makegoodfig('fig_vs');
                plot(v1,v2,'o')
                [rho,pval]=mycorr(v1,v2);
                goodax(gca,'axis',{'square' 'equal'},'grid','on','xlabel',{'rest'},'ylabel',{'run'},'title',{{var1,'vs',var2}},'box','off','text',{0,0,sprintf('rho=%.2f, p=%.3f',rho,pval),'location','NW'});
                pause;
            end
        end



end

end



%% [AXras,AXmat,AXq]=createAxes(nrow_ras,ncol_ras,nrow_grp,ncol_grp);
function [AXras,AXmat,AXgrp]=createAxes(nrow_ras,ncol_ras,nrow_grp,ncol_grp)
NSUB = 3;
xoff = 0.03;
XPOS = [0.06 0.35 0.8];
YPOS = linspace(1-1.1/nrow_grp,0.05,nrow_grp);

clf;
% raster
AXras = gobjects(nrow_ras,ncol_ras);
AXras= mysubplot([],nrow_ras,ncol_ras,'rightMargin',XPOS(2)*0.9,'leftMargin',XPOS(1),'xOffset',0.01);

% mat
pref = AXras(nrow_ras,ncol_ras).Position;
w = XPOS(3)-XPOS(2)-xoff;
h = pref(4);
p = [XPOS(2)+xoff,pref(2),w*0.9,h];
AXmat= axes('position',p);
set(AXmat,'position',p);

% groups
AXgrp= mysubplot([],nrow_grp,ncol_grp,'leftMargin',XPOS(3)+xoff,'rightMargin',0.95);
for irow = 1:nrow_grp
    for icol = 1:ncol_grp
        axis(AXgrp(irow,icol),'square','equal','tight')
    end
end

end


%% [Dras,Dmat,Dgrp]=collectData(D1, D2);
function [Dras,Dmat,Dgrp]=collectData(D1, D2,Opt)

Dras = getRasterData(D1,Opt);
Dmat = getMatData(D2,Opt);
Dgrp = getGrpData(D2,Opt);


end

%% getRasterData
function Dras = getRasterData(D1,Opt)

Dras.X = D1.PSTHs_time;
Y = D1.bestPSTHs_xRun;
nce = size(Y,1);
nsamp = size(Y,2);
nrun=2;
Dras.Y = Y;
[Dras.ID,Dras.pID] = findgroups(D1.AreaName);
Dras.IDnames = unique(D1.AreaName);
Dras.IDcolormap = Opt.CMareas;
Dras.cell_ids = D1.IDs;
% sorting

end

%% getMatData
function Dmat = getMatData(D2,Opt)
Dty = D2{1};
[Dty.AreaIds,AreaNames]=findgroups(Dty.AreaName);
nrow = numel(AreaNames);
ncol = numel(D2);
nrun = 2;
traces = cell(nrow,ncol);
MI = nan(nrow,ncol);
R = cell(nrow,ncol,nrun);

for icol = 1:ncol
    Dty = D2{icol};
    Y = Dty.bestPSTHs_xRun;
    nce = size(Y,1);
    nsamp = size(Y,2);
    [Dty.AreaIds,AreaNames]=findgroups(Dty.AreaName);
    nsamp = size(Y,2);
    for irow = 1:nrow
        i4row = Dty.AreaIds==irow;
        for irun = 1:nrun
            traces{irow,icol}(:,:,irun)=Y(i4row,:,irun);
            allR = Dty.resp_xRun(i4row,:,irun);
            R{irow,icol,irun}= allR;
        end
        
        MI(irow,icol)=mymean(Dty.MI(i4row));
    end

end
colnames = Opt.pty;
rownames = AreaNames;
t = Dty.PSTHs_time;
Dmat=var2struct({'traces' 'R' 'MI' 'AreaNames' 'nrow' 'ncol' 'nrun' 'nsamp' 'colnames' 'rownames' 't'});

end

%% getGrpData
function Dgrp = getGrpData(D2,Opt)
Dgrp =struct();

end

%% plotRasters
function plotRasters(AXras,Dras,Opt)

soundDur=1;

struct2var(Dras,'Dras');
% row and col data
nrow = 1;
ncol = size(Dras.Y,3);

% x data
XLIM = Opt.XLIM;
dXLIM = diff(XLIM);

X =Dras.X;
nX = numel(X);

t4clu = X(end)+((0.05+[0 0.05])*dXLIM);
cluCB_tmax = max(t4clu);
XLIM_CB =XLIM;
XLIM_CB(2) = cluCB_tmax;

% ydata
Y = Dras.Y;
Ymax = max(Y,[],[2 3],'omitnan');
Y  = Y./Ymax;
YLIM = nan(nrow,2,ncol);
nY = size(Y,1);

% group/ID data
ngrp = 5;

% color data
CLIM=[0 1];
% CLIM = myminmax(Y(:));
CMgrp = Dras.IDcolormap;
ID = Dras.ID;

pROWGRP = nan(nrow,ncol,ngrp);
Davg_xClu = nan(ngrp,nX,ncol,nrow);
linestyles ={ '-' ':'};

for icol = 1:ncol

    for irow = 1:nrow%irow = 2

        % plotting raster
        thisRas = AXras(irow,icol);
        axes(thisRas);cla;hold on;
        imagesc(X,0:nY,Y(:,:,icol),'tag','raster');
        YLIM(irow,:,icol) = [0 nY];
        plot([0 0],YLIM(irow,:,icol) ,'w:','LineWidth',1.5)
        plot([1 1]*soundDur,YLIM(irow,:,icol) ,'w:','LineWidth',1.5)
        goodax(thisRas,'ylim',YLIM(irow,:,icol),'ydir','reverse','clim',CLIM,'colormap',jet(100),'xlabel','Time (s)');

        % plot cluster colorbar
        CB_data= CMgrp(ID,:);
        imagesc(t4clu,0:1:nY+1 ,permute(CB_data,[1 3 2]),'tag','cb_clu','CDataMapping','direct');


        % add title
        title(thisRas,Opt.colvar{icol},'fontsize',14)
        colormap('turbo')

    end

end


% make pretty
XTICK = X(1):1:X(end);
for icol = 1:ncol
    for irow = 1:nrow
        goodax(AXras(irow,icol),'colormap',jet(100),'xlim',XLIM_CB,'ylim',YLIM(irow,:,icol),'xtick',XTICK,'caxis',CLIM);
        try
            goodax(AXras(irow,icol),'xlim',XLIM_CB,'ylim',YLIM(irow,:,icol),'xtick',XTICK,'tickdir','both');
        end
        colormap(AXras(irow,icol),'jet');
        
    end
    linkaxes(AXras(:,icol),'xy')
    if icol~=1
            goodax(AXras(irow,icol),'ylabel','');
    end
end




%% add userdata to fig
isort={};
nce = nY;
grpID = ID;
cell_ind = 1:nce;
U=var2struct({'X','Y','grpID','nrow','ncol','ngrp','CMgrp','cell_ids','cell_ind','AXras','isort','Opt','nY','nce' 't4clu' 'IDnames'});
fig = ancestor(AXras(1),'figure');
set(fig,'UserData',U,'keypressfcn',@modifyfig)

ev.Key = 's';
modifyfig(fig,ev);
goodax(AXras(:,2:end),'ylabel','');
    


end%plot raster


%% plotMat
function plotMat(ax,Dmat,Opt)
struct2var(Dmat,'Dmat');
cla(ax);
set(ax,'ydir','reverse');
CM=colormap(ax,jet(100)*0.91);
CM=colormap(ax,flipud(redblue(100,[-1 1],'k')));

imMI=imagesc(ax,1:ncol,1:nrow,MI);
colormap(ax,CM);

linestyles ={ '-' ':'};
soundDur=1;
X0 = 0.5:(ncol+0.5);
yspan = 0.8;
Y0 = (1:nrow)-yspan/2;
hold(ax,'on');
txt =gobjects(nrow,ncol);
txtMI = gobjects(nrow,ncol);
axes(ax);
for irow=1:nrow

    y0 = Y0(irow);
    for icol=1:ncol
        
        % compute x y
        x0 = X0(icol);
        x = linspace(0,1,nsamp)+x0;     


        % add sound patch
        xpa0 = x(find(t>=0,1));
        xpa1 = x(find(t<=soundDur,1,'last'));
        xpa = [xpa0 xpa0 xpa1 xpa1];
        ypa0 = irow-0.5;
        ypa1 = irow+0.5;
        ypa = [ypa0 ypa1 ypa1 ypa0];
        pa = patch(xpa,ypa,[0 0 0]);
        set(pa,'FaceAlpha',0.2,'linestyle','none');

        % add traces

        yy = traces{irow,icol};
        yymax = max(yy,[],[2 3],'omitnan');
        yy = yy./yymax;
        yy=yy*0.8;
        for irun = 1:nrun
            y = -mymean(yy(:,:,irun),1);
            y = y+y0+yspan;
            pl(irun)=plot(ax,x,y,'-w','LineStyle',linestyles{irun},'LineWidth',2);
        end

        % add n
        n = size(traces{irow,icol},1);

        txt(irow,icol)=text(x0+1,irow-0.5,sprintf(' n=%g ',n),'HorizontalAlignment','right');

        txtMI(irow,icol)=text(icol-0.5,irow-0.5,sprintf(' MI=%.2f ',MI(irow,icol)),'HorizontalAlignment','left');

    end

end
set([txt txtMI],'verticalalignment','top','color',[1 1 1]*0.4,'fontangle','italic','fontweight','bold');

CLIM = [-1 1]*0.2;
goodax(ax,'xaxislocation','top','xtick',1:ncol,'xticklabel',colnames,'ytick',1:nrow,'yticklabel',rownames,'TickDir','both','clim',CLIM,'colorbar',{'limits',CLIM,'title',{'Modulation';'index'}},...
    'ylabel',{'Auditory cortex areas','fontsize',12,'fontweight','bold'},'xlabel',{'Sound types','fontsize',12,'fontweight','bold'});

x0 = 0.94;
y0 = 0.75;
pleg(1)=plot(ax,x0+[-1 1]*0.05,[1 1]*y0+0.05,'-w','linewidth',2);
pleg(2)=plot(ax,x0+[-1 1]*0.05,[1 1]*y0-0.05,':w','linewidth',2);
tleg(1) = text(x0+0.06,y0+0.05,'rest','color','w','fontweight','bold','VerticalAlignment','middle');
tleg(2) = text(x0+0.06,y0-0.05,'run','color','w','fontweight','bold','VerticalAlignment','middle');
% 
% leg=legend(pl,{'rest' 'run'});
% p = AXmat.Position;
% set(leg,'box','off','color','none','position',[p(1) p(2)+p(4)*0.88 0.03 0.05])
end

%% plotGrp
function plotGrp(AXgrp,Dgrp,Opt)
struct2var(Dgrp,'Dgrp');
CO='rgb';
LIM = [0 40];
nbins = 20;
ticks = LIM(1):10:LIM(2);
CLIM = [0 1]*0.15;
CMdens = [linspace(1,0.2,100)' linspace(1,0.2,100)' linspace(1,1,100)'];
CMdens =hot(100);
for irow=1:nrow
    ax = AXgrp(irow);
    axes(ax);
    cla(ax);
    colormap(ax,CMdens)
    hold(ax,'on');
    R0=[];
    R1 = [];

    for icol=1:ncol
        co = CO(icol);
        r0 = R{irow,icol,1};
        r1 = R{irow,icol,2};
        %pl{irow,icol}=plot(r0,r1,'.','color',co,'MarkerFaceColor',co,'MarkerSize',3);
        R0 = vertcat(R0,r0);
        R1 = vertcat(R1,r1);
    end
    R0(R0<-2)=nan;
    R0(R0<0)=0;
    R1(R1<-2)=nan;
    R1(R1<0)=0;    
    R0(R0>LIM(2))=LIM(2);
    R1(R1>LIM(2))=LIM(2);
    inonan=~any(isnan([R0 R1]),2);
    R0 =R0(inonan);
    R1 =R1(inonan);

    bi=binscatter(R0,R1,nbins); 
    density_val = bi.Values/mymax(bi.Values(:));
    BinEdges = bi.XBinEdges;
    delete(bi);
    imagesc(ax,BinEdges,BinEdges,imgaussfilt(density_val,1));
    %imagesc(ax,BinEdges,BinEdges,density_val);

    caxis(CLIM);
    if irow==nrow
        xlabel(ax,'rest');
    elseif  irow==1
        title(ax,{'Sound responses';'(density distr.)'},'fontsize',14,'fontweight','bold');
    end
    ylabel(ax,{AreaNames{irow},'run'})
    goodax(ax,'xlim',LIM,'ylim',LIM,'tick',ticks,'tickdir','both','ydir','normal');
    set(ax,'box','on')
    if irow ~=nrow
        goodax(ax,'xticklabel','');
    end

    % add errorbar
    errY=errorbar(mymedian(R0),mymedian(R1),prctile(R1,25),prctile(R1,75),'vertical','linewidth',2,'color','k');
    errX=errorbar(mymedian(R0),mymedian(R1),prctile(R0,25),prctile(R0,75),'horizontal','linewidth',2,'color','k');

    lineco=[1 1 1]*0.9;
    % add fit
%     c = polyfit(R0,R1,1);
%     plot(LIM,LIM*c(1),'--w','color',lineco)

    % add unity line

    plot(LIM,LIM,':w','color',lineco);
end

CLIM = [0 1]*0.25;
for irow = 1:nrow
    ax = AXgrp(irow,1);
    caxis(ax,CLIM);
end



end