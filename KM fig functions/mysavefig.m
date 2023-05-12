function urls = mysavefig(figs, datafolder, exts)
% Save figures with specified extensions and output URLs of saved figures
% If exts contains 'pdf', vectorize figures for Illustrator
% Change fonts of all figures to Calibri

% Create the output directory if it does not exist
if ~exist(datafolder, 'dir')
    mkdir(datafolder)
end

% Initialize the URLs cell array
urls = cell(size(figs));

% Loop over the figures
for i = 1:numel(figs)
    % Get the current figure handle
    fig = figs(i);
    
    % Get the figure name and remove the extension
    name=fig.Name;
    
    % Change fonts to Calibri
    set(findall(fig, '-property', 'FontName'), 'FontName', 'Calibri')
    
    % Loop over the extensions
    for j = 1:numel(exts)
        % Construct the file name with the current extension
        filename = fullfile(datafolder, [name,  exts{j}]);
        
        % Save the figure with the current extension
        switch exts{j}
            case 'pdf'
                % Use '-bestfit' option to ensure compatibility with Mac
                % Use '-r300' option to ensure compatibility with PC
                if ispc
                    print(fig, '-dpdf', '-painters', '-r300', filename)
                else
                    print(fig, '-dpdf', '-painters', '-bestfit', filename)
                end
            otherwise
                saveas(fig, filename)
        end
        
        % Store the URL of the saved figure
        urls{i, j} = filename;
    end
end
