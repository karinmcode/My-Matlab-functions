function [isax, AXout]=isaxes(AX)
nax = numel(AX);
isax = false(size(AX));
for iax = 1:nax
    ax = AX(iax);
    isax(iax)=isa(ax,'matlab.graphics.axis.Axes');
end
AXout = AX(isax);
