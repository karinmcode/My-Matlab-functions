function fig=myTestingLM(tab_input)

nrow = 2;
ncol = 5;
fig = makegoodfig('myTestingLM','slide');
AX = mysubplot([],nrow,ncol);


tab = tab_input;
obs = table2array(tab);
obs = zscore(obs,0,1);
tabZ=array2table(obs,'VariableNames',tab.Properties.VariableNames);
tab = tabZ;

for icol = 1:ncol

    % default params
    opt.ResponseVar = 'MI';
    opt.Normalize = 'zscore';
    opt.IncludeSpeed = 1;
    PredictorVars = setdiff(tab.Properties.VariableNames,{'MI' });

    irow =1;
    ax=AX(irow,icol);axes(ax);cla;



    switch icol

        case 1
            opt.ResponseVar = 'MI';
            PredictorVars = {'resp_rest' 'resp_run'};
            opt.IncludeSpeed = 0;
            TITsum = 'Control';
        case 2
            PredictorVars = setdiff(tab.Properties.VariableNames,{'MI' 'resp_rest' 'resp_run'});
            TITsum = 'Excluded resp sizes from predictors';
        case 3
            opt.IncludeSpeed = 0;
            PredictorVars = setdiff(tab.Properties.VariableNames,{'MI' });
            TITsum = 'All variables as predictors';
        case 4
            opt.IncludeSpeed = 0;
            PredictorVars = {'avg_running_speed' 'Areas' 'PeakTime', 'Types' 'Z' };
            TITsum = 'A subset variables as predictors';
        case 5
            TITsum = 'Predicting response size from avg running speed';
            opt.ResponseVar = 'resp_run';
            PredictorVars = {'avg_running_speed' 'Areas' 'PeakTime', 'Types' 'Z' };
            opt.IncludeSpeed = 1;

    end

    m = fitlm(tab ,'ResponseVar',opt.ResponseVar,'PredictorVars',PredictorVars);%,'RobustOpts','on'
    R2=m.Rsquared.Adjusted;
    C= m.Coefficients;
    Y = abs(m.Coefficients.Estimate(2:end));
    pval = m.Coefficients.pValue(2:end);

    [~,isort]=sort(Y,'descend');
    Ysort = Y(isort);
    ba=bar(Ysort);
    pval_sort = pval(isort);
    nvar = m.NumPredictors;
    R = range(Ysort);
    for iba = 1:nvar
        if pval_sort(iba)<0.005
            txt=text(iba,Ysort(iba)+0.1*R,'*','verticalalignment','top','horizontalalignment','center','fontsize',12);
        end

    end

    TIT = sprintf('%s\nResponseVar = %s \nR2 = %.2f, RMSE = %.2f',TITsum,m.ResponseName,R2,m.RMSE);


    goodax(ax,'ylabel','linear model coefficient','xlabel','predictor variables','xtick',1:nvar,'title',{TIT,'fontsize',8,'color',[1 1 1]*0.5},...
        'xticklabel',m.PredictorNames(isort),...
        'xticklabelrotation',40);

    if icol~=1
        ylabel(ax,'')
    end

    %% display params
    irow =2;
    ax=AX(irow,icol);axes(ax);cla;

    opt.ResponseVar = m.ResponseName;
    F = fieldnames(opt);

    t = get_params_string(opt,'fig');
    t = replace(t,', ','\newline');
    text(0,0,t,'color',[1 1 1]*0.4,'FontAngle','italic')
    set(ax,'ycolor','none','xcolor','none','ylim',[-1 1],'xlim',[-1 3],'Color','none')
end

linkaxes(AX(2,:),'xy')




%fig.Position(1:2) =20;
