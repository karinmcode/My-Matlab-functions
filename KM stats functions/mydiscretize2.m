function [binid,ixbin,iybin]=mydiscretize2(x,y,xbin,ybin,binid_img)
% [binid,xbin,ybin]=mydiscretize2(x,y,xbin,ybin,binid2)
% find points bin in 2D and assign id from binid_img

pid = unique(binid_img(:));
nid = numel(pid);
npoints = numel(x);

% preallocate
ixbin = nan(npoints,1);
iybin = nan(npoints,1);
binid = nan(npoints,1);
x(x>max(xbin))=max(xbin);
y(y>max(ybin))=max(ybin);
x(x<min(xbin))=min(xbin);
y(y<min(ybin))=min(ybin);
for ipo = 1:npoints
    xp = x(ipo);
    yp = y(ipo);
    ixbin(ipo) = discretize(xp,xbin);
    iybin(ipo) = discretize(yp,ybin);
    binid(ipo) = binid_img(iybin(ipo),ixbin(ipo));
end