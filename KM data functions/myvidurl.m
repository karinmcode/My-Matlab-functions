function u=myvidurl(FN)
FO = 'Y:\Users\Karin\data\videos';

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