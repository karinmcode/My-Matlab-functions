function ax=mysubplot(ax,nrow,ncol,varargin)
%% ax=mysubplot(ax,nrow,ncol,varargin)
% CASE nargin==1 : ax=mysubplot(ax,nrow,ncol,index)
% CASE nargin==2 : ax=mysubplot(ax,nrow,ncol,irow,icol)
% CASE nargin>2 : 
%    ax=mysubplot([],nrow,ncol,'leftMargin',LEFT,'rightMargin',RIGHT,'topMargin',TOP,'bottomMargin',BOTTOM)
%    ax=mysubplot([],nrow,ncol,'leftMargin',LEFT,'rightMargin',RIGHT,'topMargin',TOP,'bottomMargin',BOTTOM,'xOffset',xOff,'yOffset',yOff)

%{
varargin:
'leftMargin'
'rightMargin'
'topMargin'
'bottomMargin'
'xOffset'
'yOffset'
'width'
'height'
%}
if isaxes(ax)==0
    error('the first input "ax" needs to be an axe or empty')
    keyboard;
end
params = struct;
param_names = {};
allNumeric = all(~cellfun(@(x) ischar(x) ,varargin,'UniformOutput',true));
if numel(varargin)==1
    isub = varargin{1};
    [icol,irow] = ind2sub([ncol nrow],isub);
elseif numel(varargin)==2 && allNumeric

    irow = varargin{1};
    icol = varargin{2};
else
    icol = nan(2,1);
    [params,param_names] = myparseinputs(varargin);

end

%% delete existing axes if input tag is found
if isfield(params,'tag')
    axes2delete = findobj(gcf,'tag',params.tag);
    delete(axes2delete);
end


% margins
x0 = 0.08;
x1 = 0.88;
y0 = 0.08;
y1 = 0.88;
Xspan = x1-x0;
Yspan = y1-y0;
if ncol==1
    xOff = Xspan*0.1;
else
    xOff = Xspan*0.1/(ncol-1);
end

if nrow == 1
    yOff = Yspan*0.1;
else
    yOff = Yspan*0.1/(nrow-1);
end

if ismember('leftmargin',param_names)
    x0=params.leftmargin;
end
if ismember('rightmargin',param_names)
    x1=params.rightmargin;
end
if ismember('topmargin',param_names)
    y1=params.topmargin;
end
if ismember('bottommargin',param_names)
    y0=params.bottommargin;
end
if ismember('xoffset',param_names)
    xOff=params.xoffset;
end
if ismember('yoffset',param_names)
    yOff=params.yoffset;
end

% recompute x and y space minus offsets
Xspan = x1-x0-xOff*(ncol-1);
Yspan = y1-y0-yOff*(nrow-1);
if Yspan<0.1
    keyboard
end
% width and height of axe
w = Xspan/ncol;
h = Yspan/nrow;
if ismember('width',param_names)
    w=params.width;
end
if ismember('height',param_names)
    h=params.height;
end

% compute x and y positions of axe
xpos = linspace(x0,x1-w,ncol);

ypos = linspace(y1-h,y0,nrow);

if numel(icol)==1
    if isempty(ax)
        ax = axes();
        hold(ax,'on');
    end
    ax.Position = [xpos(icol) ypos(irow) w h];
else
    ax = gobjects(nrow,ncol);
    for irow = 1:nrow

        for icol = 1:ncol
            ax(irow,icol)=axes('position',[xpos(icol) ypos(irow) w h]);
            hold(ax(irow,icol),'on');
        end
    end

end

if isfield(params,'tag')
 set(ax,'tag',params.tag)
end
