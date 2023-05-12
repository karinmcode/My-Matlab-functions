function [E]=myextrema(A,DIM)
%  [E]=myextrema(A,DIM)


MIN = mymin(A,DIM);
MAX = mymax(A,DIM);


E = MAX;
i4 = abs(MIN)>abs(MAX);
E(i4)=MIN(i4);