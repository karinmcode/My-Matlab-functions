function [str,Mean,SEM]=getMeanSE(y,varargin)
%[str,Mean,SEM]=getMeanSE(y)
n= numel(y);
Mean = nanmean(y);
SEM = std(y)/sqrt(n);

% define digits
if isempty(varargin)
    Format = '%.3f';
else
    Format = varargin{1};
end

MeanStr = num2str(Mean,Format);
SEMStr = num2str(SEM,Format);

str = sprintf('MEAN %s SEM = %s %s %s'  ,char(177),MeanStr,char(177),SEMStr );