function A=myzscore(A,DIM)
% get nan across DIM
inan = isnan(A);
i4nan = all(inan,DIM);
i4nonan = ~i4nan;

nDIM = numel(size(DIM));

Atemp = permute(A,[DIM setdiff(1:nDIM,DIM)]);
Atemp = Atemp(inonan,:,:,)
zscore(Atemp)

% get rid of nans





