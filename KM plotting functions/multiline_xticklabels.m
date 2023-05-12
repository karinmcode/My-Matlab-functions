function multiline_xticklabels(ax,labelArray)
% multiline_xticklabels(ax,labelArray)
nrow = size(labelArray,1);
ncol = size(labelArray,2);

% check that all cells contains string/chars
for i=1:numel(labelArray)
    cellval = labelArray{i};
    if ~isa(cellval,"char")
        labelArray{i} = num2str(cellval);
    end
end
% multiline xticklabel
labelArray = strjust(pad(labelArray),'center'); 
tickLabels = sprintf([repmat('%s\\newline',1,nrow-1) '%s\n'], labelArray{:});
set(ax,'xticklabel',tickLabels);
