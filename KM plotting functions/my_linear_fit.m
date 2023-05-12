function [pl, coeff, pval, rsq] = my_linear_fit(ax, x, y, varargin)
%% [pl, coeff, pval, rsq] = my_linear_fit(ax, x, y, [InterceptIncluded], [binSize])

if isaxes(ax) == 0
    keyboard;
end

InterceptIncluded = 1;
binSize = 1;
xfit = x;
optPlot = 1;

if ~isempty(varargin)
    InterceptIncluded = varargin{1};
    if numel(varargin) > 1
        binSize = varargin{2};
        X = x;
        xbins = mymin(x):binSize:mymax(x);
        x = movmean(xbins, 2);
        Y = y;
        g = discretize(X, xbins);
        inonan = ~isnan(g);
        g = g(inonan);

        tab = table();
        tab.x = X(inonan);
        tab.y = Y(inonan);
        tab.g = g;
        gsum = groupsummary(tab, 'g', 'mean');
        x = gsum.mean_x;
        y = gsum.mean_y;
        xfit = xlim(ax);
        if numel(varargin) > 2
            if strcmp(varargin{3},'noplot')
                optPlot = 0;

            end
        end
    end
end

% Fit a linear function
if InterceptIncluded
    coeff = polyfit(x, y, 1);
else
    coeff = [polyfit(x, y, 0) 0];
end

% Calculate fitted values
yfit = polyval(coeff, xfit);
if     optPlot
    hold(ax, "on");
    pl = plot(ax, xfit, yfit, '-r');
end
% Calculate p-value
yfit = polyval(coeff, x);
yresid = y - yfit;
SSresid = sum(yresid.^2);
SStotal = (length(y)-1) * var(y);
rsq = 1 - SSresid/SStotal;
df = length(y) - (1 + InterceptIncluded);
F = (rsq/(1-rsq)) * (df/1);
pval = 1 - fcdf(F, 1, df);

end
