function prefix=mygetprefix(C)
% prefix=myprefix(C)
% C: cell array of strings
% C = {'prefix_1' 'prefix_278' 'prefix_3' 'prefix_456' 'prefix_5' 'prefix_6' }
s = char(C(:));
all_rows_same = all(s == s(1,:),1);
last_common_cols = find(~all_rows_same, 1, 'first')-1;
if isempty(last_common_cols)
    prefix = '';
else
    prefix = s(1,1:last_common_cols);
end
