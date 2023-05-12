function     outFO=mySaveAllDataAlignedToVid(url_vid,url_proc,DoSave)
%% mySaveAllDataAlignedToVid
% url_vid = 'Y:\Users\Karin\data\videos\m523\211118\CAM1_m523_211118_003.avi'
% url_proc = 'Y:\Users\Karin\data\processed\2p\m523\211118\proc_m523_211118_003_continuous.mat'
% outFO=mySaveAllDataAlignedToVid(url_vid,url_proc)

% url_vid = 'Y:\Users\Karin\data\videos\m522\211118\CAM1_m523_211118_003.avi'
% url_proc = 'Y:\Users\Karin\data\processed\2p\m523\211118\proc_m523_211118_003_continuous.mat'
% outFO=mySaveAllDataAlignedToVid(url_vid,url_proc)


if isvarname('DoSave')==0
DoSave =1;
end

%% define folder variables
PROCFO = 'Y:\Users\Karin\data\processed\aligned2vid\';

url_proc = replace(url_proc,'_continuous','');%mywinopen(url_fluo)


%% define experiment variables
fn.vid = myfilename(url_vid);
fn.sbx = myfilename(url_proc);
[a , d , rec.vid] = mygce(fn.vid);
[a , d , rec.sbx] = mygce(fn.sbx);
camID = mycamID(fn.vid);
outFO = fullfile(PROCFO,a,d,rec.vid);

specialList = {'CAM1_m523_211110_002'};
if ismember(fn.vid,specialList)
thiscmd=sprintf('outFO=mySaveAllDataAlignedToVid_%s(url_vid,url_proc,DoSave)',fn.vid);
eval(thiscmd);
return;

end

%% define output files
url_save_encoder = fullfile(outFO,sprintf('encoder_CAM%g.mat',camID));
url_save_vid = fullfile(outFO,sprintf('vid_CAM%g.mat',camID));
url_save_fluo = fullfile(outFO,sprintf('fluo_CAM%g.mat',camID));
url_save_events = fullfile(outFO,sprintf('events_CAM%g.mat',camID));

url_list = {url_save_encoder url_save_vid url_save_fluo url_save_events};

isSaved = all(myisfile(url_list));
isSaved = 0;
if isSaved
    disp isSaved
    return;

else% make data

    %% CONTINUOUS

    disp(['Loading continuous data for ... ' fn.vid])
    url_continuous = replace(url_proc,'.mat','_continuous.mat');
    if myisfile(url_continuous)
        load(url_continuous,'continuous');
    else
        load(url_proc,'continuous');
    end

    if ~exist('continuous','var')
        outFO = '';
        return;
        mywinopen(fileparts(url_proc));
        keyboard
    end
    thisCam = continuous.cam(camID);
    i4filename = strncmp(thisCam.filename,fn.vid,numel(fn.vid));% unique(thisCam.filename)figure;plot(thisCam.tbeg(i4filename))
    time_beh = continuous.cam(camID).time(i4filename);%time_beh(1), figure;plot( continuous.cam(camID).tbeg);unique(continuous.cam(camID).tbeg)
    fs =1/mymean(diff(time_beh));
 

    % VIDEO 
    
    if ~myisfile(url_vid)
        url_vid = replace(url_vid,'.avi','.mp4');
    end
    if myisfile(url_vid)
        Reader = VideoReader(url_vid);
    else
        mywinopen(url_vid);
        keyboard
    end
    NFR_vid = Reader.NumFrames;

    video.time_beh= time_beh;
    NFR_beh = numel(time_beh);

    % time_frames: corrected for different length
    if NFR_vid~=NFR_beh
        disp('different numbers of frames');
        dNFR = NFR_vid-NFR_beh;
        fprintf('\ndNFR = %g \nNFR_vid = %g \nNFR_beh = %g', dNFR,NFR_vid,NFR_beh);
        if dNFR>5
            %winopen(url)
            if ~ismember(myfilename(Reader.Name),'CAM2_m523_211118_003')
            keyboard
            end
        end

        if NFR_vid<NFR_beh
            time_frames = time_beh(1:NFR_vid);
        else
            time_frames = time_beh(1:NFR_beh);
        end
    else
        time_frames = time_beh;
    end
    NFR = numel(time_frames);
    % time_proc: remove frames where speed is nan

    speed.time = continuous.encoder.time;
    speed.values = continuous.encoder.speed_ms;
    SPEED_vid = interp1(speed.time,speed.values,time_frames,'linear');

    ifr1 = find(diff(isnan(SPEED_vid))==-1,1);
    if isempty(ifr1)
        ifr1 =1;
    end
    if find(isnan(SPEED_vid),1,'last')~=ifr1
        ifr_end = min([find(isnan(SPEED_vid),1,'last') NFR-1]);
    else
        ifr_end = NFR-1;
    end
    frame_vec = ifr1:ifr_end;
    time_proc = time_frames(frame_vec);

    % store variables in video
    video.time_frames= time_frames;% remove additional frames at the end of recording
    video.time_proc= time_proc;% removed frame with no speed values
    video.url = url_vid;
    video.filename = myfilename(url_vid);
    video.camID = mycamID(video.filename);
    video.frame_rate = fs;
    video.num_frames = NFR_vid;
    video.num_frames_proc = numel(time_proc);

    mymkdir(url_save_vid);
    save(url_save_vid,'video');

    % SPEED

    speed.unit = 'm/s';
    speed.time_vid = video.time_frames;
    speed.values_vid = SPEED_vid;
    speed.time_vidproc = video.time_proc;
    speed.values_vidproc = interp1(speed.time,speed.values,video.time_proc,'linear');

    % POSITION
    wheelDiam_m = 0.08;% approx 25cm
    wheelPerimeter_m = 2*pi*wheelDiam_m/2;

    DIST_m = continuous.encoder.distance_m;
    foo = (DIST_m-DIST_m(1))/wheelPerimeter_m;
    POS = (foo-floor(foo))*360;
    position.time = continuous.encoder.time;
    position.values = POS;
    position.unit = 'degrees, 1 revolution = 360°';
    position.time_vid = video.time_frames;
    position.values_vid = interp1(position.time,position.values,video.time_frames,'linear');% figure;plot(tSPEED,POS,'-k',tVID,position.values_vid,'-r')
    position.time_vidproc = video.time_proc;
    position.values_vidproc = interp1(position.time,position.values,video.time_proc,'linear');
    position.wheelDiam_m = wheelDiam_m;
    position.wheelPerimeter_m = wheelPerimeter_m;

    save(url_save_encoder,'speed','position');

    %% FLUO
    disp(['Loading fluo data for ... ' fn.vid])

