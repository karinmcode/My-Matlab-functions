function fig=makegoodfig(name,varargin)
%% fig=makegoodfig(name,varargin)
% if ismember(varargin,'slide')
% if ismember(varargin,'slide_half_height')
% if ismember(varargin,'slide_half_width')
% if ismember(varargin,'slide_col3')
% if ismember(varargin,'slide_row2')
% if ismember(varargin,'square')

% if contains(varargin,'fullscreen')
isNOTUIFIG = true;
if ~isempty(varargin)
    isNOTUIFIG =~ismember(varargin,'uifigure');
end
if isNOTUIFIG
    fig = findobj('type','figure','name',name);
else
    fig = findall(0,'Type','figure','name',name);
end
GUI = findobj('tag','GUI');

if isempty(fig)
    if isNOTUIFIG
        fig = figure('color','w','name',name);
    else
        fig = uifigure('color','w','name',name);
    end
    if ~isempty(GUI)
        p = GUI.Position;
        fig.Position = p;
        fig.Position(1) = p(1)+p(3);
    else%plot on leftest screen
        p = get(0,'MonitorPositions');
        p = p(p(:,1)==max(p(:,1)),:);%most right
        fig.Position(1) = p(1)+p(3)*0.1;
        fig.Position(2) = p(2)+p(4)*0.1;
    end
else
    figure(fig(1));
    clf(fig(1));
end
set(fig,'units','pix');

if ismember(varargin,'slide')
    fig.Position(3:4)=[1280 720];
end
if ismember(varargin,'square')
    fig.Position(3:4)=[720 720];
end

if ismember(varargin,'paper')
    fig.Position(3:4)=[3508 2480]/4;
end

if ismember(varargin,'slide_half_height')
    fig.Position(3:4)=[1280 720/2];
end
if ismember(varargin,'slide_half_width')
    fig.Position(3:4)=[1280/2 720];
end

if ismember(varargin,'slide_col3')
    fig.Position(3:4)=[1280/3 720];
end

if ismember(varargin,'slide_row2')
    fig.Position(3:4)=[1280 720/2];
end


if contains(varargin,'fullscreen')
    p = get(0,'MonitorPositions');
    p = p(p(:,1)==max(p(:,1)),:);%most right

    if ~isempty(GUI)
        p(1:2) = GUI.Position(1:2);
    end
    p(3)=p(3)*0.90;
    p(4)=p(4)*0.90;
    fig.Position=p;

end

end