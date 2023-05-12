function axrepos(varargin)
%% axrepos(varargin)
% axrepos(varargin)
% repositions axes of the current figure or targetted axes in input
% input names are case insensitive

% EXAMPLES:
% axrepos('axes',AXES_HANDLES,'VerticalDistribute',{ yBottom, yTop},'HorizontalDistribute',{leftMargin, rightMargin})

% INPUTS: 

% - INPUTS AX related

% - INPUT for grid repositioning
% 'Grid', {xLeft, xRight, yBottom, yTop }

% - INPUT vertical 
% 'VerticalShrink', shrinkingCoeff
% 'VerticalShift', shiftCoeff
% 'VerticalDistribute', { yBottom, yTop }
% 'VerticalAlign', {AX, AXtemplate}
% 'AlignHeight', {AX, AXtemplate}
% 'Height', {AX, Height}

% - INPUT horizontal positionning 

% 'HorizontalShrink', shrinkingCoeff
% 'HorizontalStretch', {AX,stretchCoeff>0, [ismember(refPointOptinal,[-1 0 1]]}
% 'HorizontalShift', shiftCoeff
% 'HorizontalDistribute', {AX, yLeft, yRight }
% 'HorizontalAlign', {AX, AXtemplate}
% 'AlignWidth', {AX, AXtemplate} 
% 'Width', {AX, Width} 





%% check input
p = inputParser;
p.KeepUnmatched = true;
parse(p,varargin{:})%p.Results
paramsCAP = p.Unmatched;
params_namesCAP = fieldnames(paramsCAP)';

%% make all lowercase
nparams = numel(params_namesCAP);
params = struct();
for ipa = 1:nparams
    paramNameLow = lower(params_namesCAP{ipa});
    params.(paramNameLow)= paramsCAP.(params_namesCAP{ipa});
end
params_names = fieldnames(params);
%% axes related
if ismember('axes',params_names)
    AX = params.axes;
else
    AX = findobj(gcf,'type','Axes');
end
nax = numel(AX);
if nax==1
    AX_initial_pos = get(AX,'position');
else
AX_initial_pos=cell2mat(get(AX,'position'));
end
% ---------------------------------------------
% ---------------------------------------------
% ---------------------------------------------
% ---------------------------------------------
% ---------------------------------------------
% ---------------------------------------------
% ---------------------------------------------
%% ---------------------------------------------
%% grid % 'Grid', {xLeft, xRight, yBottom, yTop }

if ismember('grid',params_names)

LEFT = params.grid{1};
RIGHT = params.grid{2};
BOTTOM = params.grid{3};
TOP = params.grid{4};

nrow = size(AX,1);
ncol = size(AX,2);

hSpan = RIGHT-LEFT;
vSpan = TOP-BOTTOM;
hOff1 = 0.01*hSpan;
hOff = 0.01;
hOffSpan = hOff1+hOff*(ncol-1);
w = (0.9*hSpan-hOffSpan)/ncol;
h = w;

% set x and y positions
xpos = [LEFT linspace(LEFT+w+hOff1,RIGHT-w,ncol)];
ypos = linspace(TOP,BOTTOM,nrow);

for icol = 1:ncol
    for irow = 1:nrow
        AX(irow,icol).Position(1:2)=[xpos(icol) ypos(irow)];
        AX(irow,icol).Position(3:4)=[w h];
    end
end


end


%% verticalshrink: modify vertical dimensions
if ismember('verticalshrink',params_names)

    y  = AX_initial_pos(:,2);
    h = AX_initial_pos(:,4);

    newh = h*params.verticalshrink;%params.VerticalShrink = 0.80
    vert_offset = h-newh;
    newy = y+vert_offset;
    for iax = 1:nax
        ax = AX(iax);
        ax.Position([2 4])= [newy(iax) newh(iax)];
    end
end


if ismember('verticalshift',params_names)
keyboard
    y  = AX_initial_pos(:,2);
    h = AX_initial_pos(:,4);

    newh = h*params.verticalshift;%params.VerticalShrink = 0.80
    vert_offset = h-newh;
    newy = y+vert_offset;
    for iax = 1:nax
        ax = AX(iax);
        ax.Position([2 4])= [newy(iax) newh(iax)];
    end
end



if ismember('verticaldistribute',params_names)
    yBottom = params.verticaldistribute{1};%yBottom = 0.03;
    yTop = params.verticaldistribute{2};%yTop = 0.93;
    nrow = size(AX,1);

    h = AX(1).OuterPosition(4);
    ypos  = linspace(yTop-h,yBottom,nrow);

    for irow = 1:nrow
        ax_row = AX(irow,:);
        [~, ax_row]=isaxes(ax_row);
        nax_row = numel(ax_row);
        for iax=1:nax_row
            ax = ax_row(iax);
            ax.OuterPosition(2)= ypos(irow);
        end
    end
end

if ismember('verticalalign',params_names)

    AXtemplate = params.verticalalign;
    for iax = 1:nax
        ax = AX(iax);
        axt = AXtemplate(iax);
        ax.Position(2)=axt.Position(2);
    end

end

if ismember('alignheight',params_names)

    AXtemplate = params.alignheight;
    for iax = 1:numel(AX)
        ax = AX(iax);
        axt = AXtemplate(iax);
        ax.Position(4)=axt.Position(4);
    end

end


%% modify horizontal dimensions
if ismember('horizontalshrink',params_names)

    y  = AX_initial_pos(:,1);
    h = AX_initial_pos(:,3);

    newh = h*params.horizontalshrink;%params.horizontalshrink = 0.80
    vert_offset = h-newh;
    newy = y+vert_offset;
    for iax = 1:nax
        ax = AX(iax);
        ax.Position([1 3])= [newy(iax) newh(iax)];
    end
end

if ismember('horizontalshift',params_names)
keyboard
    y  = AX_initial_pos(:,1);
    h = AX_initial_pos(:,3);

    newh = h*params.horizontalshift;%params.VerticalShrink = 0.80
    vert_offset = h-newh;
    newy = y+vert_offset;
    for iax = 1:nax
        ax = AX(iax);
        ax.Position([1 3])= [newy(iax) newh(iax)];
    end
end

if ismember('horizontalstretch',params_names)

    if numel(params.horizontalstretch)==2
        refPoint = 0;
        stretchCoeff = params.horizontalstretch;
    else
        stretchCoeff = params.horizontalstretch{1};
        refPoint = params.horizontalstretch{2};
    end
    AX_initial_pos=cell2mat(get(AX,'position'));

    x  = AX_initial_pos(:,1);
    w = AX_initial_pos(:,3);

    neww = w*stretchCoeff;%params.VerticalShrink = 0.80
    switch refPoint
        case -1% left 
            h_offset = 0;
        case 0% center
            h_offset = (w-neww)/2;
        case 1% right
            h_offset = w-neww;
    end
    newx = x+h_offset;

    for iax = 1:numel(AX)
        ax = AX(iax);
        ax.Position([1 3])= [newx(iax) neww(iax)];
    end
end

if ismember('horizontaldistribute',params_names)
    yBottom = params.horizontaldistribute{1};%yBottom = 0.03;
    yTop = params.horizontaldistribute{2};%yTop = 0.93;
    nrow = size(AX,1);

    h = AX(1).OuterPosition(4);
    ypos  = linspace(yTop-h,yBottom,nrow);

    for irow = 1:nrow
        ax_row = AX(irow,:);
        [~, ax_row]=isaxes(ax_row);
        nax_row = numel(ax_row);
        for iax=1:nax_row
            ax = ax_row(iax);
            ax.OuterPosition(2)= ypos(irow);
        end
    end
end

if ismember('horizontalalign',params_names)

    AXtemplate = params.horizontalalign;
    for iax = 1:numel(AX)
        ax = AX(iax);
        axt = AXtemplate(iax);
        ax.Position(2)=axt.Position(2);
    end

end

if ismember('alignwidth',params_names)

    AXtemplate = params.alignwidth;
    for iax = 1:numel(AX)
        ax = AX(iax);
        axt = AXtemplate(iax);
        ax.Position(4)=axt.Position(4);
    end


end