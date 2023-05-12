function [hfit, COEFF, R2, PVAL,fitTxtTable,bestFitIndex,bestFitColor,fitDir] = myfit(ax, x, y, varargin)
%MYFIT Performs different types of fitting based on input.
%
% Syntax:
%   [hfit, COEFF, R2, PVAL] = myfit(ax, x, y, varargin)
%
% Inputs:
%   ax - Axis handle to plot the fitted data (if plotting is enabled).
%   x - Independent variable data.
%   y - Dependent variable data.
%   varargin - Optional parameters for fitting, binning, and plotting.
%
% Outputs:
%   hfit - Handle to the line object of the fit (if plotting is enabled).
%   COEFF - Cell array containing the coefficients of each fit.
%   R2 - Vector containing the R-squared value of each fit.
%   PVAL - Vector containing the p-value of each fit.
%   fitDir - Fit direction
%
% Optional parameters (Name-Value pairs):
%   'fit_names' - Cell array of strings specifying the types of fits to perform.
%                 Options: 'linear', 'step', 'exp', 'ln', 'log'. Default: {'linear'}.
%   'binning' - Flag to enable (1) or disable (0) data binning. Default: 1.
%   'plotting' - Flag to enable (1) or disable (0) plotting of the fits. Default: 1.
%
% Example:
%   [hfit, COEFF, R2, PVAL] = myfit(ax, x, y, 'fit_names', {'linear', 'exp'}, 'plotting', 1);
%
% See also: fit, polyfit, polyval, inputParser


%% Check inputs
params = mycheckinputs(varargin{:});
X = x;
Y = y;

if isempty(ax)
    params.plotting =0;
end

% Initialize output variables
fitTxtTable = '';
bestFitIndex = nan;
bestFitColor = [0 0 0];
%% Format data
if params.binning==1
    if isfield(params,'binSize')
        xbins = mymin(x):params.binSize:mymax(x);
    elseif params.xBins~=0
        xbins = params.xBins;
    end
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
end


%% Prep plotting
if  params.plotting
    previousfits = findobj(ax,'tag','myfits');
    delete(previousfits);
end

