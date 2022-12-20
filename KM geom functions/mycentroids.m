function        Centroids=mycentroids(x,y,id)
pclu = unique(id);
nclu = numel(pclu);
Centroids = nan(nclu,2);
xy = [x y];
for iclu=1:nclu
    i4clu = pclu(iclu)==id;
    xy_clu = xy(i4clu,:);
    Centroids(iclu,:) = mymean(xy_clu,1);
end