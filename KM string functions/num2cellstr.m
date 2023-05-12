function c=num2cellstr(Num,varargin)
% str=num2cellstr(Num,Format)
if ~isempty(varargin)
    Format = varargin{1};
    c = cellfun(@(x) num2str(x,Format),num2cell(Num),'UniformOutput',false);
else
    c = cellfun(@(x) num2str(x),num2cell(Num),'UniformOutput',false);
end
