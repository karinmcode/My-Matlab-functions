function my_sync_folders(source_folder, destination_folder, display_output)
% MY_SYNC_FOLDERS Syncs two folders and their subfolders bidirectionally
%   MY_SYNC_FOLDERS(SOURCE_FOLDER, DESTINATION_FOLDER) copies files between
%   SOURCE_FOLDER and DESTINATION_FOLDER, updating any existing files with
%   newer versions and adding any new files to the other folder that don't
%   exist. Subfolders are also synced recursively.
%
%   MY_SYNC_FOLDERS(SOURCE_FOLDER, DESTINATION_FOLDER, DISPLAY_OUTPUT)
%   displays the name and size of each file that is copied between SOURCE_FOLDER
%   and DESTINATION_FOLDER if DISPLAY_OUTPUT is set to true (default is false).
%
%   Example usage:
%       my_sync_folders('C:\Folder1', 'D:\Folder2')
%
%       my_sync_folders('C:\Folder1', 'D:\Folder2', true)

% set default value for display_output
if nargin < 3
    display_output = false;
end

% create destination folder if it doesn't exist
if ~exist(destination_folder, 'dir')
    mkdir(destination_folder);
end

% start timer
tic;

%% sync files in subfolders
source_subfolders = split(genpath(source_folder),';');
source_subfolders= source_subfolders(~cellfun('isempty',source_subfolders));
destination_subfolders =  split(genpath(destination_folder),';');
destination_subfolders= destination_subfolders(~cellfun('isempty',destination_subfolders));

% src > dest
for i = 1:length(source_subfolders)
    sync_files( source_subfolders{i}, ...
        replace(source_subfolders{i},source_folder,destination_folder), ...
        display_output);
end
% dest > src
for i = 1:length(destination_subfolders)
    sync_files( destination_subfolders{i}, ...
        replace(destination_subfolders{i},destination_folder,source_folder), ...
        display_output);
end

% display time taken to sync folders
elapsed_time = toc;
disp(['Finished syncing folders in ' num2str(elapsed_time) ' seconds.']);
end

% define sync function
function sync_files(src_folder, dst_folder,display_output)
if isempty(dst_folder)
    keyboard
end
if ~exist(dst_folder, 'dir')
    mkdir(dst_folder);
end
try
    src_file_structs = dir(fullfile(src_folder, '*.*'));
    src_files = src_file_structs(~[src_file_structs.isdir]);

    dst_file_structs = dir(fullfile(dst_folder, '*.*'));
    dst_files = dst_file_structs(~[dst_file_structs.isdir]);


    % compare file names and update destination folder
    for i = 1:length(src_files)
        
        if ~any(strcmp({dst_files.name}, src_files(i).name))
            % file doesn't exist in destination folder, so copy it
            copyfile(fullfile(src_folder, src_files(i).name), dst_folder);
            if display_output
                disp(['Copied ' src_files(i).name ' (' num2str(src_files(i).bytes) ' bytes) from ' src_folder ' to ' dst_folder]);
            end

        elseif src_files(i).datenum > dst_files(strcmp({dst_files.name}, src_files(i).name)).datenum
            % file exists in destination folder, but source file is newer, so replace it
            copyfile(fullfile(src_folder, src_files(i).name), dst_folder, 'f');
            if display_output
                disp(['Updated ' src_files(i).name ' (' num2str(src_files(i).bytes) ' bytes) in ' dst_folder ' with newer version from ' src_folder]);
            end
        end
    end
catch ME
    % handle any errors that occur during the sync process
    warning(ME.message);
end
end
