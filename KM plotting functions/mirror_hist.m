function [H,stats] = mirror_hist(X,DataInput,ybins,varargin)
%  H = mirror_hist(X,DataStruct,varargin)
% DataStruct labels refer to variables on X axis
% each structure field contains 2 data sets to be compared

[params,param_names]=myparseinputs(varargin);

if ~ismember('dostats',param_names)
params.dostats=true;
end
dX = min(diff(X));
if isempty(dX)
    dX = 1;
end
dX2 = dX/2;
widthDensity = dX2*3;
args.BoxWidth = 0.08*dX2;
args.MarkerSize = 20;
hOff = 0.11*dX2;
Signs = [-1 1];
stats = struct();
if isstruct(DataInput)
    D = DataInput;
    varnames = fieldnames(D);
elseif iscell(DataInput)
    varnames = params.varnames;
    D = struct();
    for ivar = 1:numel(varnames)
        D.(varnames{ivar}) = DataInput(ivar,:);
    end

end
nvar = numel(varnames);
nbins = numel(ybins)-1;
dy = diff(ybins(1:2));
ybins_centers = ybins(1:end-1)+dy;
ncenters = numel(ybins_centers);
cond_colors = [0 0 1; 1 0 0];
% prep data
for ivar = 1:nvar
    varname = varnames{ivar};
    for icond = 1:2
        data = D.(varname){icond};
        %histData.(varname)(1:nbins,icond) = histcounts(data,ybins,'normalization','probability');

        value = ybins_centers;
        density = histcounts(data,ybins,'normalization','pdf');
        density = 2*density/nbins;

        %             [density, value] = ksdensity(data,ybins);
%         i4keep = value >= min(data) & value <= max(data);
%         density = density(i4keep);
%         value = value(i4keep);
%         value(1) = min(data);
%         value(end) = max(data);
        value = [value(1)*(1-1E-5), value, value(end)*(1+1E-5)];
        density = [0, density, 0];%sum(density)==1 ? 

            % all data is identical
            if min(data) == max(data)
                density = 1;
                value = mymean(data);
            end


        densData.(varname){icond} = [density; value];
    end
end

% plotting

for ivar = 1:nvar
    varname = varnames{ivar};
    pos =X(ivar);

    for icond = 1:2
        Sign = Signs(icond);
        this_hOff = hOff*Sign;

        data = D.(varname){icond};

        % probability distribution patch
        densityC = densData.(varname){icond}(1,:);
        densityC = widthDensity*densityC;
        if all(densityC)<0.3
            densityC = 1.5*densityC;
        end

        valueC   = densData.(varname){icond}(2,:);

        co = cond_colors(icond,:);
        if icond==1% left
            h =  ...
                fill([pos-densityC(end) pos-densityC(end:-1:1)], ...
                [valueC(end) valueC(end:-1:1)], co);
            hold on;
        else
            h =  ...
                fill([pos+densityC pos-densityC(1)], ...
                [valueC valueC(1)], co);
        end

        H.ViolinPlot{icond}=h;
        set(h,'linestyle','none','facealpha',0.5);

        %% plot the mini-boxplot within the violin
        quartiles = quantile(data, [0.25, 0.5, 0.75]);
        if icond ==1
            H.BoxPlot{icond} = ... % plot color will be overwritten later
                fill(pos+this_hOff+[-1,1,1,-1]*args.BoxWidth, ...
                [quartiles(1) quartiles(1) quartiles(3) quartiles(3)], ...
                [0 0 0]);
        else
            H.BoxPlot{icond} = ... % plot color will be overwritten later
                fill(pos+this_hOff+[-1,1,1,-1]*args.BoxWidth, ...
                [quartiles(1) quartiles(1) quartiles(3) quartiles(3)], ...
                [0 0 0]);
        end

        %% plot the data mean
        meanValue = mymean(data);
        H.MeanPlot{icond} = plot(pos+args.BoxWidth*[-1,1]+this_hOff, ...
            [meanValue, meanValue],'linewidth',1,'Color',[1 1 1]);


        %% plot the median, notch, and whiskers
        IQR = quartiles(3) - quartiles(1);
        lowhisker = quartiles(1) - 1.5*IQR;
        lowhisker = max(lowhisker, min(data(data > lowhisker)));
        hiwhisker = quartiles(3) + 1.5*IQR;
        hiwhisker = min(hiwhisker, max(data(data < hiwhisker)));
        if ~isempty(lowhisker) && ~isempty(hiwhisker)
            H.WhiskerPlot{icond} = plot([pos pos]+this_hOff, [lowhisker hiwhisker],'color','k');
        end

        H.MedianPlot{icond} = scatter(pos+this_hOff, quartiles(2), args.MarkerSize, [1 1 1], 'filled','MarkerEdgeColor','k');

    end



end

goodax(gca,'xtick',X,'xticklabel',replace(varnames,'_',' '));
% do stats


if params.dostats
for ivar = 1:nvar

    varname = varnames{ivar};
    pos =X(ivar);
    Xpos = [pos pos]+[-this_hOff this_hOff];
    stats=KMStats(gca,Xpos,D.(varname),'plotNonSig',true);
end
end