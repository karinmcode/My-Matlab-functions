function fi=my_log_fit(ax,x,y,varargin)
%fi=my_log_fit(ax,x,y,varargin);
fitType = fittype('a + b*log(x)',...
    'dependent',{'y'},'independent',{'x'},...
    'coefficients',{'a','b'});
startPoints = [x(1) y(1)];
[curve, goodness, output] = fit(x(:),y(:),fitType,'Start', startPoints);
hold(ax,'on');
fi=plot(curve,'-r');
legend off;


