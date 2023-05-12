function s=keepfield(s,f)

F = fieldnames(s);
s1 = rmfield(s,F(~ismember(F,f)));

s=orderfields(s1,f);