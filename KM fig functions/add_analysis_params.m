function ann = add_analysis_params(f,Opt)
% ann = add_analysis_params(f,Opt);

figure(f);
dim = [0.001 0.9 1 0.1];
ann = annotation('textbox',dim,'String','');

set(ann,'position',dim,'fontsize',12,'horizontalalignment','left', ...
    'verticalalignment','top','LineStyle','none','FontName','arial','FontWeight','normal','fontangle','italic', ...
    'color',[1 1 1]*0.5)

ann.String = get_params_string(Opt,'fig');

