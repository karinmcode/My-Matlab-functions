function c=mybins2centers(bins)
% c=mybins2centers(bins);

c = movmean(bins,2);
c = c(2:end);