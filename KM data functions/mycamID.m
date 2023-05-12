function camID = mycamID(u);
% camID = mycamID(u);
% camID is a double
if contains(u,filesep)
u = myfilename(u);
end
camID=str2double(u(4));% after CAM
