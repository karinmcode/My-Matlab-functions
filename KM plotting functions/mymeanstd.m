function s=mymeanstd(d,varargin)
%% s=mymeanstd(d,[ndecimals])
%me =1
%se=1
%ndecimals = 2
ndecimals = 1;
me = mymean(d(:));
se = myste(d(:));

if ~isempty(varargin)
    ndecimals = varargin{1};
end


s = sprintf('MEAN%sSEM=%s%s%s',char(177),num2str(round(me,ndecimals)),char(177),num2str(round(se,ndecimals )));
 