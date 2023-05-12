%% HOG_testing_script
CellSize = [2 2];
I = zeros(CellSize(2)*5,CellSize(2)*3);
I(1,end)=0.5;
I(2,end)=1;
I = zeros(CellSize(2)*4,CellSize(2)*4);
I(8,4)=1;


idx = 150;


ro = size(I,1);
co = size(I,2);
nrows = floor(ro./CellSize(1));
ncols = floor(co./CellSize(2));

 [features, visualisation] = extractHOGFeatures(I,'CellSize',[2 2]);
 struct2var(visualisation,'visualisation');

 % plotting
 makegoodfig('HOGtest','fullscreen');
 ax1 = subplot(2,1,1,'replace');
 him=imagesc([1:size(I,2)],[1:size(I,1)],I);
 hold on;
 n=max([ro co]);
 for i = 1:n
     plot([.5,n+.5],[i-.5,i-.5],'w:',[i-.5,i-.5],[.5,n+.5],'w:');
 end
 
  n=max([ro co]);
 for i = 1:CellSize(1):n
     plot([.5,n+.5],[i-.5,i-.5],'w-',[i-.5,i-.5],[.5,n+.5],'w-','linewidth',3);
 end

 plot(visualisation);
 axis equal image ij;
 goodax(ax1,'xtick',1:co,'ytick',1:ro,'xlim',[0 co]+0.5,'ylim',[0 ro]+0.5,'xlabel','pix','ylabel','pix');

 ax2 = subplot(2,1,2,'replace');
 colormap(ax2,'jet')
 plot(features,'-or');
 hold on;
 nfeat = numel(features);%72

% compute variables

ncells = prod(floor(size(I)./CellSize));
 BlocksPerImage =floor((size(I)./CellSize - BlockSize)./(BlockSize - BlockOverlap) + 1);%[1 2]
nHOGfeatures = prod([NumBins BlockSize BlocksPerImage]);%72

idx_his= repmat(1:NumBins,1,prod(BlockSize)*prod(BlocksPerImage));
idx_block = repmat((1:prod(BlocksPerImage ))',1,prod([BlockSize NumBins]))';
idx_block = idx_block(:);

% plotting
scatter(1:nfeat,features,30*(features*0+1),idx_block,'LineWidth',3)
scatter(1:nfeat,features,30*(features*0+1),idx_his,'filled','LineWidth',1)

 text(1:nfeat,features,mynum2str(idx_his,'%g','cellstr'),'verticalalignment','top','color','r')
 text(1:nfeat,features,mynum2str(idx_block,'b%g','cellstr'),'verticalalignment','bottom','color','b')
ylabel('features values')
stem(idx,1,"filled",'color','k')
i4blocks = [0 ;find(diff(idx_block)==1)]+0.5;
blst = stem(i4blocks,ones(1,numel(i4blocks)),'-b');
text(i4blocks+0.5,ones(1,numel(i4blocks)),mynum2str(1:numel(i4blocks),'b%g','cellstr'),'verticalalignment','bottom','color','b','fontweight','bold','fontsize',14)

i4cells = find([diff(idx_his)<0 true])+0.5;
blst = stem(i4cells,ones(1,numel(i4cells)),':k');

ylim([-0.3 1])
% find index
BlockSize_pix =BlockSize.*CellSize;

this_block = idx_block(idx);

% cmput steps
blockStepInPixels = CellSize.*(BlockSize - BlockOverlap);
XPIX = 0.5:blockStepInPixels(2):co;
YPIX = 0.5:blockStepInPixels(1):ro;


for this_block = 1:prod(BlocksPerImage)
[r,c]=ind2sub(BlocksPerImage,this_block);% blocks are indexed in rows
xpix = XPIX(c);


ypix = YPIX(r);

cellpos =[xpix ypix BlockSize_pix];

rect=drawrectangle(ax1,'Position',cellpos);
set(rect,'label',sprintf('b%g i%g',this_block,idx),'color',rand(1,3),'linewidth',1,'MarkerSize',1,'FaceAlpha',0.3,'LabelAlpha',0.3)
end



