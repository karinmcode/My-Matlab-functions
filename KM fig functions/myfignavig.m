function fig = myfignavig(varargin)
%%  fig = myfignavig(varargin)
%  fig = myfignavig(fig) adds keypressfcn
%  fig = myfignavig(src, evt) adds keypressfcn

if nargin==1
    fig=varargin{1};
    set(fig,'Keypressfcn',@myfignavig)
    return;
else
    fig = varargin{1};
    ev = varargin{2};

end


KEY = ev.Key;
XLIM = xlim;

% fix inf bug
if any(ismember(XLIM,Inf))
    ax = gca;
    ch = ax.Children;
    nch = numel(ch);
    Xmin = [];
    Xmax = [];
    for ich = 1:nch
        try
            XDATA = get(ch(ich),'XData');
            i4nonan = find(~isnan(XDATA),1);
            Xmin=vertcat(Xmin,XDATA(i4nonan));
            Xmax= vertcat(Xmax,XDATA(find(~isnan(XDATA),1,'last')));
        end
    end
    xlim([mymin(Xmin) mymax(Xmax)]);

end
XLIM = xlim;

% range 
dXLIM = diff(XLIM);
YLIM = ylim;
dYLIM = diff(YLIM);
switch KEY
    case 'leftarrow'
        xlim(XLIM-dXLIM/2);
    case 'rightarrow'
        xlim(XLIM+dXLIM/2);
    case 'uparrow'
        ylim(YLIM+dYLIM/2);
    case 'downarrow'
        ylim(YLIM-dYLIM/2);
    case 'i'% zoom in

        xlim(0.3*[-dXLIM dXLIM]/2+mean(XLIM));
    case 'o'% zoom out
        xlim(1.3*[-dXLIM dXLIM]/2+mean(XLIM));
    case '0'
        ax = gca;
        ch = ax.Children;
        nch = numel(ch);
        Xmin = [];
        for ich = 1:nch
            try
                XDATA = get(ch(ich),'XData');
                i4nonan = find(~isnan(XDATA),1);
                Xmin=vertcat(Xmin,XDATA(i4nonan));
            end
        end
        xlim(mymin(Xmin)+[0 dXLIM]);
    case 'a'
        xlim(gca,'auto')
    otherwise
        fprintf('\n HELP FIG NAVIGATION :')

end






end