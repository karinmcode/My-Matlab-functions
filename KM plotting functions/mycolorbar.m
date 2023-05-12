function cb= mycolorbar(ax,Colors,varargin)
% cb= mycolorbar(ax,Colors,[labels])
p = ax.Position;
x = p(1)+p(3)*1.05;
y = p(2);
w = 0.05*p(3);
h = p(4);
cb = axes('position',[x y w h]);
Colors2 = permute(Colors,[1 3 2]);
n = size(Colors,1);
imagesc(cb,1,1:n,Colors2);
set(cb,'yaxislocation','right','xcolor','none','ytick',1:n,'tickdir','both','box','off')

if ~isempty(varargin)
    yticklabel = varargin{1};
    nlab = numel(yticklabel);
    if n<nlab
        ytick=0.5:1:(n+0.5);
    else
        ytick = 1:n;
    end

    set(cb,'ytick',ytick,'yticklabel',yticklabel);
end
