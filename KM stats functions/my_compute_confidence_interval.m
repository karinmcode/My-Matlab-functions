function [lower_bound, upper_bound] = my_compute_confidence_interval(data, confidence_level, df)
% Computes the confidence interval for a given dataset
% data: the dataset as a vector
% confidence_level: the desired confidence level (default = 0.95)
% df: degrees of freedom (default = length(data)-1)

% Set default values for confidence_level and df if not provided
if nargin < 2
    confidence_level = 0.95;
end
if nargin < 3
    df = length(data) - 1;
end

% Compute sample mean and standard deviation
sample_mean = mean(data);
sample_std = std(data);

% Compute t-value for the given confidence level and degrees of freedom
t_value = tinv((1 - confidence_level) / 2, df);

% Compute margin of error
margin_of_error = t_value * (sample_std / sqrt(length(data)));

% Compute confidence interval
lower_bound = sample_mean - margin_of_error;
upper_bound = sample_mean + margin_of_error;

end
