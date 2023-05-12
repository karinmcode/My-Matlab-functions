function EXISTS=myisfile(urls)
%% ANS=myisfile(urls)
if ~iscell(urls)
    urls = {urls};
end
N = numel(urls);
EXISTS = false(N,1);
for i = 1:N
    url = urls{i};

if contains(url,'*')
    foo = dir(url);
    if ~isempty(foo)
        EXISTS(i)=true;
    end
else
    EXISTS(i)= exist(url,'file')==2;
end    


end


