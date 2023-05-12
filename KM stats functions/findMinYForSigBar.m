function  y=findMinYForSigBar(x)
% find y pos for significance bar

ax=gca;
ch = ax.Children;
nch = numel(ch); 
y = nan;
for ich = 1:nch

    c = ch(ich);
    f = fieldnames(c);
    if ismember('XData',f)
        xc = c.XData;
        if any(ismember(x,xc))
            yc = c.YData(ismember(xc,x));
            y = mymax([y;yc(:)]);
        end
    end
end