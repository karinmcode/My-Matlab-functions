function [M,I]=mymax(A,varargin)

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
        [M{i},I{i}] = max(A{i},[],DIM,"omitnan");
    end
else
    if numel(DIM)==1
    [M,I]=max(A,[],DIM,"omitnan");
    else
    [M,I]=max(A,[],DIM,"omitnan",'linear');
    end
end

I(isnan(M))=nan;
