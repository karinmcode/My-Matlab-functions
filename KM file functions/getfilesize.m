function Sizes=getfilesize(urls)
%% Sizes=getfilesize(urls)
if ~iscell(urls)
    urls = {urls};
end
N= numel(urls);
Sizes= cell(N,1);
for i=1:N
    url =urls{i};
    file = dir(url);
    fileSize = file.bytes;
    fileName = file.name;
    if fileSize < 1025
        S=sprintf( '%.0f B\n', fileSize);
    elseif fileSize < 1024^2+1
        S=sprintf('%.0f KB\n', fileSize/1024);
    elseif fileSize < 1024^3+1
        S=sprintf('%.0f MB\n', fileSize/1024^2);
    else
        S=sprintf('%.0f GB\n', fileSize/1024^3);
    end
    Sizes{i}=S;
end %N

if N ==1
    Sizes = Sizes{1};
end

end
