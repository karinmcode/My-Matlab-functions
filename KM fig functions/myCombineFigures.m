function fig=myCombineFigures(figures)
% This function combines multiple figures into a single subplot

% If input is cell array of figure file paths, load the figures
if iscell(figures)
    nFigures = numel(figures);
    figHandles = gobjects(nFigures, 1);
    for icol = 1:nFigures
        figHandles(icol) = openfig(figures{icol});
    end
else
    % If input is array of figure objects, use them directly
    figHandles = figures;
end

% Create a new figure to copy the subplots into
fig=makegoodfig('combFig','slide');
nCols = numel(figHandles);
oldAxes=findobj(figHandles(1),'type', 'axes');
nAx= numel(oldAxes);
nRows = nAx;

cnt=0;
for irow =1:nRows

    for icol = 1:nCols
        oldAxes=findobj(figHandles(icol),'type', 'axes');
        cnt = cnt+1;
        ind = cnt;
        newAxes=subplot(nRows, nCols, ind);
        oldAx =oldAxes(irow);
        copyobj(allchild(oldAx), gca,'legacy');

        % Get the properties of the current axes
        oldProps = get(oldAx);

        % Create a new axes with the same position
        oldProps.Position = get(newAxes,'Position');
        % Copy the properties of the old axes to the new one
        try
            F = fieldnames(oldProps);
            for ifi = 1:numel(F)
                newAxes.(F{ifi})= oldProps.(F{ifi});
            end
        end

        caxis(newAxes,caxis(oldAx))

        if irow==1
            figName = figHandles(icol).Name;
             title(newAxes, figName);
        end
        % Set the title and axis labels if they exist
%         if ~isempty(oldAxes(irow).Title)
%             title(newAxes, oldAxes(irow).Title.String);
%         end
%         if ~isempty(oldAxes(irow).XLabel)
%             xlabel(newAxes, oldAxes(irow).XLabel.String);
%         end
%         if ~isempty(oldAxes(irow).YLabel)
%             ylabel(newAxes, oldAxes(irow).YLabel.String);
%         end

    end
end



end
