function stats=mychi2(n,N,Alpha)
% stats=mychi2(n,N,Alpha)
% Karin's chi2 test for comparing proportions
% INPUTS:
% n = (nproportions x ngroups x ngroups2) matrix of successes
% N = (1 x ngroups) vector of total number of events/trials
% source : https://www.mathworks.com/matlabcentral/answers/96572-how-can-i-perform-a-chi-square-test-to-determine-how-statistically-different-two-proportions-are-in

%% check inputs

% check alpha
switch nargin
    case{3}
        if isempty(Alpha) == false
            if (Alpha <= 0 || Alpha >= 1)
                fprintf('Warning: Significance level error; must be 0 < alpha < 1 \n');
                return;
            end
        end
    case{2}
        Alpha = 0.05;
    otherwise
        error('Requires at least 2 input argument.');
end

% check that numbers are integers
if all(round(n)~=n)
    warning('Data n is not in integer format.');
    n = round(n);
end

if all(round(N)~=N)
    error('Data N is not in integer format.');
end


%% do test
ndim = numel(size(n));
ndim1 = size(n,1);
ndim2 = size(n,2);
if ndim<3
    ncomp = ndim2*(ndim2-1)/2;
else
    k = ndim2*ndim3;
    ncomp = k*(k-1)/2;
end
Alpha_corr = Alpha/ncomp;


colNames = cellfun(@(x) sprintf('col%g',x),num2cell(1:ndim),'UniformOutput',false);%provisory
tab=myunpackgroups(n,colNames);

if ndim==2
    [cont_tbl,chi2stat,pval,labels] = crosstab(tab.(colNames{1}),tab.(colNames{2}));
else
    [cont_tbl,chi2stat,pval,labels] = crosstab(tab.(colNames{1}),tab.(colNames{2}),tab.(colName{3}));
end
stats.test = 'chi2 test';
stats.pval = pval;
stats.ncomparisons = ncomp;
stats.Alpha = Alpha;
stats.Alpha_corr = Alpha_corr;


%% do multiple comparison posthoc test
if pval<=Alpha_corr

    pcomp = nchoosek(1:ndim2,2);% vector , number of items in combination
    comptable = nan(ncomp,3);
    comptable2 = comptable;
    for icomp = 1:ncomp
        this_comp = pcomp(icomp,:);
        n1 = n(:,this_comp(1),1)';
        n2 = n(:,this_comp(2),1)';

        % method 1 : inout number of occurences does not work for me
%         [h,p,st] = chi2gof(1:ndim1,'Ctrs',1:ndim1,...
%             'Frequency',n1, ...
%             'Expected',n2,...
%             'NParams',1);%If you specify Expected, the default value of NParams is 0.
%         comptable(icomp,:)=[this_comp p];

        % methods 2: input databasae
        i4comp = ismember(tab.(colNames{2}),this_comp);
        tab4test = tab(i4comp,:);
            [cont_tbl,chi2stat,pval,labels] = crosstab(tab4test.(colNames{1}),tab4test.(colNames{2}));
        comptable2(icomp,:)=[this_comp pval];

    end

    comptable =array2table(comptable2,"VariableNames",{'column1' 'column2' 'pval'});
    stats.comptable = comptable;
else
    pcomp = nchoosek(1:ndim2,2);% vector , number of items in combination
    comptable = nan(ncomp,3);
    comptable2 = comptable;
    for icomp = 1:ncomp
        this_comp = pcomp(icomp,:);
        n1 = n(:,this_comp(1),1)';
        n2 = n(:,this_comp(2),1)';

        % method 1 : inout number of occurences does not work for me
%         [h,p,st] = chi2gof(1:ndim1,'Ctrs',1:ndim1,...
%             'Frequency',n1, ...
%             'Expected',n2,...
%             'NParams',1);%If you specify Expected, the default value of NParams is 0.
%         comptable(icomp,:)=[this_comp p];

        % methods 2: input databasae
        i4comp = ismember(tab.(colNames{2}),this_comp);
        tab4test = tab(i4comp,:);
            [cont_tbl,chi2stat,pval,labels] = crosstab(tab4test.(colNames{1}),tab4test.(colNames{2}));
        comptable2(icomp,:)=[this_comp pval];

    end

    comptable =array2table(comptable2,"VariableNames",{'column1' 'column2' 'pval'});
    stats.comptable = comptable;

    if any(comptable.pval<=Alpha_corr)
        warning('found one comparison significantly different during multiple comparisons') 
        disp(comptable)
        disp(stats.pval)
        %keyboard
    end
    
end




