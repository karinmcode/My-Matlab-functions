function M=mymedian(A,varargin)

if isempty(varargin)
    DIM = 'all';
else
    DIM = varargin{1};
end

if iscell(A)
    M = cellfun(@(x) median(x,DIM,"omitnan"),A,'UniformOutput',false);
else
    M = median(A,DIM,"omitnan");
end
