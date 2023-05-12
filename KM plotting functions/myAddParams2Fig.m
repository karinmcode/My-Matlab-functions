function ann=myAddParams2Fig(f,Opt)
%  ann=myAddParams2Fig(f,Opt)

figure(f);
dim = [0.001 0.9 1 0.1];
ann = annotation('textbox',dim,'String','');

set(ann,'position',dim,'fontsize',12,'horizontalalignment','left', ...
    'verticalalignment','top','LineStyle','none','FontName','arial','FontWeight','normal','fontangle','italic', ...
    'color',[1 1 1]*0.5)

ann.String = my_get_params_string(Opt,'fig');
