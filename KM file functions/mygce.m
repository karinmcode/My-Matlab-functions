function [a , d , rec,prefix,suffix,fn0] = mygce(u)
% [a , d , rec] = mygce(u)
% u can be url or filename

if contains(u,filesep)
u = myfilename(u);
end

prefix = {};
suffix = {};
if startsWith(u,'proc_')
    prefix = vertcat(prefix,'proc_');
end
if startsWith(u,'CAM*_')
    prefix = vertcat(prefix,'CAM');
end



u = replace(u,{'proc_' 'CAM1_' 'CAM2_'},'');
u = replace(u,'.mat','');
u = replace(u,'.avi','');
u = replace(u,'.mp4','');

c = strsplit(u,'_');
a = c{1};
d = c{2};
rec = c{3};

fn0 = sprintf('%s_%s_%s',a,d,rec);
