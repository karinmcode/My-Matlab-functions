function [step_fit, lin_fit, step_p, lin_p, corr_sign] = my_fit_step_lin(x, y, varargin)
% x: vector of x-values
% y: vector of y-values
% varargin: optional input argument to control display of results and plot (true/false)

% Examples
% % Display and plot results
% [step_fit, lin_fit, step_p, lin_p, corr_sign] = fit_step_lin(x, y, [display_results], [plot_results]);
% [step_fit, lin_fit, step_p, lin_p, corr_sign] = fit_step_lin(x, y, true, true);
% 
% % Do not display results but plot them
% [step_fit, lin_fit, step_p, lin_p, corr_sign] = fit_step_lin(x, y, false, true);
% 
% % Display results but do not plot them
% [step_fit, lin_fit, step_p, lin_p, corr_sign] = fit_step_lin(x, y, true, false);


% Set default values for varargin
if isempty(varargin)
    display_results = true;
    plot_results = false;
else
    display_results = varargin{1};
    if length(varargin) > 1
        plot_results = varargin{2};
    else
        plot_results = false;
    end
end

% Fit step/sigmoid function
step_fit = fit(x',y','step1');
step_p = anova(step_fit,'summary').pValue(1);

% Fit linear function
lin_fit = fitlm(x,y);
lin_p = lin_fit.Coefficients.pValue(2);

% Calculate correlation coefficient and determine sign
[r, pval] = corr(x,y);
if r > 0
    corr_sign = 1;
else
    corr_sign = -1;
end

% Display results if requested
if display_results
    disp(['Step/Sigmoid fit: p = ' num2str(step_p) ', goodness of fit = ' num2str(step_fit.rsquare)]);
    disp(['Linear fit: p = ' num2str(lin_p) ', goodness of fit = ' num2str(lin_fit.Rsquared.Ordinary)]);
    disp(['Correlation/regression is ' num2str(corr_sign) ' with correlation coefficient r = ' num2str(r) ' and p-value = ' num2str(pval)]);
end

% Plot results if requested
if plot_results
    % Plot data points in black
    scatter(x, y, 'k');
    hold on;
    % Plot step/sigmoid fit in red
    plot(step_fit, 'r');
    % Plot linear fit in blue
    plot(lin_fit, 'b');
    hold off;
end
end
