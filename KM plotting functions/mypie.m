function   [hpa,htxt] = mypie(pPie,pieLabels,pieColors,varargin)
%% [hpa,htxt] = mypie(pPie,pieLabels,pieColors,[edgecolor,'none'],[textcolor,CM],[location])

%% Check inputs
if ~isempty(varargin)
    [params,param_names] = myparseinputs(varargin);

    [params,param_names]=fixparams(params,param_names);

end

N=numel(pPie);
hpi=pie(pPie,pieLabels);
hpa = hpi(1:2:end);
htxt = hpi(2:2:end);



% if text contains \n make it a new line
for itx = 1:N
    if isfield(params,'dispproportion')
        if params.dispproportion
            htxt(itx).String = sprintf('%s (%.0f%%)',htxt(itx).String,100*pPie(itx));
        end
    end
    if contains(htxt(itx).String,'\n')
        s= htxt(itx).String;
        s = replace(s,'\n','\');
        htxt(itx).String = strsplit(s,'\');

    end


end

% change colors
axis('square');
for i=1:N
    if ischar(pieColors)
        set(hpa(i),'FaceColor',pieColors(i))
    else
        set(hpa(i),'FaceColor',pieColors(i,:))
    end
end

if ~isempty(varargin)
  
    if ismember('edgecolor',param_names)
        set(hpa,'EdgeColor',params.edgecolor);
    end

    if ismember('textcolor',param_names)
        ncolors = size(params.textcolor,1);
        if ncolors>1
            for i = 1:ncolors
                set(htxt(i),'Color',params.textcolor(i,:))
            end
        else
            set(htxt,'Color',params.textcolor)
        end
    end   
    if ismember('fontsize',param_names)
        set(htxt,'fontsize',params.fontsize);
    end   

    if ismember('location',param_names)


        for i=1:N
            switch params.location
                case {'center' 'middle' 'inside'}% text label at the center of each patch
                    ht=htxt(i);
                    set(htxt(i),'HorizontalAlignment','center','verticalalignment','middle','fontsize',10);
                    h = hpa(i);
               
                    x = ht.Position(1)/2;
                    y = ht.Position(2)/2;
                case {'periph' 'perif' 'around'}
                    ht=htxt(i);
                    x = ht.Position(1);
                    y = ht.Position(2);
                    if x==0 
                        set(ht,'HorizontalAlignment','center')
                    end

                    if y == 0
                       set(ht ,'verticalalignment','middle')
                    end

                    if x>0
                        set(ht,'HorizontalAlignment','left')
                    else
                        set(ht,'HorizontalAlignment','right')
                    end

                    if y>0
                        set(ht,'verticalalignment','bottom')
                    else
                        set(ht,'verticalalignment','top')
                    end
                case {'inandout' 'inout'}
                    inLab = params.inLabels;
                    outLab = params.outLabels;
                    keyboard;

            end

            htxt(i).Position(1:2) =[x y] ;
        end
    
    
    end
end
end

function [params,param_names]=fixparams(params,param_names)

for param_name = param_names(:)'
    if ~strcmp(param_name{:},lower(param_name{:}))
        params.(lower(param_name{:}))=params.(param_name{:});
        params = rmfield(params,param_name{:});
    end
end

param_names = fieldnames(params);
end
