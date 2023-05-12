function M=myste(A,varargin)
% M=myste(A,varargin)
if isempty(varargin)
    DIM = 'all';
else
    DIM = varargin{1};
end

if iscell(A)
    M = cellfun(@(x) std(x,0,DIM,"omitnan")./sqrt(sum(~isnan(x),DIM)),A,'UniformOutput',false);
else
    M = std(A,0,DIM,"omitnan")./sqrt(sum(~isnan(A),DIM));
end