function [params,param_names] = myparseinputs(vararginIN)

if isempty(vararginIN)
    params = struct();
    param_names = cell(1,0);
    return;
end
varargin = vararginIN{1};

p = inputParser();
p.CaseSensitive =false;
p.KeepUnmatched =true;
try
    parse(p,varargin{:})%p.Results
catch
    varargin = vararginIN;
    parse(p,varargin{:})%p.Results
end

paramsWithCap = p.Unmatched;
param_names = fieldnames(paramsWithCap);

params = struct();
for i = 1:numel(param_names)
    params.(lower(param_names{i}))=paramsWithCap.(param_names{i});
end
param_names = fieldnames(params);