function pa=add_patches(ax,x,y,dur,CO,Alpha)
% pa=add_patches(ax,x,y,duration,a)
%  pa=add_patches(ax,x,[],d,a)
n = numel(x);
pa = gobjects(n,1);
x= x(:);
dur = dur(:);
XPA = [x x x+dur x+dur];
% height
if isempty(y)
    YLIM  =ylim(ax);
    ypa = [YLIM(1) YLIM(2) YLIM(2) YLIM(1)];%[-1; 1; 1;-1].*
else
    ypa = [y(1) y(2) y(2) y(1)];%[-1; 1; 1;-1].*
end
%transparency
if isempty(Alpha)
    Alpha = 0.3;
end

% color
if isempty(CO)
    CO = repmat([1 1 1]*0.5,n,1);
end
if size(CO,1)~=n
    CO = repmat(CO,n,1);
end

hold(ax,'on');

for i = 1:n

    xpa = XPA(i,:);
    co = CO(i,:);

    % add patch
    pa(i) = patch(ax,xpa, ypa, co,'EdgeColor','none','FaceAlpha',Alpha,'FaceColor',co...
        ,'Marker','none', 'MarkerEdgeColor',co,'MarkerFaceColor',co,'tag','KMPatch');
end





