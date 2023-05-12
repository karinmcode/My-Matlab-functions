function [pl, coeff, pval, rsq] = my_step_fit(ax, x, y, varargin)
%% [pl, coeff, pval, rsq] = my_step_fit(ax, x, y, [binSize])

if isaxes(ax) == 0
    keyboard;
end
optPlot = 1;
binSize = 1;
xfit = x;
if ~isempty(varargin)
    binSize = varargin{1};

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

% Define the custom step function
stepFcn = @(a, b, x) a .* heaviside(x - b);
customFitType = fittype(stepFcn, 'independent', 'x', 'coefficients', {'a', 'b'});

% Define starting point for coefficients a and b based on y
startPoint_a = mean(y);
startPoint_b = median(x);
startPoint = [startPoint_a, startPoint_b];

% Fit the custom step function

[cfit, gof] = fit(x(:), y(:), customFitType,'StartPoint',startPoint);

coeff = cfit;

% Calculate fitted values
yfit = cfit(x(:));

% Plot fit
if optPlot
hold(ax, "on");
pl = plot(ax, x(:), yfit, '-r');
end
% Calculate residuals (yresid)
yresid = y - yfit;

% Calculate residual sum of squares (SSresid)
SSresid = sum(yresid.^2);

% Calculate total sum of squares (SStotal)
SStotal = (length(y)-1) * var(y);

% Calculate R-squared value (rsq)
rsq = 1 - SSresid/SStotal;

% Calculate degrees of freedom (df)
df = length(y) - 2;

% Calculate F-statistic (F)
F = (rsq/(1-rsq)) * (df/1);

% Calculate p-value (pval) using the F-distribution CDF
pval = 1 - fcdf(F, 1, df);

end
