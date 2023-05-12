function N=mynumel(X)

if iscell(X)
    try
    N = cellfun(@(x) numel(x),X,'UniformOutput',true);
    catch
    N = cell2mat(cellfun(@(x) numel(x),X,'UniformOutput',false));
    end
else
    N=numel(X);
end