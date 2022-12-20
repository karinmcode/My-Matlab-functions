function  [pl,coeff]=my_linear_fit(ax,x,y,varargin)
%% [pl,li]=my_linear_fit(ax,x,y,[InterceptIncluded],[binSize])

if isaxes(ax)==0
keyboard;
end

InterceptIncluded =1;
xfit = x;
if ~isempty(varargin)
    InterceptIncluded = varargin{1};

    if numel(varargin)>1
        binSize = varargin{2};
        X = x;
        xbins = mymin(x):binSize:mymax(x);
        x = movmean(xbins,2);
        Y = y;
        g=discretize(X,xbins);
        inonan=~isnan(g);
        g = g(inonan);

        tab = table();
        tab.x = X(inonan);
        tab.y = Y(inonan);
        tab.g = g;
        gsum=groupsummary(tab,'g','mean');
        x = gsum.mean_x;
        y = gsum.mean_y;
        xfit = xlim(ax);
    end
end
coeff = polyfit(x,y,1);
if InterceptIncluded
    yfit = polyval(coeff,xfit);
else
    coeff(end)=0;
    yfit = polyval(coeff,xfit);
end


hold(ax,"on");
pl = plot(ax,xfit,yfit,'-r');

end
