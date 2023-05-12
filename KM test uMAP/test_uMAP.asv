function             fig=test_uMAP(obs)

ncol = 5;
nrow = 6;
p_min_dist = linspace(0.06 ,0.79 ,ncol);%default 0.3, compaction 0<mindist<1,  x>.05&&x<.8
p_n_neighbors = round(linspace(3,199,nrow))%default 15, 2<n_neighbors<199



nobs = size(obs,1);
nvar = size(obs,2);
uMAP_var = mynum2str(1:nvar,'v%g','cellstr');
          

n_min_dist = numel(p_min_dist);
n_n_neighbors = numel(p_n_neighbors);

fig = makegoodfig('test_uMAP','slide');
AX = mysubplot([],nrow,ncol,[]);
for irow = 1:n_n_neighbors
    n_neighbors = p_n_neighbors(irow);
    for icol = 1:n_min_dist
        min_dist = p_min_dist(icol);

        %run uMAP
        rng default % for reproducibility

        [XYclusters,umap,clusterIdentifiers,extras]=run_umap(obs,'parameter_names',uMAP_var,'min_dist',min_dist,'n_neighbors',n_neighbors);
        clusterIdentifiers = clusterIdentifiers(:);
        clusterIdentifiers = clusterIdentifiers+1;
        pclu = unique(clusterIdentifiers);
        nclu = numel(pclu);
        CM = turbo(nclu);
        close(extras.fig);

        % plot
        ax = AX(irow,icol);
        cla(ax);
        gs=scatter(ax,XYclusters(:,1),XYclusters(:,2),ones(nobs,1)*6,clusterIdentifiers,'filled');

        goodax(ax,'colormap',CM,'colorbar',{'ylabel',sprintf('%g\nclusters',nclu),'box','off','TickLabels',''},'axis',{'equal' 'tight'},'box','off');
  
        if icol~=1
            ax.YTickLabel='';
        end

        if irow ~=nrow
            ax.XTickLabel='';
        end

        if irow ==1
            goodax(ax,'title',{sprintf('min dist = %g',min_dist),'fontsize',12,'fontweight','bold'})
        end

        if icol == 1
            goodax(ax,'ylabel',{sprintf('n neighbors\n= %g',n_neighbors),'fontsize',12,'fontweight','bold'})
        end
    end


end

keyboard


