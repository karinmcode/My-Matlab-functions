function u=myproc2purl(FN,varargin)

if numel(varargin)>0
    batchname = varargin{1};
    FO = fullfile('Y:\Users\Karin\data\processed\2p\' , batchname);
else
    FO = 'Y:\Users\Karin\data\processed\2p\';
end

if ~iscell(FN)
    FN = {FN};
end

nfi = numel(FN);
u = FN;
for ifi=1:nfi
    fn = FN{ifi};
    [a,d,rec]=mygce(fn);

    fo = fullfile(FO,a,d);
    u{ifi} = fullfile(fo,fn);
end

if nfi==1
    u = u{1};
end