function [M,I]=mymin(A,varargin)

if isempty(varargin)
    DIM = 'all';
else
    DIM = varargin{1};
end

if iscell(A)
    N = numel(A);
    M = cell(size(A));
    I = M;
    for i = 1:N
        [M{i},I{i}] = min(A{i},[],DIM,"omitnan");
    end
else
    [M,I]=min(A,[],DIM,"omitnan");
end

I(isnan(M))=nan;
