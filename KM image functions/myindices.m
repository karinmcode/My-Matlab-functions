function idx = myindices(nrow,ncol,irows,icols);
% get ROI indices
%  idx = myindices(nrow,ncol,,irows,icols);
row_idx = repmat(irows(:),1,numel(icols));
col_idx = repmat(icols,numel(irows),1);
idx = sub2ind([nrow ncol],row_idx(:),col_idx(:));