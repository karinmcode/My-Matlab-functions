function frames=getframes(Vin,varargin)
% frames=getframes(Vin,[idx],[doExport3channels])
% Karin 20220610
NFR = Vin.NumFrames;
Period = 1/Vin.FrameRate;
t = linspace(0,Vin.Duration-Period,NFR);
ch3=0;
if isempty(varargin)
    nfr = Vin.NumFrames;
    idx = 1:nfr;
elseif numel(varargin)==2
    idx = varargin{1};
    nfr = numel(idx);
    ch3=varargin{2};
else
    idx = varargin{1};
    nfr = numel(idx);
end

IS_CONSETIVE = all(diff(idx)==1);
if ch3==0
frames = nan(Vin.Height,Vin.Width,nfr);
else
frames = nan(Vin.Height,Vin.Width,3,nfr);
end
if IS_CONSETIVE
    Vin.CurrentTime = max([0 t(idx(1))-Period/2]);%check KM

    for ifr=1:nfr
        thisFrame = readFrame(Vin);
        thisFrame = mat2gray(thisFrame);
        if ch3
            frames(:,:,:,ifr) = thisFrame;
        else
            frames(:,:,ifr) = thisFrame(:,:,1);
        end
    end

else
    for ifr=1:nfr
        Vin.CurrentTime = t(idx(ifr));
        thisFrame = readFrame(Vin);
        if ch3
            frames(:,:,:,ifr) = thisFrame;
        else
            frames(:,:,ifr) = thisFrame(:,:,1);
        end
    end

end




end