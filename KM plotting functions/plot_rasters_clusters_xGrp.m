function [fig,AXras,AXclu]=plot_rasters_clusters_xGrp(X,Y,ROWGRP,COLGRP,GRP,I4ROW,I4COL,Opt,varargin)
% ROWGRP=plot_raster_clusters_xGrp(P,G,ROWGRP,params)
% X = time
% Y = obs or psths
% GRP = groups
% i4row =
% i4col =
% ROWGRP = clusters
% varargin:other optional plotting params
% - ColunmVar
% - RowVar
% -

%% check input

p = inputParser;
addRequired(p,'X');
addRequired(p,'Y');
addRequired(p,'ROWGRP');
addRequired(p,'COLGRP');
addRequired(p,'GRP');
addRequired(p,'I4ROW');
addRequired(p,'I4COL');
addRequired(p,'Opt');
addOptional(p,'compareVar','row');
addParameter(p,'cluvar','NA');


p.KeepUnmatched = true;
parse(p,X,Y,ROWGRP,GRP,I4ROW,I4COL,Opt,varargin{:});%p.Results

params = p.Results;
params_names = fieldnames(params)';


nrow = max(I4ROW);
ncol_var = max(I4COL);
ncol = ncol_var+2;% 2 last column = quantifications

nclu = max(ROWGRP);
CMclu = hsv(nclu);
XLIM = myminmax(X);
%% group and sort rasters

D = cell(nrow,ncol);
clu = cell(nrow,ncol);
nce = nan(nrow,ncol);
cell_ids = cell(nrow,ncol);
cell_ind = cell(nrow,ncol);

% collect data
for irow= 1:nrow

    i4row = I4ROW==irow;


    for icol = 1:ncol_var
        i4col = I4COL == icol;

        i4 = i4row&i4col;
        nce(irow,icol) = sum(i4);
        D{irow,icol} = Y(i4,:);
        clu{irow,icol} = ROWGRP(i4);
        if ismember(params_names,'cell_ids')
            cell_ids{irow,icol} = Opt.cell_ids(i4,:);
        else
            cell_ids{irow,icol} = 1:nce(irow,icol);
        end
        cell_ind{irow,icol} = 1:nce(irow,icol);

    end

end



%% figure
[fig,ax_xCol,i4row,i4col,xpos,ypos,ANN,i4fig,AXras]=preplotXfigs(nrow,ncol,nrow*ncol);%#ok
delete(ANN);

%% position rasters and cluster axes
w = 0.6*(0.8/ncol);
h = 0.8/nrow;
CLIM=[0 prctile(Y(:),95)];%myminmax(Y(:))
CLIM=[0 1];%myminmax(Y(:))
YLIMclu = [-0.15 1];
ypos = linspace(0.9-h,0.05,nrow);
xpos = linspace(0.05,0.9-0.3,ncol);

for irow = 1:nrow
    for icol = 1:ncol_var
        AXras(irow,icol).Position=[xpos(icol) ypos(irow) w h];
    end
end
delete(AXras(:,ncol_var+1:end));

%position clu axes
AXclu = gobjects(nrow,ncol_var,nclu);

wh_clu =0.8*h/nclu;
ypos_clu = linspace(h-wh_clu,0,nclu);
for irow = 1:nrow
    for icol = 1:ncol_var
        ax=AXras(irow,icol);
        xclu = sum([ax.Position(1),ax.Position(3)*1.05] );
        for iclu = 1:nclu

            switch params.compareVar
                case 'row'
                    thisClu = AXclu(irow,icol,iclu) ;


                    if isa(thisClu,'matlab.graphics.GraphicsPlaceholder')
                        AXclu(irow,icol,iclu) = axes('box','off');
                    else
                        axes(thisClu);%#ok
                    end

                    thisClu = AXclu(irow,icol,iclu) ;
                    yclu = ypos_clu(iclu)+ax.Position(2);
                    thisClu.Position = [xclu yclu wh_clu, wh_clu];
                    goodax(thisClu,'color',[1 1 1]*0.95,'ycolor','none','xcolor','none','axis','square');
                case 'clu'% only one 
                    if icol ==ncol_var
                    thisClu = AXclu(irow,icol,iclu) ;

                    if isa(thisClu,'matlab.graphics.GraphicsPlaceholder')
                        AXclu(irow,icol,iclu) = axes('box','off');
                    else
                        axes(thisClu);%#ok
                    end

                    thisClu = AXclu(irow,icol,iclu) ;
                    yclu = ypos_clu(iclu)+ax.Position(2);
                    thisClu.Position = [xclu yclu wh_clu, wh_clu];
                    goodax(thisClu,'color',[1 1 1]*0.95,'ycolor','none','xcolor','none','axis','square');
                    end

            end
        end
    end
