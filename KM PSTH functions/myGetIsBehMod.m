function isModulatedDifferentlyAcrossBeh=myGetIsBehMod(PSTHs,CellIdx)


ncond=PSTHs.ncond;
nce = numel(CellIdx);
isModulatedDifferentlyAcrossBeh  =nan(nce,1);
Alpha_corr = 0.05/(ncond-1);
for ice = 1:nce
    Y = PSTHs.values(CellIdx(ice),:);
    nper = size(PSTHs.i4post,1);
    pval_xPer= nan(nper,1);
    for iper = 1:nper
        y= cell(1,ncond-1);
        for icond = 1:ncond-1
            if isempty(Y{icond})
                y{icond} =nan;
            else
                y{icond} = mymean(Y{icond}(:,PSTHs.i4post(iper,:)),2);
            end
        end
        stats = KMStats([],1:ncond-1,y);
        pval_xPer(iper)=stats.pval;
    end

    isModulatedDifferentlyAcrossBeh(ice) = any(pval_xPer<Alpha_corr);
end