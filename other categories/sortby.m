function [INDEXESinA,Asorted,varargout]=sortby(Order,A,varargin)
%   [INDEXESinA,Asorted,varargout]=sortby(Order,A,varargin)
N = numel(Order);
nrow = size(A,1);
ncol = size(A,2);
Asorted = [];
ISCELL = iscell(Order);
INDEXESinA = [];

for i=1:N
    id = Order(i);
    if ~ISCELL
        i4id = find(A==id);
    else
        i4id = find(strcmp(A,id));
    end
    Asorted = vertcat(Asorted,A(i4id));
    INDEXESinA=vertcat(INDEXESinA,i4id);
end

if numel(A)~=numel(Asorted)
    keyboard
end

% sort other vectors
if ~isempty(varargin)
    ninputs = numel(varargin);
    varargout = cell(1,ninputs);
    for i = 1:ninputs
        varargout{i}=varargin{i}(INDEXESinA);
    end

end