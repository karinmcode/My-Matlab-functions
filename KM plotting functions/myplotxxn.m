function [ax1,ax,pl]=myplotxxn(ax1,x1,x2,y,varargin)
% [ax1,ax2]=myplotxxn(ax1,x1,x2,y,varargin)
% [ax1,ax2]=myplotxxn(ax1,x1,x2,y);
% assumes linear relation between x1 and x2
%{
%TESTING


clf;clc;clear all;close all;
makegoodfig('plotxxn','slide');

x1 = 0:10;
x2 = x1*2;
y = x1*10;
ax1 = axes();
C = '-ok';
pause(0.05);
[ax1,ax]=myplotxxn(ax1,x1,x2,y,'xlabel',{'frames','time (s)'});



pause(0.05);
xlim(ax1,[2 6])

%}
if isempty(ax1)
    ax1 = axes('tag','ax1');
end



%% plotting ax1

pl=plot(ax1,x1,y,'-');
set(ax1,'color','none','TickDir','in','box','off','PositionConstraint','innerposition');
pause(0.1);

%% move xtick labels of active ax
XAxis1 = ax1.XAxis;
XAxis1.TickLabelGapOffset = 4;

%% plotting ax2 with no color and remove interactions
f = ax1.Parent;
ax2 = axes(f);
warning off;
p=get(ax1,'Position');
warning on;
set(ax2,'position',p,'positionconstraint','innerposition','position',ax1.Position,'color','none','box','off','tag','ax2')
pr=plot(ax2,x2,y,'s-r','color','none');
set(ax2,'YColor',pr(1).Color,'XAxisLocation','bottom','xcolor',[1 1 1]*0.5,'box','off','TickDir','out','color','none');
pause(0.1)
% turn off interactions with ax2 (the passive ax) to simplify the code
ax2.Interactions = []; 
ax2.Toolbar.Visible = 'off'; 
drawnow;
pause(0.1);
%% move xtick labels of passive ax
XAxis2 = ax2.XAxis;
XAxis2.TickLabelGapOffset = 8;% warning error when negative
drawnow;
pause(0.05);
% Original xlims
ax = vertcat(ax1,ax2);
xLimits = vertcat(ax.XLim);

% Original x axis ranges
xRanges = diff(xLimits,1,2);
ax1.UserData.xRanges=xRanges;
ax1.UserData.xLimits=xLimits;
%
for iax = 1:numel(ax)
    %% add limits changed fcn to all axes
    thisax = ax(iax);
    thisax.XAxis.LimitsChangedFcn = {@syncxlim, ax(:), xLimits, xRanges};

%     %% Fix restoreview button so that it updates both axes (turns out this is unecessary)
%     warning off;axTB = axtoolbar(thisax,'default');drawnow;warning on; % gives warning error
%     isRestoreButton = strcmpi({axTB.Children.Icon},'restoreview');
%     if any(isRestoreButton)
%         restoreButtonHandle = axTB.Children(isRestoreButton);
%         originalRestoreFcn = restoreButtonHandle.ButtonPushedFcn;
%         restoreButtonHandle.ButtonPushedFcn = ...
%             {@myRestoreButtonCallbackFcn, ax, originalRestoreFcn};
%     end
end





%% label axes with xlabel
warning off;
if ~isempty(varargin)

    %% check inputs
    p = inputParser;
    p.KeepUnmatched = true;
    parse(p,varargin{:})

    params = p.Unmatched;

    if isfield(params,{'xlabel' })
        if iscell(params.xlabel)
            l1 = ['\newline\color[rgb]{0 0 0}' params.xlabel{1}];
            l2 = ['\color[rgb]{0.5 0.5 0.5}' params.xlabel{2}];
            xlab = vertcat({l1},{l2});
            xlabel(ax1,xlab);
        else
            xlabel(ax1,params.xlabel);
        end
        drawnow;
    end

end
warning on;
end
% xlim(ax1,[2 5.5])


%% function syncxlim(src, event, axs, xLimits, xRanges)
function syncxlim(src, event, ax, xLimits, xRanges)
% Responds to changes to x-axis limits in axes listed in axs.
% Updates xlims to maintain original scales.
%   axs: nx1 vector of axes handles
%   xLimits: nx2 matrix of original [min,max] xlims
%   xRanges: nx1 vector of original axis ranges
% Index of axes that just changed


axActive = src.Parent;
axIdx = ax == axActive;

% Compute the new xlims for axes that weren't just changed
normLowerLim = (event.NewLimits(1) - xLimits(axIdx,1)) / xRanges(axIdx);
newLowerLimits = normLowerLim * xRanges(~axIdx) + xLimits(~axIdx,1);
newUpperLimits = newLowerLimits + diff(event.NewLimits) .*  xRanges(~axIdx)./ xRanges(axIdx);
newXLimits = [newLowerLimits, newUpperLimits];

% Only update if the new XLimits significantly differ from current xlims
nax = sum(~axIdx);
ax2sync = ax(~axIdx);

if nax==1
    allCurrentXLims = get(ax2sync,'xlim');
else
    allCurrentXLims = cell2mat(ax2sync,'xlim');
end



%% - update limits only if sufficiently different
if any(abs(allCurrentXLims - newXLimits) > (1E-5 * xRanges(~axIdx)),'all')

    % pause LimitsChangedFcn call
    for iax = 1:numel(ax)
        thisax = ax(iax);
        thisax.XAxis.LimitsChangedFcn = '';
    end
    drawnow;%make sure XAxis is not sensitive to xlim change
    pause(0.01);
    YLIM = axActive.YLim;
    if nax==1
        set(ax2sync, 'xlim', newXLimits,'ylim',YLIM)
    else
        set(ax2sync, {'xlim'}, mat2cell(newXLimits, ones(nax,1), 2))
        set(ax2sync, {'ylim'}, mat2cell(YLIM, ones(nax,1), 2))
    end
    drawnow;
    pause(0.01); % needed to prevent reentry which triggers warning "Error updating Axes. Update failed for unknown reason."
    % unpause LimitsChangedFcn call
    for iax = 1:numel(ax)
        thisax = ax(iax);
        thisax.XAxis.LimitsChangedFcn = {@syncxlim, ax(:), xLimits, xRanges};
    end
    drawnow;
    pause(0.01); % needed to prevent reentry which triggers warning "Error updating Axes. Update failed for unknown reason."


end



end



%% function myRestoreButtonCallbackFcn
function myRestoreButtonCallbackFcn(hobj, event, ax, originalCallback)
% Responds to pressing the restore button in the ax1 toolbar. 
% originalCallback is a function handle to the original callback 
% function for this button. 
% xyscale and axBaseLim are defined elsewhere.
originalCallback(ax,event) % reset ax2
ax1 = ax(1);
xLimits = ax1.UserData.xLimits;
xRanges= ax1.UserData.xRanges;
src.Parent = ax1;
syncxlim(src, event,ax,xLimits,xRanges);
end

