function s = mydispcell(c)
% MYDISPCELL displays the content of a cell array of strings as a string shaped as a table
% padded in each column.

if ~iscellstr(c)
    error('Input must be a cell array of strings.');
end

% Get the size of the cell array
[nRows, nCols] = size(c);

% Find the maximum length of strings in each column of the cell array
maxLens = max(cellfun('length', c), [], 1);

% Create a format specifier for each column
fmts = cellfun(@(x) ['%', num2str(x), 's'], num2cell(maxLens), 'UniformOutput', false);

% Combine format specifiers into a single format string
fmt = [strjoin(fmts, ' '), '\n'];

% Initialize the output string
s = '';

% Loop through each row in the cell array
for i = 1:nRows
    % Get the current row
    row = c(i, :);
    
    % Append the formatted row to the output string
    s = [s, sprintf(fmt, row{:})]; %#ok<AGROW>
end

% Remove the trailing newline character
s = s(1:end-1);



end
