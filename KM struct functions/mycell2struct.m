function s=mycell2struct(c,headers)
% manages invalid fieldnames
n = numel(headers);
new_headers = headers;
for i = 1:n

    h = headers{i};
    h = replace(h,'  ',' ');
    h = replace(h,' ','_');
    h = replace(h,{'(' ')' '[' ']'},'__');
    h = replace(h,'.','o');
    new_headers{i}=h;
end

s= cell2struct(c,new_headers);