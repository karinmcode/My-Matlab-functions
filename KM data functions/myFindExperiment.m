function [info,a,d,exp]=myFindExperiment(url_experiment,varargin)
% info=myFindExperiment(url_experiment,varargin )
% info=myFindExperiment(url_experiment,'soundcategory','chirp' )
% to do
% add camID
% add code for more criteria 
% 

[params,param_names] = myparseinputs(varargin);

% variable
DATA_FOLDER = 'Y:\Users\Karin\data';

FO_proc = fullfile(DATA_FOLDER,'processed');
FO_proc2p = fullfile(DATA_FOLDER,'processed',"2p");

%% decide which input type was given
    [path,filename,ext] = fileparts(url_experiment);

CASE = '';
if contains(path,'2p')
    CASE = 'sbx';
end

if startsWith(filename,'proc_')
    CASE = 'sbx';
end

if startsWith(filename,'CAM')
    CASE = 'vid';
    camID = mycamID(filename);
else
    camID = 1;
end

if any(ismember(ext,{'.mp4','.avi'}))
    CASE = 'vid';
end

if contains(path,'beh')
    CASE = 'beh';
end

if isempty(CASE)
    keyboard
end

if ismember('camid',param_names)
    camID = params.camid;
end

%% extract file type independent information: animal and date
filename = replace(filename,{'proc_' 'CAM1_' 'CAM2_'},'');
c = strsplit(filename,'_');
[a,info.a]=deal(c{1});
[d, info.d] = deal(c{2});
rec = c{3};




%% Get spreadsheet of sessions
[sheet,sheet_headers]=myGetTrainingSheet();
i4a = strcmp({sheet.anmid},a);
i4d = strcmp({sheet.Date},d);
i4exp = i4a&i4d;

%% add inlcusion criteria if varargin includes them
is_header = ismember(param_names,sheet_headers);
if sum(is_header)>0
    npa = numel(param_names);
    for ipa = 1:npa
        this_param= param_names{ipa};
        if ismember(this_param,sheet_headers)
            i4 = strcmp({sheet.(this_param)},params.(this_param));
        else
            keyboard
            switch this_param
                case 'area'

            end
        end
        i4exp = i4exp&i4;

    end
end

%% find recording
switch CASE
    case 'sbx'
        i4rec = strcmp({sheet.SBX_filename},rec);
        info.exp.sbx=rec;

        i4 = i4exp&i4rec;
        n4 = sum(i4);


        if n4>1
            i4 = chooseFromOptions(sheet,i4);
        end
        info.exp.beh = sheet(i4).BEH_filename;
        info.exp.vid = sheet(i4).VID_filename;

    case 'beh'

        info.exp.beh=rec;
        i4rec = strcmp({sheet.BEH_filename},rec);
        i4 = i4exp&i4rec;
        n4 = sum(i4);

        if n4>1
            i4 = chooseFromOptions(sheet,i4);
        end
        info.exp.sbx = sheet(i4).SBX_filename;
        info.exp.vid = sheet(i4).VID_filename;


    case 'vid'

        info.exp.vid=rec;
        i4rec = strcmp({sheet.VID_filename},rec);
        i4 = i4exp&i4rec;
        n4 = sum(i4);
        if n4>1
            i4 = chooseFromOptions(sheet,i4);
        end
        info.exp.sbx = sheet(i4).SBX_filename;
        info.exp.beh = sheet(i4).BEH_filename;
    otherwise
        keyboard
end
%% Populate info structures
info.exp.plane =  {0 1};%provisory
exp = info.exp;

%% Define batch name
batch_name = '2p_211108_all_cells';%provisory
batchDate = strsplit(batch_name,'_');
batchDate = str2double(batchDate{2});

%% define folders
fo.beh = fullfile(DATA_FOLDER,'behavior',a,d);
fo.vid = fullfile(DATA_FOLDER,'videos',a,d);
fo.proc2p = fullfile(FO_proc2p,a,d);
fo.procbeh = fullfile(FO_proc,'beh',['batch_' batch_name],a,d);
fo.proc2pbatch = fullfile(FO_proc2p,['batch_' batch_name],a,d);
fo.sbx = fullfile(fullfile(DATA_FOLDER,'2p',a,d,exp.sbx));
nplanes = numel(exp.plane);
if nplanes>1
    fo.plane = cell(nplanes,1);
    for i = 1:nplanes
        fo.plane{i} = fullfile(fo.sbx,'suite2p',['plane' exp.plane{i}]);
    end
else
    fo.plane = fullfile(fo.sbx,'suite2p',['plane' exp.plane]);
end

%% define filenames without extension

if  batchDate>=200630
    fn0.beh = ['raw_' a '_' d '_' exp.beh ];
else
    fn0.beh = [ a '_' d '_' exp.beh ];
end
fn0.sbx = [ a '_' d '_' exp.sbx ];
fn0.vid = ['CAM1_' a '_' d '_' exp.vid ];
fn0.proc2p = ['proc_' a '_' d '_' exp.sbx ];
fn0.procbeh = ['proc_' a '_' d '_' exp.beh ];

%% define filenames with extension
fn.beh = [ fn0.beh '.mat'];
fn.sbx = [ a '_' d '_' exp.sbx '.mat'];
fn.vid = ['CAM1_' a '_' d '_' exp.vid '.avi'];

fn.proc2p = ['proc_' a '_' d '_' exp.sbx '.mat'];
fn.procbeh = ['proc_' a '_' d '_' exp.beh '.mat'];
fn.proc2pbatch = ['proc_' a '_' d '_' exp.sbx '.mat'];


%% define urls
url.beh = fullfile(fo.beh,fn.beh);
url.sbx = fullfile(fo.sbx,fn.sbx);
url.vid = fullfile(fo.vid,fn.vid);
url.proc2p = fullfile(fo.proc2p,fn.proc2p);
url.procbeh = fullfile(fo.procbeh,fn.procbeh);
url.proc2pbatch = fullfile(fo.proc2pbatch,fn.proc2pbatch);

url.plane = fullfile(fo.plane,'stat.npy');
url.events = fullfile(fo.proc2p,[fn0.proc2p '_events.mat']);
url.continuous = fullfile(fo.proc2p,[fn0.proc2p '_continuous.mat']);
url.cont_sound = fullfile(fo.proc2p,[fn0.proc2p '_cont_sound.mat']);
url.sync = fullfile(fo.proc2p,[fn0.proc2p '_sync.mat']);
url.fluo = fullfile(fo.proc2p,[fn0.proc2p '_fluo.mat']);
url.metadata = fullfile(fo.proc2p,[fn0.proc2p '_metadata.mat']);

%% store all info structure
info.fn0 = fn0;
info.fn = fn;
info.fo = fo;
info.url = url;

end

%% i4 = chooseFromOptions(sheet,i4)
function i4 = chooseFromOptions(sheet,i4)
Options = sheet(i4);
keyboard
listRec = strjoin([{Options.BEH_filename} {Options.VID_filename} {Options.SBX_filename} ],'  ');
idx_choice=listdlg('ListString',Options_str);
ind4 = find(i4);
idx = ind4(idx_choice);
i4 = false(size(i4));
i4(idx)=true;

end


%% check

