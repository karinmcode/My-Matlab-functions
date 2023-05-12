function     [tVID,SPEED_VID,outFO]=myGetSpeedAndTimestamps(url_vid,url_proc,DoSave)

if isvarname('DoSave')==0
DoSave =1;
end
PROCFO = 'Y:\Users\Karin\data\processed\aligned2vid\';

fn.vid = myfilename(url_vid);
fn.sbx = myfilename(url_proc);
[a , d , rec.vid] = mygce(fn.vid);
[a , d , rec.sbx] = mygce(fn.sbx);
camID = mycamID(fn.vid);
outFO = fullfile(PROCFO,a,d,rec.vid);
url_save_encoder = fullfile(PROCFO,a,d,rec.vid,sprintf('encoder_CAM%g.mat',camID));
url_save_vid = fullfile(PROCFO,a,d,rec.vid,sprintf('vid_CAM%g.mat',camID));

isSaved = myisfile(url_save_vid) && myisfile(url_save_encoder);

if ~isSaved
    mySaveAllDataAlignedToVid(url_vid,url_proc2p);
end

load(url_save_encoder,'speed');
SPEED_VID = speed.values_vid;% for number of frames in
load(url_save_vid,'video');
tVID = video.time_frames;
