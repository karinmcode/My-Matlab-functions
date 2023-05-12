function H=myplotstats(ax,compTable,Alpha,varargin)
% H=myplotstats(compTable,Alpha)
% compTable = nComp rows x 3 columns (col1 = x1, col2 = x2, col3 = pval)
if istable(compTable)
    compTable = table2array(compTable);
end
pval = compTable(:,3);
ncomparisons = size(compTable,1);

defaultAlphas = [0.05 0.01 0.001];
if exist("Alpha",'var')==0
    Alpha = [];
end
if isempty(Alpha)
    Alphas = defaultAlphas/ncomparisons;
elseif numel(Alpha)==1
    ncomparisons=defaultAlphas(1)/Alpha;
    Alphas = defaultAlphas/ncomparisons;
else
    Alphas = Alpha;
end
statsComps = compTable(:,1:2);
i4sig = pval<=Alphas(1);
H=sigstar(statsComps(i4sig,:) , pval(i4sig) , Alphas);

%default params
params.plotNonSig=0;
if params.plotNonSig
    for ih =1:numel(H)
        h = H(ih);
        if isa(h,'matlab.graphics.primitive.Text')%class(h)
            if isempty(h.String)
                h.String = 'n.s.';
            else

            end
        end
    end
end

% fix height of bars
YData=get(H(:,1),'ydata');
if iscell(YData)
    inonan = cellfun(@(x) ~any(isnan(x)),YData);
    YData = cell2mat(YData(inonan,:));
end

oldYLim=ax.YLim(2);
newYLim = max(YData(:));
if newYLim>oldYLim
    ax.YLim(2)=newYLim;
end




end