end


%% postition qunatification axes
switch params.compareVar
    case 'row'
        AXq = gobjects(2,2);
    case 'clu'
        AXq = gobjects(nclu,2);
        for icol = 1:size(AXq,2)
            for irow = 1:size(AXq,1)
                AXq(irow,icol) = mysubplot([],size(AXq,1),size(AXq,2),irow,icol,'leftMargin',sum(AXclu(1,ncol_var).OuterPosition([1 3])),'rightMargin',0.99);
            end
            templateAX = squeeze(AXclu(1,ncol_var,:));
            axrepos('VerticalAlign',{AXq(:,icol),templateAX},'AlignHeight',{AXq(:,icol),templateAX});

        end
            axrepos('HorizontalStretch',{AXq(:,icol),1.2,1});

end


%% Plot rasters and plot clusters
XLIM_CB = XLIM;
dXLIM = diff(XLIM);
t4clu = X(end)+((0.05+[0 0.03])*dXLIM);
cluCB_tmax = max(t4clu);
XLIM_CB(2) = cluCB_tmax;
YLIM = nan(nrow,2,ncol);
pROWGRP = nan(nrow,ncol,nclu);
D_xClu = cell(nclu,ncol_var,nrow);
nX = numel(X);
Davg_xClu = nan(nclu,nX,ncol,nrow);
linestyles ={ '-' ':'};
soundDur=1;

