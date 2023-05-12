function myfiltertest(d)


n = size(d,1);

pmethods = {'movmean' 'movmedian' 'gaussian' 'lowess' 'loess' 'rlowess' 'rloess' 'sgolay' };
nm = numel(pmethods);
pwind = [1 2 3 5 10 ];
nw = numel(pwind);

nrow = nw;
ncol = nm+1;
AX = gobjects(nrow,ncol);
fig = makegoodfig('filtertest','slide');

for icol = 1:ncol


    if icol==1
        for irow=1:nrow
            AX(irow,icol)=mysubplot([],nrow,ncol,irow,icol,'rightmargin',0.05);
            plot(d,'-');
            if irow ==1
                title('raw');
            end
            [yrmax,xrmax]=mymax(d(:));
            hold on;
            plot([0 n],[1 1 ]*yrmax,':k');

            AX(irow,icol).Position(1)=0.05;
        end
        continue;
    end

    m = pmethods{icol-1};

    for iw = 1:nw
        irow = iw;
        w = pwind(iw);

        %% smoothdata
        df = smoothdata(d,1,m,w,"includenan");

        [ymax,xmax]=mymax(df);

        AX(irow,icol)=mysubplot([],nrow,ncol,irow,icol);
        hold on;
        plot(d,'--');
        plot(df,'-');
        plot([0 n],[1 1 ]*yrmax,':k');
        plot([0 n],[1 1 ]*ymax,':r');

        if irow ==1
            title(m);
        end

        if icol ==2
            ylabel(sprintf('wind = %g',w),'FontSize',12,'FontWeight','bold');
        end

        ddf = d-df;


    end

end

linkaxes(AX,'xy')

