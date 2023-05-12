function [omega_squared, eta_squared] = myEffectSize(varargin)
%MYEFFECTSIZE Compute the Omega-squared (ω²) and Eta-squared (η²) effect sizes for one-way ANOVA
%
%   [omega_squared, eta_squared] = MYEFFECTSIZE(groups) computes the
%   Omega-squared (ω²) and Eta-squared (η²) effect sizes for the given
%   input 'groups', which can be either a matrix with each column being a
%   group, or a cell array where each cell contains a column vector of
%   observations for one group.
%
%   [omega_squared, eta_squared] = MYEFFECTSIZE(values, group_labels)
%   computes the Omega-squared (ω²) and Eta-squared (η²) effect sizes for
%   the given input 'values' (a column vector containing the data) and
%   'group_labels' (a column vector containing group labels corresponding
%   to the values in 'values').
%
%   INPUT:
%   - varargin: either (1) a matrix with each column being a group, (2) a
%               cell array where each cell contains a column vector of
%               observations for one group, or (3) two column vectors, the
%               first containing the values and the second containing the
%               group labels
%
%   OUTPUT:
%   - omega_squared: the computed Omega-squared (ω²) effect size
% %   - eta_squared: the computed Eta-squared (η²) effect size
% 
%   Eta-squared (η²) and Omega-squared (ω²) are both effect size measures
%   used in the context of one-way Analysis of Variance (ANOVA) to
%   quantify the proportion of the total variability in the data that is
%   explained by the group differences (i.e., the independent variable).
%   They are useful for understanding the practical significance of the
%   findings, as statistical significance alone does not necessarily imply
%   that the effect is practically meaningful.
%
%   Differences between Eta-squared (η²) and Omega-squared (ω²):
%   1. Bias: Eta-squared (η²) is a biased estimator of the population effect
%   size, which means that it tends to overestimate the true effect size in
%   the population. On the other hand, Omega-squared (ω²) is an unbiased
%   estimator of the population effect size, providing a more accurate
%   estimate.
%   2. Calculation: Eta-squared (η²) is calculated as the ratio of the sum
%   of squares between groups (SS_between) to the total sum of squares
%   (SS_total), while Omega-squared (ω²) is calculated using both the sum
%   of squares between groups (SS_between) and the sum of squares within
%   groups (SS_within), as well as their corresponding degrees of freedom.

% Which one to use:
% 
% In general, it is recommended to use Omega-squared (ω²) because it is an 
% unbiased estimator of the population effect size and provides a more accurate 
% estimate of the true effect size. Eta-squared (η²) may still be reported in 
% some cases, but it is important to keep in mind that it tends to overestimate 
% the true effect size. If you are comparing your results to previous research
% that reported Eta-squared, it might be useful to report both effect sizes 
% for the sake of comparability.
% 
% In summary, while both Eta-squared and Omega-squared are effect size measures
% used in ANOVA, Omega-squared is generally preferred due to its unbiased nature
% and more accurate representation of the true population effect size.

% Check the number of input arguments
narginchk(1, 2);

% Parse input arguments
if nargin == 1
    if iscell(varargin{1})
        groups = varargin{1};
    elseif ismatrix(varargin{1})
        groups = num2cell(varargin{1}, 1);
    else
        error('Invalid input. Expected a matrix or cell array.');
    end
elseif nargin == 2
    values = varargin{1};
    group_labels = varargin{2};
    if isnumeric(group_labels)
        groups = arrayfun(@(x) values(group_labels== x), unique(group_labels), 'UniformOutput', false);
    else
        groups = arrayfun(@(x) values(strcmp(group_labels, x)), unique(group_labels), 'UniformOutput', false);
    end
end

% Remove NaNs from the groups
groups = cellfun(@(x) x(~isnan(x)), groups, 'UniformOutput', false);

% Calculate the means
grand_mean = nanmean(cell2mat(groups));
group_means = cellfun(@nanmean, groups);

% Calculate the sums of squares
SStotal = nansum(cellfun(@(x) nansum((x - grand_mean).^2), groups));
SSbetween = nansum(cellfun(@(x, m) numel(x) * (m - grand_mean)^2, groups, num2cell(group_means)));
SSwithin = nansum(cellfun(@(x, m) nansum((x - m).^2), groups, num2cell(group_means)));

% Calculate the degrees of freedom
df_between = numel(groups) - 1;
df_within = numel(cell2mat(groups)) - numel(groups);
df_total = numel(cell2mat(groups)) - 1;

% Calculate effect sizes
eta_squared = SSbetween / SStotal;
omega_squared = (SSbetween - (df_between * (SSwithin / df_within))) / (SStotal + (SSwithin / df_within));


