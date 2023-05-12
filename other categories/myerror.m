function myerror(err)
% try
%     kldj=asdf;
% catch err
% rethrow(err)
% end
% warning();
nlines = 3;
nrep = 30;
fprintf('\n')
fprintf(2,repmat(sprintf('\n%s',repmat('-!-',1,nrep)),1,nlines));
fprintf('\n')
disp( getReport( err, 'extended', 'hyperlinks', 'on' ) );
fprintf(2,repmat(sprintf('\n%s',repmat('-!-',1,nrep)),1,nlines));
fprintf('\n')
