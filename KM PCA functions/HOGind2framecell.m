function cellpos=HOGind2framecell(idx,I,CellSize,NumBins,BlockSize,BlockOverlap)
%  cellpos=HOGind2framecell(I,cell_size,nbOfBinsPerCell,BlockSize,BlockOverlap)

%{
frame_size = 576 x 704;

HOG parameters:
nbOfCellsPerFrame = 20 rows x 20 columns;
CellSize = [29    35];% 29 rows, 35 columns
nbOfBinsPerCell = 9;% Number of orientation histogram bins
BlockSize = [2 2] ;% Number of cells in block
BlockOverlap = 1;
BlocksPerImage =  floor((size(I)./CellSize – BlockSize)./(BlockSize – BlockOverlap) + 1);

Variables:
HOG: NFrames-by-N_HOGfeatures matrix
N_HOGfeatures = prod([BlocksPerImage, BlockSize, NumBins]);
extractHOGFeatures
%}
[ro,co]=size(I);
BlocksPerImage =floor((size(I)./CellSize - BlockSize)./(BlockSize - BlockOverlap) + 1);
nHOGfeatures = prod([NumBins BlockSize BlocksPerImage]);
idx_his= repmat(1:NumBins,1,prod(BlockSize)*prod(BlocksPerImage));
idx_block = repmat((1:prod(BlocksPerImage ))',1,prod([BlockSize NumBins]))';
idx_block = idx_block(:);

% find block
this_block = idx_block(idx);
[r,c]=ind2sub(BlocksPerImage,this_block);% blocks are indexed in columns
BlockSize_pix =BlockSize.*CellSize;

% block step size 
blockStepInPixels = CellSize.*(BlockSize - BlockOverlap);
XPIX = 0.5:blockStepInPixels(2):co;
YPIX = 0.5:blockStepInPixels(1):ro;

xpix = XPIX(c);
ypix = YPIX(r);
cellpos =[xpix ypix BlockSize_pix];


% helpHOG_testing_script
