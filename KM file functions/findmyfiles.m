function urls=findmyfiles(url)


list = dir(char(url));

isnotdir = [list.isdir]==0;
fn = {list(isnotdir).name}';
urls = fullfile(fileparts(url),fn);