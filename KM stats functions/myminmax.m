function MINMAX=myminmax(d,varargin)
% MINMAX=myminmax(d,[ROUNDING_decimals= -1 0 1 ])
if ~isempty(varargin)
    ROUNDING_decimals=varargin{1};
else
    ROUNDING_decimals=nan;
end
MIN = min(d(:),[],1,'omitnan');
MAX = max(d(:),[],1,'omitnan');
if ~isnan(ROUNDING_decimals)
    if numel(ROUNDING_decimals)==1
        MIN = floor(MIN*10^-ROUNDING_decimals)*10^ROUNDING_decimals;
        MAX = ceil(MAX*10^-ROUNDING_decimals)*10^ROUNDING_decimals;
    else
        
        [r,c,MIN] = findnearest(MIN,ROUNDING_decimals,-1);
        [r,c,MAX] = findnearest(MAX,ROUNDING_decimals,1);
    
    end
end
MINMAX = [MIN MAX];