%% Fitting
nfi = numel(params.fit_names);
hfit = gobjects(nfi, 1);
COEFF = cell(nfi, 1);
R2 = nan(nfi, 1);
PVAL = nan(nfi, 1);
fitDir = nan(nfi,1);
CM = turbo(nfi);
for ifi = 1:nfi
    % Define fit function
    fitname = params.fit_names{ifi};
    switch fitname
        case  {'linear' 'lin'}

            % Define the custom step function
            coeff = polyfit(x, y, 1);
            % Calculate fitted values
            yfit = polyval(coeff, x);

        case 'step'
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
            xfit = x(:);
            yfit = cfit(xfit);


        case 'exp'
            % Define the exponential fit function
            expFcn = @(a, b, x) a .* exp(b .* x);
            customFitType = fittype(expFcn, 'independent', 'x', 'coefficients', {'a', 'b'});

            % Define starting points
            startPoint_a = mean(y);
            startPoint_b = 1/mean(x);
            startPoint = [startPoint_a, startPoint_b];

            % Set bounds for the coefficients
            lowerBounds = [0, -Inf];
            upperBounds = [Inf, Inf];

            % Fit the exponential function
            [cfit, gof] = fit(x(:), y(:), customFitType, 'StartPoint', startPoint, 'Lower', lowerBounds, 'Upper', upperBounds);

            coeff = cfit;

            % Calculate fitted values
            xfit = x(:);
            yfit = cfit(xfit);
        case 'ln'
            % Apply a small offset to y to avoid log(0) and negative infinity
            y = y + 0.0001;

            % Fit the natural logarithm function
            lnFcn = @(a, b, x) a + b .* log(x);
            customFitType = fittype(lnFcn, 'independent', 'x', 'coefficients', {'a', 'b'});

            % Define starting points
            startPoint_a = mean(y);
            startPoint_b = mean(log(x));
            startPoint = [startPoint_a, startPoint_b];

            [cfit, gof] = fit(x(:), y(:), customFitType, 'StartPoint', startPoint);

            coeff = cfit;

            % Calculate fitted values
            xfit = x(:);
            yfit = cfit(xfit);

        case 'log'
            % Apply a small offset to y to avoid log10(0) and negative infinity
            y = y + 0.0001;

            % Fit the base-10 logarithm function
            logFcn = @(a, b, x) a + b .* log10(x);
            customFitType = fittype(logFcn, 'independent', 'x', 'coefficients', {'a', 'b'});

            % Define starting points and bounds for the coefficients
            startPoint_a = mean(y);
            startPoint_b = mean(log10(x));
            startPoint = [startPoint_a, startPoint_b];
            lb = [0, -Inf];
            ub = [Inf, Inf];

            % Try fitting the log function with different starting points and bounds
            for i = 1:5
                try
                    warning off;
                    [cfit, gof] = fit(x(:), y(:), customFitType, 'StartPoint', startPoint, 'Lower', lb, 'Upper', ub);
                    warning on;
                    break
                catch
                    % If the fit fails, try using different starting points and bounds
                    startPoint_a = mean(y);
                    startPoint_b = mean(log10(x)) / 10^i;
                    startPoint = [startPoint_a, startPoint_b];
                    lb = [0, -10^i];
                    ub = [Inf, 10^i];
                end
            end

            coeff = cfit;

            % Calculate fitted values
            xfit = x(:);
            yfit = cfit(xfit);


    end



    %% calculate goodness of the fit

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

    %% store data
    R2(ifi)=rsq;
    PVAL(ifi)=pval;
    COEFF{ifi} = coeff;

    %% fitDir
    yStart = yfit(1);
    yEnd = yfit(end);
    fitDir(ifi) = sign(yEnd-yStart);

    %% plotting
    if  params.plotting
        hold(ax, "on");
        hfit(ifi) = plot(ax, x, yfit, '-','color',CM(ifi,:),'tag','myfits');
    end
end


%% Get best fit

if all(PVAL>0.05)
    [~,bestFitIndex]=max(R2,[],"omitnan");
    bestFitColor = [0 0 0];
else
    R2best = R2;
    R2best(PVAL>0.05)=nan;
    [~,bestFitIndex]=max(R2best,[],"omitnan");
    bestFitColor = CM(bestFitIndex,:);
end

if all(bestFitColor==0) && any(PVAL<=0.05)
    disp(R2)
    keyboard
end
%% Add text
if params.text
    fitTxt = cell(nfi+1,3);
    fitTxt(1,1:3) = {'fit' 'R2' 'pval'};

    for ifi=1:nfi
        if PVAL(ifi)>0.05
            pvalstr = '>0.05';
        elseif PVAL(ifi)<0.001
            pvalstr = '<0.001';
        else
            pvalstr = num2str(PVAL(ifi),'%.3f');
        end

        if ifi==bestFitIndex
            BOLD = '\bf';
        else
            BOLD = '\rm';
        end

        fitTxt(ifi+1,:)= {[BOLD params.fit_names{ifi}] num2str(R2(ifi),'%.2f') pvalstr};
    end

    fitTxtTable = mydispcell(fitTxt);
    %goodax(ax,'text',{0,0,fitTxtTable,'location','W'});
end



end


function params = mycheckinputs(varargin)

% Parse input arguments and set defaults for params
p = inputParser;
p.addParameter('fit_names', {'linear'}, @(x) iscell(x) && all(ismember(x, {'linear', 'step', 'exp', 'ln', 'log'})));
p.addParameter('binning', 1);
p.addParameter('plotting', 1);
p.addParameter('text', 1);
p.addParameter('xBins', 0);
p.addParameter('binSize', 0.02);

p.parse(varargin{:});
params = p.Results;

if params.xBins~=0
    params.binning=1;
end

end
