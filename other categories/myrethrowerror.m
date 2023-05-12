function myerror(err)
% try
%     kldj=asdf;
% catch err
% rethrow(err)
% end
% warning();
fprintf(2, getReport( err, 'extended', 'hyperlinks', 'on' ) );