%     % first get the sound responsive cells
%     url_isresp_soma = replace(url_proc,'_continuous','_ISRESP_SOMA');
%     if ~myisfile(url_isresp_soma)
%         fn.isresp_soma = myfilename(url_isresp_soma);
%         fn.proc = replace(fn.isresp_soma,'_ISRESP_SOMA','');
%         filename_suggestion = sprintf('%s*_ISRESP_SOMA.mat',  fn.proc(1:find(fn.proc=='_',1,'last')));
%         files = dir(fullfile(fileparts(url_isresp_soma),filename_suggestion));
%         if numel(files)==1
%             url_isresp_soma=fullfile(files.folder,files.name);
%         else
%             disp(files)
%             keyboard;
%         end
%     end
%     load(url_isresp_soma,'IDs','ISCELL')
%     IDs = IDs(ISCELL==1,:);
%     IDs(:,3) = str2num(rec.sbx);
    % then get them in _fluo


    url_fluo = replace(url_proc,'.mat','_fluo.mat');%mywinopen(url_fluo)
    url_fluo_resp_cells =  replace(url_proc,'.mat','_resp_cells.mat');
    url_fluo_batch = replace(url_fluo_resp_cells,'2p',['2p' filesep 'batch_2p_211108_all_cells']);

   URLs_fluo = { url_fluo url_fluo_resp_cells url_fluo_batch};
   varnames_fluo = {'fluo' 'FLUO'};
   for iu = 1:numel(URLs_fluo)
       if myisfile(URLs_fluo{iu})
           varlist=whos('-file',URLs_fluo{iu});
           CONTAINS_FLUO = ismember(varnames_fluo,{varlist.name});
           if any(CONTAINS_FLUO)
               url_fluo = URLs_fluo{iu};
               varname_fluo  = varnames_fluo{CONTAINS_FLUO};
               break;
           end
       end
   end



    if myisfile(url_fluo)%mywinopen(fileparts(url_fluo))
        load(url_fluo,'fluo', 'FLUO');
        if ~exist('fluo','var') && exist('FLUO','var')
            fluo = FLUO;

                fluo.id_uni = fluo.id;
                disp(['Found FLUO instead of fluo in ' myfilename(url_fluo)])
            
        else
            warning('2p file needs to be processed')
        end


        if 0% select cells to save
            i4ce = ismember(fluo.id_uni,IDs,"rows");
            fluo.values = fluo.data.norm(i4ce,:);
        else
            fluo.values = fluo.data.norm;
        end
        fluo = rmfield(fluo,'data');
        
        i4camfile = fluo.time>=video.time_proc(1) &   fluo.time<=video.time_proc(end);%plot(i4camfile)
        fluo.time_vid = fluo.time(i4camfile);
        fluo.values_vid = fluo.values(:,i4camfile);
        fluo.fs_common = 15;
        period = 1/fluo.fs_common;
        fluo.time_common = fluo.time_vid(1):period:fluo.time_vid(end);
        fluo.values_common = interp1(fluo.time_vid,fluo.values_vid',fluo.time_common,'linear')';%figure;plot(fluo.time_common,fluo.values_common(1,:))
        fluo.src_proc_url = url_proc;
        fluo = rmfield(fluo,{'time' 'values'});

        save(url_save_fluo,'-v7.3','fluo');
    else
        warning('did not find fluo file')
        mywinopen(fileparts(url_fluo))
    end


    %% EVENTS
    url_events = replace(url_proc,'.mat','_events.mat');
    if ~myisfile(url_events)%mywinopen(fileparts(url_fluo))
        url_events = url_proc;%mywinopen(url_fluo)
    end    


    if myisfile(url_events)

        load(url_events,'events');
        pev = fieldnames(events);
        nev = numel(pev);
        for iev = 1:nev
            this_ev = pev{iev};
            t = events.(this_ev).time;
            % select events occuring during the video myminmax(t)
            i4camfile = t>=video.time_proc(1) &   t<=video.time_proc(end);%plot(i4camfile)
            n4camfile = sum(i4camfile);
            if n4camfile==0
                keyboard
            end
            pfi = fieldnames(events.(this_ev));
            nfi = numel(pfi);
            for ifi = 1:nfi
                this_fi = pfi{ifi};
                try
                    events.(this_ev).(this_fi) = events.(this_ev).(this_fi)(i4camfile);
                end
            end
            events.(this_ev).cnt = sum(i4camfile);
            events.(this_ev).time_proc_vid = events.(this_ev).time-video.time_proc(1);
        end

        save(url_save_events,'events','-v7.3');
    else
        warning('did not find events')
    end

    %% PSTHs



end