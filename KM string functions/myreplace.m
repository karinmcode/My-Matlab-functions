function str2=myreplace(str,OLD,NEW)
% str can be a string or a cell string

ISCELL = iscell(str);

if ISCELL
    str2 = str;
    for i = 1:numel(str)
        str2{i} = replace(str{i},OLD,NEW);
    end
else
str2 = replace(str,OLD,NEW);

end
