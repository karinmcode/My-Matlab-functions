function mytestcolormap(CM)

f=makegoodfig('mytestcolormap');
n = size(CM,1);
ax = axes(f);
imagesc(1,1:n,permute(CM,[1 3 2]));