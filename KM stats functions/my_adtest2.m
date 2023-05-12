function [h, p, ad_stat] = my_adtest2(x1, x2)
% Two-sample Anderson-Darling test
% x1 and x2 are matrices of observations, where each row represents a sample
% Returns h=1 if the null hypothesis of equal distribution is rejected
% p is the p-value of the test
% ad_stat is the test statistic

% Concatenate the data into a single matrix
x = [x1; x2];

% Compute the empirical CDFs of the two datasets
n1 = size(x1, 1);
n2 = size(x2, 1);
[f1, x1] = ecdf(x1);
[f2, x2] = ecdf(x2);

% Interpolate the empirical CDFs onto a common set of points
x_range = linspace(min(x), max(x), max(n1, n2));
f1_interp = interp1(x1, f1, x_range, 'linear', 'extrap');
f2_interp = interp1(x2, f2, x_range, 'linear', 'extrap');

% Compute the Anderson-Darling statistic
ad_stat = (n1*n2/(n1+n2)) * sum((f1_interp - f2_interp).^2 ./ (f1_interp.*(1 - f1_interp) + f2_interp.*(1 - f2_interp)));

% Compute the p-value using a reference distribution
ref_dist = get_ad_reference_distribution(n1, n2);
p = sum(ref_dist >= ad_stat) / numel(ref_dist);

% Test the null hypothesis
alpha = 0.05;
h = (p < alpha);

end
