function M=mymean(A,varargin)

if isempty(varargin)
    DIM = 'all';
else
    DIM = varargin{1};
end

if iscell(A)
    M = cellfun(@(x) mean(x,DIM,"omitnan"),A,'UniformOutput',false);
else
    M = mean(A,DIM,"omitnan");
end
