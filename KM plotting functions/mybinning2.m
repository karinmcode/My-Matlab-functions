function [imMosaic,xBins,yBins,NREP]=mybinning2(ax,X,Y,C,binSize)
%  [I,xEdges,yEdges,NREP]=mybinning2(ax,X,Y,C,binSize,X0,Y0)
% Define the x and y coordinates of your points
% X = randn(100,1); % Replace with your own x values
% Y = randn(100,1); % Replace with your own y values
% V = rand(100,1); % Replace with your own values to bin

Opt.mosaicCalc = 'median';
Opt.minrep = 3;

minX = min(X);
maxX = max(X);
minY = min(Y);
maxY = max(Y);

% If mode is computed, make bin  C 
if strcmp(Opt.mosaicCalc,'mode')
C4mode = round(C,1);
end

% Calculate the number of bins needed in each dimension

xBins = [fliplr(0:-binSize:minX) binSize:binSize:maxX];
yBins = [fliplr(0:-binSize:minY) binSize:binSize:maxY];

nX = numel(xBins)-1;
nY = numel(yBins)-1;
binValues =nan(nY,nX);
NREP = nan(nY,nX);

for iX =1:nX
    i4X = X>=xBins(iX)&X<xBins(iX+1);
    for iY = 1:nY
        i4Y = Y>=yBins(iY)&Y<yBins(iY+1);
        i4neu  = i4X&i4Y;
        c = C(i4neu);
        n4neu = sum(~isnan(c));
        c = c(~isnan(c));
        if n4neu>=Opt.minrep
            switch Opt.mosaicCalc
                case 'mean'
                    binValues(iY,iX) = mean(c,"all",'omitnan');
                case 'median'
                    binValues(iY,iX) = median(c,"all",'omitnan');
                case 'mode'
                    c = C4mode(i4neu);
                    c = c(~isnan(c));
                    binValues(iY,iX) = mode(c,"all");
            end
        end
        NREP(iY,iX)=n4neu;
    end
end
dX = mean(diff(xBins))/2;

if ~isempty(findobj(ax,'tag','mybinning2'))
    delete(findobj(ax,'tag','mybinning2'));
end

imMosaic = imagesc(ax,xBins(1:end-1)+dX,yBins(1:end-1)+dX,binValues);
set(imMosaic,'AlphaData',1*double(~isnan(binValues)),'tag','mybinning2')
set(ax,'xtick',xBins,'ytick',yBins,'xlim',[minX maxX],'ylim',[minY maxY]);
axis(ax,'tight','equal')

% put mosaic below cells
ch = ax.Children;
ax.Children= [setdiff(ch,imMosaic); imMosaic];
set(imMosaic,'UserData',Opt.mosaicCalc);



