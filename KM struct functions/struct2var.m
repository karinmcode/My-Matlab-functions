function struct2var(struct_value,struct_name)
% struct2var(struct_value,struct_name)

varnames = fieldnames(struct_value);
nvar = numel(varnames);

for ivar = 1:nvar
    varname = varnames{ivar};

    evalin('caller',sprintf('%s=%s.%s;',varname,struct_name,varname));
end