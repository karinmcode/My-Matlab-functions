function mysaveas(figureHandles, filePaths, varargin)
    % mysaveas: Save figure(s) as specified file format
    %
    % Usage:
    %   mysaveas(figureHandles, filePaths)
    %   mysaveas(figureHandles, filePaths, 'Param1', Value1, 'Param2', Value2, ...)
    %
    % Inputs:
    %   - figureHandles: Figure handle(s) to be saved. Can be a single figure handle or an array of figure handles.
    %   - filePaths: Full file path(s) including the file name and extension, or a folder path(s).
    %                If filePaths is a folder path, the figures will be saved in that folder using the figure names.
    %                If filePaths is a single file path, the figures will be saved with that file name, and an additional suffix
    %                "figNumber_NbOfFigures" will be added to the file name if multiple figures are provided.
    %
    % Optional Parameters:
    %   - 'FontName': Specify the font name for the figure (default: 'Calibri').
    %   - 'FontSize': Specify the font size for the figure (default: 8).
    %   - 'OutputUnit': Specify the output unit for the figure (default: 'points').
    %   - 'OutputPosition': Specify the output position for the figure (default: [0 0 200 400]).
    %
    % Example:
    %   % Save a single figure as a PDF with default options
    %   mysaveas(figureHandles, 'output.pdf');
    %
    %   % Save multiple figures as PDFs in a folder with custom options
    %   mysaveas(figureHandles, 'output.pdf','OutputPosition',[0 0 300 300] , 'FontName', 'Calibri');

    % Validate and process export options
    exportOptions = parseInputs(varargin{:});
    
    if ~iscell(filePaths)
        filePaths = {filePaths};
    end
    % Check if figureHandles is an array of figure handles
    for i = 1:numel(figureHandles)
        % Determine the figure path based on the size of filePaths
        if numel(filePaths) > 1
            % Multiple file paths provided
            [folderPath, fileName, ext] = fileparts(filePaths{i});
            fileNameSuffix = sprintf('_%d_%d', i, numel(figureHandles));
            figurePath = fullfile(folderPath, [fileName, fileNameSuffix, ext]);
        else
            % Single file path provided
            if isfolder(filePaths{i})
                % Save the figure in the specified folder using the figure name
                [~, fileName, ext] = fileparts(get(figureHandles(i), 'Name'));
                figurePath = fullfile(filePaths{i}, [fileName, ext]);
            else
                % Save the figure with the specified file name
                figurePath = filePaths{i};
            end
        end
        
        % Save the current figure with the specified options
        saveSingleFigure(figureHandles(i), figurePath, exportOptions);
    end
end

%% function saveSingleFigure(figHandle, fileURL, params)
function saveSingleFigure(figHandle, fileURL, params)
% Export figure based on file extension

 prepFig4Illustrator(figHandle,params)

[figFolder, ~, ext] = fileparts(fileURL);

mymkdir(figFolder);

switch ext
    case '.emf'
        % Export as EMF with specified options
        exportgraphics(figHandle, fileURL, 'Resolution', 150, 'BackgroundColor', 'none', 'Colorspace','rgb', 'ContentType', 'vector');
    case '.pdf'
        % Export as PDF with specified options
        exportgraphics(figHandle, fileURL, 'BackgroundColor', 'none',  'ContentType', 'vector');
    otherwise
        % Export using saveas function
        saveas(figHandle, fileURL);
end
end

%% function params = parseInputs(varargin)
function params = parseInputs(varargin)
    % Parse and validate input parameters
    
    
    % Create input parser
    parser = inputParser;
    parser.CaseSensitive = false;
    
    % Define optional parameters and their validation rules
    addParameter(parser, 'FontName', 'Calibri');
    addParameter(parser, 'FontSize', 8);
    addParameter(parser, 'OutputUnit', 'points');
    addParameter(parser, 'OutputPosition', [0 0 200 400]);
    letterSize = [792   612];
    addParameter(parser, 'PaperSize', letterSize);
    addParameter(parser, 'ExportFormat', {'.pdf'});
    % Parse the input parameters
    parse(parser, varargin{:});
    
    % Get the parameter values
    params = parser.Results;
end

%% function prepFig4Illustrator
function prepFig4Illustrator(fig, params)

    % Set all fontsizes to params.fontsize
    set(findall(fig, 'Type', 'text'), 'FontSize', params.FontSize);
    
    % Remove all white backgrounds from figures and axes
    set(fig, 'Color', 'none');
    allAxes = findall(fig, 'Type', 'axes');
    set(allAxes, 'Color', 'none');
    
    % Make tick direction 'both'
    for iax = 1:numel(allAxes)
        ax = allAxes(iax);
        set(ax,'TickDir','both')
    end

    % Set size to output size using outputPosition
    set(fig, 'Units', params.OutputUnit);
    set(fig, 'Position', params.OutputPosition);
    drawnow;
end
