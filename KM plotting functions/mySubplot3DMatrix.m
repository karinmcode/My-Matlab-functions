function mySubplot3DMatrix(data,nrow,ncol)

makegoodfig('mySubplot3DMatrix','slide');
if ~exist('nrow','var')
    nrow = min([7 size(data,1)]);
end
if ~exist('ncol','var')
    ncol =  size(data,3);
end
AX = mysubplot([],nrow,ncol);
for irow = 1:nrow

    for icol = 1:ncol

        ax = AX(irow,icol);

        d = data(irow,:,icol);

        plot(ax,d,'b-');

    end
    linkaxes(AX(irow,:),'y')
end
