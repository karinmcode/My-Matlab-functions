function pa=myethogram(ax,X,Y,varargin)
dx = 1;
dy = 1;
nX = numel(X);

Alpha = 0.5;
nY = numel(unique(Y));
CM = jet(nY);

pa = gobjects(nX);
hold on;
for ix = 1:nX
    x0 = X(ix);
    y0 = Y(ix);
    x1 = x0+dx;
    y1 = y0+dy;
    xpa = [x0 x0 x1 x1];
    ypa = [y0 y1 y1 y0];
    co = CM(y0,:);

        % add patch
    pa(ix) = patch(ax,xpa, ypa, co,'EdgeColor','none','FaceAlpha',Alpha,'FaceColor',co...
        ,'Marker','none', 'MarkerEdgeColor',co,'MarkerFaceColor',co,'tag','KMPatch');

end
hold off;