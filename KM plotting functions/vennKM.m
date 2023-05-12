%% FUNCTION [V, Vs] = vennKM(R0,event_names);
function [V, Vs,zoneColors,I4zone,N,Zprop,txtLabels] = vennKM(R,labels,varargin)
%% [V, Vs,zoneColors,i4zone] = vennKM(R0,labels)


FaceAlpha=0.6;
nA = size(R,1);
ncircles = size(R,2);
if isempty(varargin)
    colors = {'r','g' 'b'};
    colors = colors(1:ncircles);
else
    colors = varargin{1};
end
if ncircles==2
    comp = [1 2];
    nzones = 3;
else
    comp = [1 2; 1 3; 2 3];
    nzones = 7;
end
vec = 1:ncircles;

%% compute proportions for each circle
N= nan(nzones,1);
Zprop = nan(nzones,1);
I4zone = nan(nA,1);

for iZ=1:nzones


    if iZ<=ncircles
        i4zone = R(:,iZ)==1& all(R(:,setdiff(vec,iZ))==0,2);
    elseif iZ>ncircles && iZ<nzones
        i1 = comp(iZ-ncircles,1);
        i2 = comp(iZ-ncircles,2);
        i3 = setdiff(vec,[i1 i2]);
        i4zone =R(:,i1)==1 & R(:,i2)==1 & R(:,i3)==0;
    else
        i4zone =all(R==1,2);
    end
    I4zone(i4zone)=iZ;
    N(iZ) = sum(i4zone);
    Zprop(iZ)= mean(i4zone);

end

Zprop(Zprop==0)=0.001;

%% plot it
try
    [V, Vs] = venn(Zprop,'FaceColor',colors,'FaceAlpha',repmat({FaceAlpha},1,ncircles),'EdgeColor','black');
catch err
    disp('venn error')
    V= [];
    Vs= [];
    zoneColors = [];
    txtLabels = gobjects(nzones,1);
    return;
end
hold on;
axis tight equal;

% add labels
XLIM = xlim;
dX = diff(XLIM);
YLIM = ylim;
dY = diff(YLIM);


% n cells text
txt_n=text(mean(XLIM),YLIM(2)+dY*0.1,sprintf('%d cells',nA));
set(txt_n,'HorizontalAlignment','center')

% legend

if ncircles==3
xlabel(['\bf \color{red}' labels{1}   '     \color{green}' labels{2}  '     \color{blue}' labels{3}])
else
leg = legend(V,labels,'location','bestoutside');
set(leg,'location','southoutside','Box','off')
end
% t_L1=text(-Lim80,mean([0 -Lim80]),labels{1},'color','r','horizontalalignment','right','fontweight','bold');
% t_L2=text(Lim80,mean([0 -Lim80]),labels{2},'color','g','fontweight','bold','horizontalalignment','left');
% if ncircles>2
%     t_L3=text(0,Lim*1.1,labels{3},'color','b','fontweight','bold','horizontalalignment','center');
% end


% add numbers and get colors
zoneColors = nan(nzones,3);
txtLabels = gobjects(nzones,1);
for iZ=1:nzones
    c1 = Vs.ZoneCentroid(iZ,:);
    if iZ<=ncircles
        zoneColors(iZ,:) = get(V(iZ),'FaceColor')+get(V(iZ),'FaceAlpha');
        zoneColors(iZ,zoneColors(iZ,:)>1)=1;
    elseif iZ>ncircles && iZ<nzones

        if ncircles ==3% provisory [z1 z2 z3 z12 z13 z23 z123]
            switch iZ
                case 4% r+g = g
                    zoneColors(iZ,:) = [102 194 41]/255;
                case 5% r+b = vio  [r g b 4:rg 5:rb 6:gb 7:rgb]
                    zoneColors(iZ,:) = [102 51 204]/255;
                case 6% g+ b = dark blue
                    zoneColors(iZ,:) = [40 102 194]/255;
                case 7 %rgb
                    zoneColors(iZ,:) = [43 79 166]/255;
            end
        else
            zoneColors(iZ,:) = (zoneColors(i1,:)+zoneColors(i2,:))/2;

        end
    else
        zoneColors(iZ,:) = mean(zoneColors(1:ncircles,:),1);
    end
    p1 = 100*N(iZ)/nA;
    txtLabels(iZ) = text(c1(1),c1(2),sprintf('%d (%.0f%%)',N(iZ),p1),'color','w');
    set(txtLabels(iZ),'horizontalalignment','center','fontweight','bold')
end
set(gca,'ycolor','none','xcolor','w')

% add cases that do not  cells
i4Z0 = isnan(I4zone);
I4zone(i4Z0) = nzones+1;
N(nzones+1)= sum(i4Z0);
zoneColors(nzones+1,:)=[1 1 1];
Zprop(nzones+1,:) = N(nzones+1)/nA;
txtLabels(nzones+1) = text(min(xlim),min(ylim),sprintf('%d (%.0f%%)',N(end), 100*N(nzones+1)/nA),'color','k');
set(txtLabels(nzones+1),'horizontalalignment','left','fontweight','normal')

end
