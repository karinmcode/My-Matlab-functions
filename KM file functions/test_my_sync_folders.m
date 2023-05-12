clc


% Create example folders and files for testing my_sync_folders
src_folder = 'G:\My Drive\code\F1';
dst_folder = 'G:\My Drive\code\F2';
try
rmdir(src_folder);
rmdir(dst_folder);
end

% Create source_folder and destination_folder
if ~exist(src_folder, 'dir')
    mkdir(src_folder);
end
if ~exist(dst_folder, 'dir')
    mkdir(dst_folder);
end

% Create files in source_folder
fid = fopen(fullfile(src_folder, 'file1.txt'), 'w');
fprintf(fid, 'This is file1 in source_folder.\n');
fclose(fid);

fid = fopen(fullfile(src_folder, 'file2.txt'), 'w');
fprintf(fid, 'This is file2 in source_folder.\n');
fclose(fid);

% Create a subfolder in source_folder
subfolder_src = fullfile(src_folder, 'subfolder1');
if ~exist(subfolder_src, 'dir')
    mkdir(subfolder_src);
end

% Create files in subfolder1 of source_folder
fid = fopen(fullfile(subfolder_src, 'file3.txt'), 'w');
fprintf(fid, 'This is file3 in subfolder1 of source_folder.\n');
fclose(fid);

fid = fopen(fullfile(subfolder_src, 'file4.txt'), 'w');
fprintf(fid, 'This is file4 in subfolder1 of source_folder.\n');
fclose(fid);

%% Create files in destination_folder
fid = fopen(fullfile(dst_folder, 'file1.txt'), 'w');
fprintf(fid, 'This is an older version of file1 in destination_folder.\n');
fclose(fid);

fid = fopen(fullfile(dst_folder, 'file5.txt'), 'w');
fprintf(fid, 'This is file5 in destination_folder.\n');
fclose(fid);

% Create a subfolder in destination_folder
subfolder_dst = fullfile(dst_folder, 'subfolder2');
if ~exist(subfolder_dst, 'dir')
    mkdir(subfolder_dst);
end

% Create files in subfolder2 of destination_folder
fid = fopen(fullfile(subfolder_dst, 'file6.txt'), 'w');
fprintf(fid, 'This is file6 in subfolder2 of destination_folder.\n');
fclose(fid);

fid = fopen(fullfile(subfolder_dst, 'file7.txt'), 'w');
fprintf(fid, 'This is file7 in subfolder2 of destination_folder.\n');
fclose(fid);

%% Test my_sync_folders with the created folders
my_sync_folders(src_folder, dst_folder, true);




%% 
src_folder = 'G:\My Drive\code\My MATLAB functions';
dst_folder = 'G:\My Drive\code\GUIs\bentoMAT-master\bento\util\My MATLAB functions';
my_sync_folders(src_folder, dst_folder, true);
