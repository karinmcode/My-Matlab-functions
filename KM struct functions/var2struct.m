function OutputStruct=var2struct(varargin)
%% OutputStruct=var2struct(VarList);
% OutputStruct=var2struct(OutputStruct,VarList); % appending


switch nargin
    case 1
        VarList = varargin{1};
        OutputStruct = struct();

    case 2
        if isstruct(varargin{1})
            OutputStruct = varargin{1};
        else
            error('expected output structure as position 1 input.')
        end
        VarList = varargin{2};


end

nfi = numel(VarList);

for ifi =1:nfi
    fi = VarList{ifi};
    cmd = [fi ';'];
    try
        OutputStruct.(fi) = evalin("caller",cmd);
    catch err
        warning(err.message);
    end
end