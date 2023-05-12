function SAVE_FIGS_AS_FIGNAME(FO,figs)
% SAVE_FIGS_AS_FIGNAME(FO,figs)

fprintf('\n saving figures ...')

if isfolder(FO)==0
    mkdir(FO);
end
nfig = numel(figs);

for ifig = 1:nfig
    fig = figs(ifig);
    try
        figName = fig.Name;
        figName=replace(figName,'/','_');
        fn.fig = sprintf('%s.png',figName);
        url.fig = fullfile(FO,fn.fig);
        sz=fprintf( '\n*%s*',fn.fig);
        saveas(fig,url.fig)
    catch err
        rethrow(err);
        disp('no fig save')
    end
    %fprintf(repmat('\b',1,sz))
end
fprintf('\n saved all figs')