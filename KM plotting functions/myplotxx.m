function [ax1,ax2,pl]=myplotxx(ax1,x1,x2,y,varargin)
% [ax1,ax2]=myplotxx(ax1,x1,x2,y,varargin)
% [ax1,ax2]=myplotxx(ax1,x1,x2,y);
% assumes linear relation between x1 and x2
%{
%TESTING

clf;clc;clear all;close all;
makegoodfig('plotxx','slide');

x1 = 1:10;
x2 = x1*2;
y = x1*10;
ax1 = axes();
C = '-ok';
[ax1,ax2]=myplotxx(ax1,x1,x2,y,'xlabel',{'frames','time (s)'});

xlim(ax1,[2 5])

%}
if isempty(ax1)
    ax1 = axes('tag','ax1');
end



%% plotting

pl=plot(ax1,x1,y);
set(ax1,'color','none','TickDir','in','box','off');
%% move xtick labels of active ax
XAxis = ax1.XAxis;
XAxis.TickLabelGapOffset = -30;

ax2 = axes('position',ax1.Position,'color','none','box','off','tag','ax2');
pr=plot(ax2,x2,y,'s-r','color','none');
set(ax2,'YColor',pr(1).Color,'XAxisLocation','bottom','xcolor',[1 1 1]*0.5,'box','off','TickDir','out','color','none');
% turn off interactions with ax2 (the passive ax)
ax2.Interactions = []; 
ax2.Toolbar.Visible = 'off'; 

%% move xtick labels of passive ax
XAxis = ax2.XAxis;
XAxis.TickLabelGapOffset = 0;

%% compute xlim coefficients
XLIM = [min(x1,[],'omitnan') max(x1,[],'omitnan')];
XLIM2 = [min(x2,[],'omitnan') max(x2,[],'omitnan')];
dx1 = range(XLIM);
dx2 = range(XLIM2);


%% Fix restoreview button so that it updates both axes
axTB = axtoolbar(ax1,'default'); 
isRestoreButton = strcmpi({axTB.Children.Icon},'restoreview');
if any(isRestoreButton)
    restoreButtonHandle = axTB.Children(isRestoreButton);
    originalRestoreFcn = restoreButtonHandle.ButtonPushedFcn;
    restoreButtonHandle.ButtonPushedFcn = ...
        {@myRestoreButtonCallbackFcn, ax2, originalRestoreFcn};
end

%% add listeners
u.ax2sync = ax2;
u.c = dx1/dx2;
u.listener = addlistener(ax1, {'XLim'}, 'PostSet', @syncAxes);
set(ax1,'UserData',u,'tag','ax1');

u.ax2sync = ax1;
u.c = dx2/dx1;
u.listener = addlistener(ax2, {'XLim'}, 'PostSet', @syncAxes);
set(ax2,'UserData',u,'tag','ax2');

% label axes with xlabel
if ~isempty(varargin)

    %% check inputs
    p = inputParser;
    p.KeepUnmatched = true;
    parse(p,varargin{:})

    params = p.Unmatched;

    if isfield(params,{'xlabel' })
        if iscell(params.xlabel)
            l1 = ['\newline\newline\newline\color[rgb]{0 0 0}' params.xlabel{1}];
            l2 = ['\color[rgb]{0.5 0.5 0.5}' params.xlabel{2}];
            xlab = vertcat({l1},{l2});
            set(ax1,'PositionConstraint','innerposition')
            h.xlab=xlabel(ax1,xlab);
        else
            h.xlab=xlabel(ax1,params.xlabel);
        end

    end

end
end
% xlim(ax1,[2 5])


function syncAxes(prop, evData)
axModif = evData.AffectedObject;
ax2sync = axModif.UserData.ax2sync;
ax2sync.YLim = axModif.YLim;
if strcmp(prop.Name,'XLim')
    %     disp 'syncAxes';

    c= ax2sync.UserData.c;

    delete(ax2sync.UserData.listener);
    xlim(ax2sync,axModif.XLim*c);
    ax2sync.UserData.listener = addlistener(ax2sync, {'XLim'}, 'PostSet', @syncAxes);
end

function myRestoreButtonCallbackFcn(hobj, event, ax1, originalCallback)
% Responds to pressing the restore button in the ax1 toolbar. 
% originalCallback is a function handle to the original callback 
% function for this button. 
% xyscale and axBaseLim are defined elsewhere.
originalCallback(hobj,event) % reset ax2
prop.Name = 'XLim';
evData.AffectedObject = ax1;
syncAxes(prop, evData)
end

end
