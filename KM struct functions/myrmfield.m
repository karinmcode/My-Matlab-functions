function s=myrmfield(s,list)
% s=myrmfield(s,list)
if ~iscell(list)
    list = {list};
end

for i=1:numel(list)
    try
    s = rmfield(s,list{i});
    end
end