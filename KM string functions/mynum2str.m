function s=mynum2str(Num,varargin)
%% s=mynum2str(num,[format],['url'],['axlabel'],['cellstr'],['prefix'])
% num can be cell or vector or matrix
% format: matlab format, can be left empty
% 'url' : url compatible string
% 'title' : title compatible string
% 'cellstr' : outputs cell of strings

ISCELL = iscell(Num);
URL=0;
AXLABEL =0;
CELLSTR =0;
PREFIX = 0;
SUFFIX = 0;
if ~isempty(varargin)
    if nargin>=1
        if ~isempty(varargin{1})
        FORMAT = varargin{1};
        end
    end

    if nargin>=2
        other_inputs =varargin(2:end);
        other_inputs_str = other_inputs;
        for i= 1:numel(other_inputs)
            v = other_inputs{1};
            if isa(v,'double')
                other_inputs_str{i} = num2str(v);
            end
        end
        if contains(other_inputs_str,'url')
            URL=1;
        end

        if any(contains(other_inputs_str,{'title' 'axlabel' 'label'}))
            AXLABEL=1;
        end

        if contains(other_inputs_str,'cellstr')
            CELLSTR=1;
        end

        if contains(other_inputs_str,'prefix')
            PREFIX=0;
            pos = find(strcmp(other_inputs_str,'prefix'),1);
            pos = pos+1;
            prefix = other_inputs{pos};
        end

        if contains(other_inputs_str,'suffix')
            SUFFIX=0;
            pos = find(strcmp(other_inputs_str,'suffix'),1);
            pos = pos+1;
            suffix = other_inputs{pos};
        end


        end

      
    end


if ISCELL
    if exist('FORMAT','var')
        s = cellfun(@(x) num2str(x,FORMAT),Num,'UniformOutput',false);
    else
        s = cellfun(@(x) num2str(x),Num,'UniformOutput',false);
    end

    if URL
        s = cellfun(@(x) replace(replace(x,'  ',' '),' ','_'),s,'UniformOutput',false);
        s = cellfun(@(x) replace(x,'.','o'),s,'UniformOutput',false);
    end

    if AXLABEL
        s = cellfun(@(x) replace(x,'_',' '),s,'UniformOutput',false);
    end




else
    if CELLSTR
        if exist('FORMAT','var')
            s = cellfun(@(x) num2str(x,FORMAT),num2cell(Num),'UniformOutput',false);
        else
            s = cellfun(@(x) num2str(x),num2cell(Num),'UniformOutput',false);
        end

        if URL
            s = cellfun(@(x) replace(replace(x,'  ',' '),' ','_'),s,'UniformOutput',false);
            s = cellfun(@(x) replace(x,'.','o'),s,'UniformOutput',false);
        end

        if AXLABEL
            s = cellfun(@(x) replace(x,'_',' '),s,'UniformOutput',false);
        end
 

    else% normal num2str
        if exist('FORMAT','var')
            s =num2str(Num,FORMAT);
        else
            s = num2str(Num);
        end

        if URL
            s = replace(replace(s,'  ',' '),' ','_');
            s =replace(s,'.','o');
        end

        if AXLABEL
            s = replace(s,'_',' ');
        end


    end

end

