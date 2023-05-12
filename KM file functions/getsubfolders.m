function [subfoldernames,sub_folders]=getsubfolders(fo)

% get the folder contents
d = dir(fo);
% remove all files (isdir property is 0)
dfolders = d([d(:).isdir]) ;
% remove '.' and '..' 
sub_folders = dfolders(~ismember({dfolders(:).name},{'.','..'}));
subfoldernames = {sub_folders(:).name}';

end