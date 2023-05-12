function mymkdir(INPUT)
% INPUT can be folder or url
[PATH,~,EXT]=fileparts(INPUT);

% INPUT is non existing folder
if isempty(EXT) && ~isfolder(INPUT)
    mkdir(INPUT);
end

% INPUT
if ~isempty(EXT) && ~isfolder(PATH)
    mkdir(PATH);
end
