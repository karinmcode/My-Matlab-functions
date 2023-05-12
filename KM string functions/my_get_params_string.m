function   ParamsStr = my_get_params_string(Params,varargin)
% generate params for save name;
% ParamsStr = my_get_params_string(Params,['fig'],['save'])

%% get separator
Separator1 = '_';
Separator2 = '__';

if numel(varargin)==1
    if contains(varargin,'fig')
        Separator1 = ' = ';
        Separator2 = ', ';
    else
        Separator1 = '_';
        Separator2 = '__';
    end
elseif numel(varargin)==2
        Separator1 = varargin{1};
        Separator2 = varargin{2};
end

if ~iscell(Params)
    ParamsCell = {Params};% Params is cell containing several structures
else
    ParamsCell = Params;% Params is structure
end

NInputParamsStruct = numel(ParamsCell);
ParamsStrCell = {};

for ipar = 1:NInputParamsStruct
    Params = ParamsCell{ipar};
    f = fieldnames(Params);

    for i=1:numel(f)
        fi = f{i};
        fival = Params.(fi);

        %% FIELD IS STRUCTURE
        if isstruct(fival)
            % rename fields
            FI2 = fieldnames(fival);
           
            % 
            if Separator1 == '_'
                SubParamsStr = get_params_string(fival);
                SubParamsStr = [fi '___' SubParamsStr];
            else
                SubParamsStr = get_params_string(fival,'fig');
                SubParamsStr = [fi ' : ' SubParamsStr];
            end
            ParamsStrCell = cat(2,ParamsStrCell,SubParamsStr);
            continue;
        end

        %% FIELD HAS VALUES OR Strings
        if ~ischar(fival)

            if iscell(fival)
                if numel(fival)==1
                    fival=fival{1};
                    if ~ischar(fival)
                        fival=num2str(fival);
                        while contains(fival,'  ')
                            fival = replace(fival,'  ',' ');
                        end
                    end
                else
                    if ischar(fival{1})
                        fival=strjoin(fival,' ');
                    else
                        fival = cellfun(@(x) num2str(x) , fival,'UniformOutput',false);
                        fival=strjoin(fival,' ');
                        while contains(fival,'  ')
                            fival = replace(fival,'  ',' ');
                        end
                    end
                end

            else
                fival=num2str(fival);
            end

        end
        ParamStr = sprintf('%s%s%s',fi,Separator1,fival);% fieldname_fieldval

        % replace incompatible caracted
        if Separator1=='_'% for filename or url
            ParamStr = replace(ParamStr,{'.'},'o');
            ParamStr = replace(ParamStr,{','},'-');
        elseif contains(Separator1,'=')
            ParamStr = replace(ParamStr,'_',' ');
        end

        ParamsStrCell = cat(2,ParamsStrCell,ParamStr);

    end

end
ParamsStr = strjoin(ParamsStrCell,Separator2);
