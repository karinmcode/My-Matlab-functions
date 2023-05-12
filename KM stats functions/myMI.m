function MI=myMI(R0,R1,varargin)
%% MI=myMI(R0,R1,varargin)
% R0 and R1 can be double, column vector


%% If input is single number or column vector
if isempty(R0)
    xy = 0:40;
    [R0,R1] = meshgrid(xy,xy);
    
    MI = (R1-R0)./(R0+R1);
    angMI = myAngMI(R0,R1);

    f=makegoodfig('myMI');
    for iax = 1:2
        ax(iax)=subplot(1,2,iax);
        if iax==1
            imagesc(xy,xy,MI);
            title('MI')
        else
            imagesc(xy,xy,angMI);
            title('angMI')
        end
        cb(iax)= colorbar();
        axis square;
    end
    set(ax,'ydir','normal','colormap',jet(100))
    set(cb,'limits',[-1 1])


else
    R0(R0<=-2)=nan;% remove negative responses for computing MI
    R0(R0<0)=0;
    R1(R1<=-2)=nan;% remove negative responses for computing MI
    R1(R1<0)=0;
    if isempty(varargin)
        MI = (R1-R0)./(R0+R1);
    else % compute radial/angular modulation index
        MI = myAngMI(R0,R1);
    end
end
end

function MI = myAngMI(R0,R1)
        [theta, ~] = cart2pol(R0,R1);
        %Put it with respect to -2 to 2 line!
        theta2 = theta + (pi/4);
        theta2(theta2>pi) = theta2(theta2>pi)-2*pi; %Need to simplify pi values to within -pi to +pi after adding
        MI = (abs(theta2)*4/pi) -2;
end