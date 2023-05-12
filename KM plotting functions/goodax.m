function varargout=goodax(AX,varargin)
%  goodax(ax,[varargin])
% INPUTS:
% Axes properties: xlim, ylim, 
% Axis functions
% YLabel, XLabel
% Specials:
% xticktext: inputs are cells { {xrow1;xrow2;...} , {text cell array row 1 ; text cell array row 1;... } , {xbars row1 ; xbars row2;...}}
%            x4bar = xbars{irow}(1:2,icol)
% colorbar: {'parametername',value} for example title caxis limits ylabel


% 

%check inputs
p = inputParser;
addRequired(p,'AX',@(x) isa(x,'matlab.graphics.axis.Axes'));
p.KeepUnmatched = true;
parse(p,AX,varargin{:})%p.Results
INPUTNAMES = cat(2,setdiff(p.Parameters(2:end),p.UsingDefaults),fieldnames(p.Unmatched)');
mergestructs = @(x,y) cell2struct([struct2cell(x);struct2cell(y)],[fieldnames(x);fieldnames(y)]);

params = mergestructs(p.Results,p.Unmatched);

clean = @(x) replace(x,'_',' ');

for iax = 1:numel(AX)
    ax = AX(iax);

    % by default for easier illustrator
    set(ax,'color','none','box','off','fontname','calibri');

    for iin = 1:numel(INPUTNAMES)
        INPUTNAME = INPUTNAMES{iin};
        switch INPUTNAME

            %% AXES PROPERTIES
            case 'xlim'
                xlim(ax,params.(INPUTNAME))
            case 'ylim'
                ylim(ax,params.(INPUTNAME))
            case 'xtick'
                ticks = params.(INPUTNAME);
                set(ax,'xtick',ticks);
            case {'xticklabels' 'xticklabel'}
                ticksLabels = params.(INPUTNAME);
                MULTILINE =size(ticksLabels,1)>1 && size(ticksLabels,2)~=1;
                if MULTILINE
                    multiline_xticklabels(ax,ticksLabels);
                else
                    if iscell(ticksLabels)
                        ticksLabels = cellfun(@(x) replace(x,'_',' '),ticksLabels,'UniformOutput',0);
                    end
                    set(ax,'xticklabel',ticksLabels);
                end
            case 'xtickrotation'
                set(ax,'xticklabelrotation',params.(INPUTNAME));
            case 'xticklabelrotation'
                set(ax,'xticklabelrotation',params.(INPUTNAME));
            case 'ytickrotation'
                set(ax,'ytickrotation',params.(INPUTNAME));
            case 'yticklabelrotation'
                set(ax,'yticklabelrotation',params.(INPUTNAME));
            case {'ticks' 'Ticks' 'tick' 'xytick'}

                ticks = params.(INPUTNAME);
                set(ax,'xtick',ticks,'ytick',ticks);
            case 'xycolor'
                Color =  params.(INPUTNAME);
                set(ax,'xcolor',Color,'ycolor',Color);
            case {'tickslabs' 'Tickslabs' 'ticklabs' 'xyticklabs' 'ticklab'}
                tickslabs = params.(INPUTNAME);
                set(ax,'xticklabels',tickslabs,'yticklabels',tickslabs);
            case {'TickDir'}
                set(ax,eval(sprintf('"%s"',INPUTNAME)),params.(INPUTNAME));
            case 'colormap'
                colormap(ax,params.(INPUTNAME));
            case 'hold'
                hold(ax,params.(INPUTNAME));
                %% AXIS FUNCTION
            case 'axis'
                axisInputs = params.(INPUTNAME);

                if iscell(axisInputs)
                    for axi = axisInputs
                        axis(ax,axi{1});
                    end
                else
                    axis(ax,axisInputs);
                end

                %% GRID
            case {'grid' 'grids'}
                grid(ax,params.(INPUTNAME));
                %% X/YLABEL
            case {'xlabel' }
                INPUT = params.(INPUTNAME);
                if ischar(INPUT)
                    h.xlabel=xlabel(ax,clean(INPUT));
                    continue;
                else
                     h.xlabel=xlabel(ax,clean(INPUT{1}));
                end

                n = numel(INPUT);
                INPUTSTR=INPUT;
                for i=1:n
                    try
                        INPUTSTR{i} = num2str(INPUT{i});
                    end
                end

                for i=2:2:numel(INPUTSTR)
                    thisParam = INPUTSTR{i};
                    thisParamVal = INPUT{i+1};
                    if ischar(thisParamVal)
                        eval(sprintf('set(h.xlabel,"%s","%s");',thisParam,thisParamVal));
                    else
                        try
                            eval(sprintf('set(h.xlabel,"%s",%g);',thisParam,thisParamVal));
                        catch
                            eval(sprintf('set(h.xlabel,"%s",[%s]);',thisParam,num2str(thisParamVal)));
                        end
                    end
                end


            case 'ylabel'
                INPUT = params.(INPUTNAME);
                if ischar(INPUT)
                    h.ylabel=ylabel(ax,clean(INPUT));
                    continue;
                else
                     h.ylabel=ylabel(ax,clean(INPUT{1}));
                end

                n = numel(INPUT);
                INPUTSTR=INPUT;
                for i=1:n
                    try
                        INPUTSTR{i} = num2str(INPUT{i});
                    end
                end

                for i=2:2:numel(INPUTSTR)
                    thisParam = INPUTSTR{i};
                    thisParamVal = INPUT{i+1};
                    if ischar(thisParamVal)
                        eval(sprintf('set(h.ylabel,"%s","%s");',thisParam,thisParamVal));
                    else
                        try
                            eval(sprintf('set(h.ylabel,"%s",%g);',thisParam,thisParamVal));
                        catch
                            eval(sprintf('set(h.ylabel,"%s",[%s]);',thisParam,num2str(thisParamVal)));
                        end
                    end
                end

                %% TITLE
            case 'title'
                    INPUT = params.title;
                if ischar(INPUT)
                    titstr = params.title;
                    INPUT = {};
                else
                    titstr = INPUT{1};

                end

                if iscell(titstr)
                    titstr = cellfun(@(x) replace(x,'_',' '),titstr,'UniformOutput',false);
                else
                    titstr = replace(titstr,'_',' ');
                    if contains(titstr,'\newline')
                        titstr = split(titstr,'\newline');
                    end                    
                    if contains(titstr,'\n')
                        titstr = split(titstr,'\n');
                    end
                end
                h.title=title(ax,titstr,'FontSize',12);
                n = numel(INPUT);
                INPUTSTR=INPUT;
                for i=1:n
                    try
                        INPUTSTR{i} = num2str(INPUT{i});
                    end
                end

                for i=2:2:numel(INPUTSTR)
                    thisParam = INPUTSTR{i};
                    thisParamVal = INPUT{i+1};
                    if ischar(thisParamVal)
                        eval(sprintf('set(h.title,"%s","%s");',thisParam,thisParamVal));
                    else
                        try
                            eval(sprintf('set(h.title,"%s",%g);',thisParam,thisParamVal));
                        catch
                            eval(sprintf('set(h.title,"%s",[%s]);',thisParam,num2str(thisParamVal)));
                        end
                    end
                end



                %% TEXT
            case 'text'
                x= params.text{1};
                y= params.text{2};
                txt = params.text{3};
                h.text=text(ax,x,y,txt);
                set(h.text,'color',[1 1 1]*0.5,'VerticalAlignment','top','fontangle','italic')
                isNormalAxisDir = ax.YDir(1)=='n';
                if numel(params.text)>3

                    other_inputs = params.text(4:end);
                    txt_p = inputParser();
                    txt_p.KeepUnmatched = true;
                    parse(txt_p,other_inputs{:});
                    txt_params = txt_p.Unmatched;
                    txt_params_names = fieldnames(txt_params);

                    % apply text properties
                    txt_properties = fieldnames(h.text);
                    i4builtin = false(numel(txt_params_names),1);
                    for i=1:numel(txt_params_names)
                        i4builtin(i) = any(strcmpi(txt_params_names{i},txt_properties));
                    end
                    txt_builtin_params_names = txt_params_names(i4builtin);
                    for i=1:numel(txt_builtin_params_names)
                        pa = txt_builtin_params_names{i};

                        set(h.text,eval(sprintf('"%s"',pa)),txt_params.(pa));
                    end

                    % apply custom properties
                    txt_params_names = txt_params_names(~i4builtin);
                    XLIM = xlim;
                    YLIM = ylim;
                    if isNormalAxisDir==0
                        YLIM = fliplr(YLIM);
                    end

                    if ismember('location',txt_params_names)
                        loc = txt_params.location;

                        switch loc
                            case 'N'
                                pos = [mean(XLIM) YLIM(2) 0];
                                V = 'top';
                                H = 'center';
                            case 'NE'
                                pos = [XLIM(2) YLIM(2) 0];
                                V = 'top';
                                H = 'right';
                            case 'E'
                                pos = [XLIM(2) mean(YLIM) 0];
                                V = 'center';
                                H = 'right';
                            case 'SE'
                                pos = [XLIM(2) YLIM(1) 0];
                                V = 'bottom';
                                H = 'right';
                            case 'S'
                                pos = [mean(XLIM) YLIM(1) 0];
                                V = 'bottom';
                                H = 'middle';
                            case 'SW'
                                pos = [XLIM(1) YLIM(1) 0];
                                V = 'bottom';
                                H = 'left';
                            case 'W'
                                pos = [XLIM(1) mean(YLIM) 0];
                                V = 'middle';
                                H = 'left';
                            case 'NW'
                                pos = [XLIM(1) YLIM(2) 0];
                                V = 'top';
                                H = 'left';
                        end
                        set(h.text,'Position',pos,'VerticalAlignment',V,'HorizontalAlignment',H)
                    end

                    if ismember('HorizontalAlignment',txt_params_names)
                        if strcmp(txt_params.HorizontalAlignment,'middle')
                            txt_params.HorizontalAlignment = 'center';
                        end
                        set(h.text,'HorizontalAlignment',txt_params.HorizontalAlignment)
                    end

                    if ismember('VerticalAlignment',txt_params_names)
                        if strcmp(txt_params.HorizontalAlignment,'center')
                            txt_params.HorizontalAlignment = 'middle';
                        end
                        set(h.text,'VerticalAlignment',txt_params.VerticalAlignment)
                    end

                end

            case 'xticktext'
                % X =  params.xticktext{1} (nrow = size(X,1);); xticklabels = params.xticktext{2}; input4xbars = numel(params.xticktext)==3;
                X =  params.xticktext{1};
                xticklabels = params.xticktext{2};
                input4xbars = numel(params.xticktext)==3;

                % get YLIM
                if ismember('ylim',INPUTNAMES)
                    YLIM = params.ylim;
                    ylim(ax,YLIM);
                else
                    YLIM = ax.YLim;
                end

                % get ypos of text to add according to number of rows and tightInset
                dYLIM = diff(YLIM);
                nrow = size(X,1);
                InnerPos = get(ax,'InnerPosition');
                c_figpos2datapos = dYLIM/InnerPos(4);

                % get bottom or top tight inset without xlabel
                XLAB = ax.XLabel.String;
                xlabel(ax,'')
                TightInset = get(ax,'TightInset');%ax.Units='normalized'
                xlabel(ax,XLAB);
                row_height = 0.1*dYLIM;
                NormalAxisDir = ax.YDir(1)=='n';
                if NormalAxisDir%normal
                    dBottom = TightInset(2);
                    y0 = -dBottom*c_figpos2datapos+YLIM(1);% position below x axis and negative
                    ypos = -row_height*(1:nrow)+y0;
                else%reverse
                    dBottom = TightInset(2);
                    y0 = dBottom*c_figpos2datapos+YLIM(2);
                    ypos = row_height*(1:nrow)+y0;
                end
                h.xticktext = cell(nrow,1);

                % initialise x input bars
                if input4xbars
                    xticks = ax.XTick;
                    nticks = numel(xticks);
                    h.xbar = cell(nrow,1);
                    hold(ax, "on");
                    ax.Clipping = 'off';
                    xbars = params.xticktext{3};

                end

                for irow=1:nrow
                    y = ypos(irow);
                    xpos = cell2mat(X(irow,:));
                    ncol = numel(xpos);
                    h.xticktext{irow} = gobjects(1,ncol);

                    for icol = 1:ncol
                        x = xpos(icol);
                        h.xticktext{irow}(1,icol) = text(x, y,xticklabels{irow}{icol},'horizontalalignment','center','VerticalAlignment','bottom');

                        if input4xbars
                            if numel(xbars{irow})==0
                                [~,isort]=sort([xticks,x]);
                                i4x = find(isort==(nticks+1));
                                x4bar = xticks(i4x+(-1:0));
                            else
                                x4bar = xbars{irow}(:,icol);
                            end
                            if NormalAxisDir
                                y4bar = y+0.02*dYLIM;
                            else
                                y4bar = y-0.08*dYLIM;
                            end
                            h.xbar{irow}(icol)=plot(ax,x4bar,y4bar*[1 1],'-','color',[ 1 1 1]*0.01,'LineWidth',1.5);

                        end
                    end
                end

                %% LEGEND
            case 'legend'

                h.legend=legend(params.legend{1},params.legend{2});

                if numel(params.legend)>2
                    legend_params = params.legend(3:end);
                    p_leg = inputParser;
                    p_leg.KeepUnmatched = true;
                    parse(p_leg,legend_params{:});
                    leg_params = p_leg.Unmatched;
                    leg_params_names = fieldnames(leg_params);
                    for pa=1:numel(leg_params_names)
                        pa_name=leg_params_names{pa};
                        set(h.legend,eval(sprintf('"%s"',pa_name)),leg_params.(pa_name));
                    end

                end

            case 'box'
                box(ax,params.box);
            case {'colorbar' 'cb'}

                pos=ax.Position;

                cb = colorbar(ax);
                ax.Position = pos;
                cb_p =inputParser;
                cb_p.KeepUnmatched=true;
                cb_varargin=params.(INPUTNAME);
                parse(cb_p,cb_varargin{:})%params

                cb_params = cb_p.Unmatched;
                cb_params_names = lower(fieldnames(cb_params));

                if contains('title',cb_params_names)
                    title(cb,cb_params.title);
                end

                if any(contains({'ylabel'},cb_params_names))
                    drawnow;
                    ylabel(cb,cb_params.ylabel);
                end

                if any(contains({'width'},cb_params_names))
                    cb.Position(3) = cb_params.width;
                end
                % colorbar built in properties
                list_cb_properties = lower(fieldnames(cb));
                list_cb_properties = intersect(cb_params_names,list_cb_properties);

                if ~isempty(list_cb_properties)

                    for pname=list_cb_properties(:)'
                        property_name = pname{1};
                        property_val = cb_params.(property_name);
                        set(cb,eval(sprintf('"%s"',property_name)),property_val);
                    end
                end
                if contains('limits',cb_params_names)
                    set(cb,'Limits',cb_params.limits);
                end

                set(cb,'box','off','TickDirection','out')
                if contains('caxis',cb_params_names)
                    caxis(ax,cb_params.caxis);
                end

                % if ncolors = nticklabels and no ticks values have been
                % defined, assume labels correspond to colors and shift
                % tick values
                if all(isfield(cb_params,{'ticklabels' 'colormap'}))
                    colormap(ax,cb_params.colormap)
                    ncolors = size(cb_params.colormap,1);
                    nmatch =  ncolors == numel(cb_params.ticklabels);
                    if nmatch
                        CLIM = clim(ax);% CLIM = clim(gca) cLIM=caxis
                        if all(CLIM==[0 1])
                            halfITI = 0.5/ncolors;% half intertick interval
                            tstart = halfITI;
                            tend = CLIM(2)-halfITI;
                        else
                            CLIMrange = range(CLIM);
                            halfITI = 0.5*(CLIMrange+1)/ncolors;
                            tstart = halfITI;
                            tend = CLIM(2)-halfITI;
                        end

                        cb.Ticks = linspace(tstart,tend,ncolors);
                    end
                end

                h.colorbar = cb;
                ax.Position = pos;
            case 'caxis'
                try
                    caxis(ax,params.caxis);
                catch
                    caxis(ax,[0 1]);
                end
            otherwise

                % built in ax property
                try
                    set(ax,eval(sprintf('"%s"',INPUTNAME)),params.(INPUTNAME));
                end


        end
    end
end
% assign graph objects handles to varargout
varargout = {[]};
if nargout >= 1
    if exist('h','var')
        varargout = {h};
    end
end