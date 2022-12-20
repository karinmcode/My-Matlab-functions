function OutputVar=var2struct(VarList)
% OutputVar=var2struct(VarList);

nfi = numel(VarList);
OutputVar = struct();

for ifi =1:nfi
    fi = VarList{ifi};
    cmd = [fi ';'];
    try
    OutputVar.(fi) = evalin("caller",cmd);
    catch err
        warning(err.message);
    end
end