for icol = 1:ncol_var

    for irow = 1:nrow%irow = 2

        % plotting raster
        thisRas = AXras(irow,icol);
        axes(thisRas);cla;hold on;
        imagesc(X,0:nce(irow,icol),D{irow,icol},'tag','raster');
        YLIM(irow,:,icol) = [0 nce(irow,icol)];
        plot([0 0],YLIM(irow,:,icol) ,'w:','LineWidth',1.5)
        plot([1 1]*soundDur,YLIM(irow,:,icol) ,'w:','LineWidth',1.5)
        goodax(thisRas,'ylim',YLIM(irow,:,icol),'ydir','reverse','clim',CLIM,'colormap',jet(100));

        % plot cluster colorbar
        CB_data= CMclu(clu{irow,icol},:);
        imagesc(t4clu,0:1:nce(irow,icol)+1 ,permute(CB_data,[1 3 2]),'tag','cb_clu','CDataMapping','direct');


        n4 = numel(clu{irow,icol});

        % add clu PSTHs
        for iclu = 1:nclu
            i4clu = clu{irow,icol}==iclu;
            n4clu = sum(i4clu);
            clu_traces = D{irow,icol}(i4clu,:);
            D_xClu{iclu,icol,irow} =clu_traces;
            avg_clu_trace = mean(clu_traces,1,"omitnan");
            Davg_xClu(iclu,:,icol,irow) = avg_clu_trace;

            switch params.compareVar
                case 'row'
                    thisClu = AXclu(irow,icol,iclu) ;
                    axes(thisClu);cla;hold on;
                    co = CMclu(iclu,:);
                    plot(X,clu_traces','-','Color',co)
                    plot(X,avg_clu_trace,'-','Color',co*0.5,'LineWidth',2)
                    plot([0 0],CLIM ,'w:','LineWidth',0.5,'color',[1 1 1]*0.5)
                    goodax(thisClu,'xlim',XLIM,'ylim',YLIMclu,'xlabel',{''});
                    goodax(thisClu,'text',{0,0,sprintf('%0.f %%',100*n4clu/n4),'color',co*0.5,'verticalalignment','middle','fontweight','bold','fontsize',10,'location','NW'});
                case 'clu'
                    thisClu = AXclu(irow,ncol_var,iclu) ;
                    axes(thisClu);hold on;
                    co = CMclu(iclu,:);
                    plot(X,avg_clu_trace,'-','Color',co*0.9,'LineWidth',1.5,'linestyle',linestyles{icol})
                    if icol==1
                        plot([0 0],CLIM ,'w:','LineWidth',0.5,'color',[1 1 1]*0.5)
                        plot([1 1]*soundDur,CLIM ,'w:','LineWidth',0.5,'color',[1 1 1]*0.5)
                        goodax(thisClu,'xlim',XLIM,'ylim',YLIMclu,'xlabel',{''});
                        goodax(thisClu,'text',{0,0,sprintf('%s (%g cells)',Opt.cluvar{iclu},n4clu),'color',co*0.9,'verticalalignment','middle','fontweight','bold','fontsize',10,'location','NW'});

                    end
            end
            pROWGRP(irow,icol,iclu) = 100*n4clu/n4;
        end

        % good ax
        switch params.compareVar
            case 'row'
                % ylabels
                if icol ==1
                    axann = axes();
                    P = thisRas.Position;
                    set(axann,'Position',[P(1)-0.25*P(3) P(2) P(3)*0.2 P(4)],'color','none','ycolor','none','xcolor','none','box','off');
                    ylabel(axann,Opt.rowvar{irow},'FontSize',18,'fontweight','bold','color','k','verticalalignment','top')

                    axes(thisRas);
                    ylabel(thisRas,'(unsorted)','FontSize',12,'fontweight','normal')
                end


                if irow ==1
                    title(replace(Opt.colvar{icol},'_',' '));
                end

                if irow==nrow
                    xlabel('Time from sound (s)')
                end
            case 'clu'
                % ylabels
                P = thisRas.Position;
                if icol<ncol_var
                    goodax(thisRas,'ylabel',{{'(unsorted)'},'FontSize',12,'fontweight','normal'});

                end


                if irow ==1
                    goodax(thisRas,'title',{Opt.colvar(icol)});
                end

                if irow==nrow && icol<ncol_var
                    xlabel(thisRas,'Time from sound (s)')
                end
                thisRas.Position = P;
               goodax(thisRas,'ylabel',{{'(unsorted)'},'FontSize',12,'fontweight','normal'});

        end

    end

end


% make pretty
XTICK = X(1):1:X(end);
for icol = 1:ncol_var
    for irow = 1:nrow
        goodax(AXras(irow,icol),'colormap',jet(100),'xlim',XLIM_CB,'ylim',YLIM(irow,:,icol),'xtick',XTICK,'caxis',CLIM);
        try
            goodax(AXclu(irow,icol,:),'xlim',XLIM,'ylim',YLIMclu,'xtick',XTICK,'xtickdir','both');
        end
    end
    linkaxes(AXras(:,icol),'xy')
end




%% add userdata to fig
U.nrow = nrow;
U.ncol = ncol;
U.ncol_var = ncol_var;
U.nclu = nclu;
U.CMclu = CMclu;
U.X = X;
U.D = D;
U.clu = clu;
U.nce = nce;
U.cell_ids = cell_ids;
U.cell_ind = cell_ind;
U.AXras = AXras;
U.AXclu = AXclu;
U.isort = {};
U.Opt = Opt;


set(fig,'UserData',U,'keypressfcn',@modifyfig)


ev.Key = 's';
modifyfig(fig,ev);
%% --------------------------
%%  QUANTIFY

switch p.Results.compareVar
    case 'row'
        %% AX avg trace
        thisrow=1;
        ax = AXras(thisrow,ncol-1);
        axes(ax);cla(ax);
        rowCo = [0 0 1;1 0 0];
        Style = 'no_oldschool';
        for irow = 1:nrow

            Yrow = D{irow,1};
            if strcmp(Style,'oldschool')
                plot(X,Yrow,'-','color',rowCo(irow))
                hold on;
                me(irow)= plot(X,mymean(Yrow,1),'-','color',rowCo(irow,:)*0.5,'linewidth',2);
            else
                sh=shadedErrorBar(X,mymean(Yrow,1),myste(Yrow,1)) ;
                hold on;
                set(sh.mainLine,'color',rowCo(irow,:)*0.5,'linewidth',1.5)
                set(sh.patch,'facecolor',rowCo(irow,:),'facealpha',0.3,'LineStyle','none')
                set(sh.edge,'LineStyle','none')
                SH(irow) = sh.patch;
            end
        end
        goodax(ax,'box','off','xlabel','Time from sound (s)','ylabel','Norm. to max response','legend',{SH,Opt.rowvar,'location','northwest','box','off'});

        %% AX proportions clu
        thisrow=2;
        ax = AXras(thisrow,ncol-1);
        axes(ax);cla(ax);


        ba=bar(permute(pROWGRP(:,1,:),[1 3 2]),'grouped');
        colororder(CMclu)

        for iclu =1:nclu
            set(ba(iclu),'linestyle','none');
        end

        goodax(ax,'box','off','xticklabel',Opt.rowvar,'ylabel','proportion of cells per cluster (%)')




        %% Get quantification data


        [RespOnsets,PeakTimes,PeakSizes,RespDurations] = GetTracesTimings(X,D(:,1));

        %% AX Q° Timing
        thisrow = 1;
        ax = AXras(thisrow,ncol);
        axes(ax);cla(ax);

        d = struct();
        d.Resp_Onsets = RespOnsets;
        d.Peak_Times = PeakTimes;
        d.Resp_Durations= RespDurations;
        violin_varnames = fieldnames(d);
        nvio = numel(violin_varnames);
        ybins = 0:0.1:X(end);
        [H,stats] = mirror_hist(1:nvio,d,ybins);

        goodax(ax,'box','off','xticklabel',violin_varnames,'ylabel','Time from sound onset (s)','xlim',[1 nvio]+[-0.5 0.5]);

        %% AX Q° Peak sizes
        thisrow=2;
        ax = AXras(thisrow,ncol);
        axes(ax);cla(ax);

        d = struct();
        d.Peak_Sizes = PeakSizes;
        violin_varnames = fieldnames(d);
        nvio = numel(violin_varnames);
        ybins = 0:0.05:1;
        [H,stats] = mirror_hist(1:nvio,d,ybins);

        goodax(ax,'box','off','xticklabel',violin_varnames,'ylabel','Norm. resp size','xlim',[1 nvio]+[-0.5 0.5]);

        disp('done ')

    case 'clu'

        % compare measures
        [RespOnsets,PeakTimes,PeakSizes,RespDurations] = GetTracesTimings(X,D_xClu);

        dclu.Resp_Onsets=RespOnsets;
        dclu.Peak_Times=PeakTimes;
        dclu.Peak_Sizes=PeakSizes;
        dclu.Resp_Durations=RespDurations;
        varnames = fieldnames(dclu);
        nvar = numel(varnames);
        for iclu = 1:nclu
            ax=AXq(iclu,1);
            axes(ax);
            cla
            p = ax.Position;
            d.Resp_Onsets=RespOnsets(iclu,:);
            d.Peak_Times=PeakTimes(iclu,:);
            d.Peak_Sizes=PeakSizes(iclu,:);
            d.Resp_Durations=RespDurations(iclu,:);
            ybins = 0:0.05:2;
            [H,stats] = mirror_hist(1:nvar,d,ybins);
            goodax(ax,'xticklabel','','tickdir','both','xtick',1:nvar);

            if iclu ==1
                goodax(ax,'title',{'Comparison REST vs RUN'});
            end            
        end
        goodax(ax,'xticklabel',varnames);

        % compare areas
        for ivar = 1:nvar
                ax=AXq(ivar,2);
                axes(ax);cla;hold on;
            for icol = 1:ncol_var


                
                p = ax.Position;
                tempd = dclu.(varnames{ivar});
                if icol==1
                    tempd(:,2) = num2cell(nan(nclu,1));
                else
                    tempd(:,1) = num2cell(nan(nclu,1));
                end
                Xpos = (1:nclu)+nclu*(icol-1);
                H = mirror_hist((1:nclu)+nclu*(icol-1),tempd,ybins,'varnames',Opt.cluvar,'dostats',false);
                stats=KMStats(gca,Xpos,tempd(:,icol));
                goodax(ax,'ylabel',{varnames{ivar}},'xticklabel','','tickdir','both','xtick',1:nclu*ncol_var);
            end
            if ivar ==1
                goodax(ax,'title',{'Comparison Areas'});
            end

        end
        goodax(ax,'xtick',1:nclu*ncol_var,'tickdir','both','xticklabel',repmat(Opt.cluvar,ncol_var,1),'xlim',[0.5 nclu*ncol_var+0.5])

end
delete(AXq(end))
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
function isort = SortFluoRas(X,F,nclu, clu, clu_vec)
isort = [];
i4post=X>=0;
for iclu = 1:nclu
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
                                };
        if CODE_INPUT==0
            OPTsort = listdlg('ListString',OPTsort_labels,'ListSize',[600 300]);
        else
            OPTsort =Opt.sorting;%OPTsort=5
        end
        clu_vec =1:nclu;
        for irow = 1:nrow
            for icol = 1:ncol_var
                % sort by cluster in coupled

                switch OPTsort
                    
                    case 1
                        isort = 1:nce;
                    case 2
                        isort = SortFluoRas(X,D{irow,icol},nclu, clu{irow,icol}, clu_vec);
                    case 3
                        if irow==1
                            isort = SortFluoRas(X,D{irow,icol},nclu, clu{irow,icol}, clu_vec);
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
                    case 8 % resp dur during rest
                        if irow==1
                            d4sort = D{1,icol};
                            [RespOnsets,PeakTimes,PeakSizes,RespDurations] = GetTracesTimings(X,d4sort);
                            RespDurations = sum(  d4sort>0.3,2);
                            data2sort = [RespDurations,RespOnsets,PeakSizes];
                            [data_sorted,isort] = sortrows(data2sort,{'ascend' 'ascend' 'descend'});
                        end
                    case 9 % resp onset, dur during rest,
                        if irow==1
                            d4sort = D{1,icol};
                            [RespOnsets,PeakTimes,PeakSizes,RespDurations] = GetTracesTimings(X,d4sort);
                            RespDurations = sum(  d4sort>0.3,2);
                            data2sort = [RespOnsets,RespDurations,PeakSizes];
                            [data_sorted,isort] = sortrows(data2sort,{'ascend' 'ascend' 'descend'});
                        end

                end
                fig.UserData.isort{irow,icol} = isort;

                im = findobj(AXras(irow,icol),'type','image','tag','raster');
                im.CData = D{irow,icol}(isort,:);

                im = findobj(AXras(irow,icol),'type','image','tag','cb_clu');
                thoseColors = CMclu(clu{irow,icol},:);
                im.CData = permute(thoseColors(isort,:),[1 3 2]);

                YLAB = OPTsort_labels{OPTsort};
                if contains(YLAB,':::')
                    YLAB = strsplit(YLAB, ':::');
                end
                ax = AXras(irow,icol);
                p=ax.Position;
                ylabel(AXras(irow,icol),YLAB)
                ax.Position = p;
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


