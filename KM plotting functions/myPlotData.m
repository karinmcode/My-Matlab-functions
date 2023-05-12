function [fig,AX,H]=myPlotData(Signal,X)

is2D = numel(size(Signal))==2;


fig = makegoodfig('myPlotData','slide');
if is2D
    nrow = 1;
    ncol = 2;
    AX = mysubplot([],nrow,ncol);

    if ~exist('X','var')
        X = 1:size(Signal,2);
    end
    H.pl=plot(AX(1),X,Signal','-');
    Y = 1:size(Signal,1);
    H.im=imagesc(AX(2),X,Y,Signal);
else

    keyboard
end
