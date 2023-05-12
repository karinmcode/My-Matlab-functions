%% function H=myshadederror(X,Y,Co,facealpha,varargin)
function  H=myshadederror(X,Y,Co,facealpha,varargin)
%  H=myshadederror(X,Y,Co,facealpha,varargin)
% varargin = 'ste'
Ym = mymean(Y,1);
if contains(varargin,'ste')
    Ye = myste(Y,1);
else
    Ye = mystd(Y,1);
end

if isempty(facealpha)
    facealpha=0.2;
end
H.patch=fill([X(:);flipud(X(:))],[Ym(:)-Ye(:);flipud(Ym(:)+Ye(:))],'r','linestyle','none','marker','none','facecolor',Co);
hold("on")
H.line=plot(X,Ym,'-','color',Co*0.5);
paCol = Co*1.1;
paCol(paCol>1) = 1;
set(H.patch,'linestyle','none','facealpha',facealpha,'facecolor',paCol)
end