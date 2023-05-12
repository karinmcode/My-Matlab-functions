function newxy = mytranslation(oldxy,d,a)
%%  newxy = mytranslation(oldxy,dist,ang_in_degree)
% oldxy = [x y];
npoints = size(oldxy,1);
xy = [oldxy';ones(1,npoints)];% each column = xyz coord of point
xtrans = sind(a)*d;%
ytrans = cosd(a)*d;%
tform = [1 0 xtrans;0 1 ytrans; 0 0 1];
newxy = tform*xy;
newxy = newxy(1:2,:)';% each row = xy coor of point

