function         topPCAVar = getTopPCAVar(coeff,topK)
% topPCAVar = getTopPCAVar(coeff,topK)
% nvar = size(coeff,1);
% nPC =size(coeff,2);

nvar = size(coeff,1);
nPC =size(coeff,2);
topPCAVar = nan(topK,nPC);
for ipc =1:nPC
    c = coeff(:,ipc);
    [sorted,isort]=sort(abs(c),'descend');
    topPCAVar(:,ipc)=isort(1:topK);
end