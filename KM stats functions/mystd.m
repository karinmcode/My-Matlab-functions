function STD=mystd(A,varargin)

if isempty(varargin)
    DIM = 'all';
else
    DIM = varargin{1};
end

if iscell(A)
    STD = cellfun(@(x) std(x,0,DIM,"omitnan"),A,'UniformOutput',false);
else
    STD=std(A,0,DIM,"omitnan");
end