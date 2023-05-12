function [rho, pval]=mycorr(X,Y)
inonan=~any(isnan([X Y]),2);
X = X(inonan);
Y = Y(inonan);

[rho, pval]=corr(X,Y);