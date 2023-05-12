function V=myviolin(AX,y,Categories,pCategories,CM,pLabels,relevantComp)
% V=myviolin(AX,y,Categories,pCategories,CM,pLabels,relevantComp)

% remove nans
inan=isnan(y);
y(inan) =[];
Categories(inan) =[];

if isempty(pCategories)
    
    if ~iscell(Categories) || isempty(pCategories)
        pCategories_num = unique(Categories,'rows');
        ncol = size(Categories,2);
        ncat = size(pCategories_num,1);
        pCategories = cell(1,ncat);
        for icat = 1:ncat
            
            for icol = 1:ncol
                if icol ==1
                    catstr=num2str(pCategories_num(icat,icol));
                else
                    catstr=[catstr ' ' num2str(pCategories_num(icat,icol))];
                end
            end
            pCategories{icat} = catstr;
        end
        
    else
        pCategories = unique(Categories);
    end
end

ncat = numel(pCategories);
x =1:ncat;
nobs = numel(y);
if ~iscell(Categories)
    Categories_num = Categories;
    ncol = size(Categories,2);
    CCategories = cell(nobs,1);
    for iobs = 1:nobs
        for icol = 1:ncol
            if icol ==1
                catstr=num2str(Categories_num(iobs,icol));
            else
                catstr=[catstr ' ' num2str(Categories_num(iobs,icol))];
            end
        end
        CCategories{iobs}=catstr;
    end
    
else
    CCategories = Categories;
end

% plot violing

V=violinplot(y,CCategories(:),'GroupOrder',pCategories(:)');
% fix colors
if isempty(CM)
    CM = jet(ncat)*0.9;
end
for icat = 1:ncat
    i4cat = strcmp(pCategories,pCategories{icat});
    [V(i4cat).ViolinColor]=deal(CM(icat,:));
end

[V(:).EdgeColor]=deal([1 1 1]*0.1);
[V(:).MedianColor]=deal([1 1 1]*1);
[V(:).BoxColor]=deal([1 1 1]*0.12);
[V(:).BoxWidth]=deal(0.04);

% plot line
yplot = nan(ncat,1);
for i=1:ncat
    yplot(i)=V(i).MedianPlot.YData;
end
plot(x,yplot,'k-')

xlim(AX,[-0.5 +0.5]+[1 ncat])
doStats(AX,x,y,CCategories,pCategories,relevantComp)

% fix xtick labels
if ~isempty(pLabels)
    % multiline xticklabel
    ncol = numel(strsplit(pLabels{1},' '));
    notAC = cellfun(@(x) contains(x,'notAC'),pLabels);
    if any(notAC)
        ncol = ncol+1;
        pLabels=cellfun(@(x) replace(x,'notAC','not AC'),pLabels,'uniformoutput',0);
    end
    labelArray = cell(ncol,ncat);
    for ilab=1:ncat
        spl=strsplit(pLabels{ilab},' ');
        for icol = 1:ncol
            try
                labelArray{icol,ilab} =spl{icol};
            catch
                labelArray{icol,ilab} =' ';
            end
        end
    end
    labelArray = strjust(pad(labelArray),'center');
    tickLabels = sprintf([repmat('%s\\newline',1,ncol-1) '%s\n'], labelArray{:});
    
    set(AX,'xticklabel',tickLabels);
    
end
end

