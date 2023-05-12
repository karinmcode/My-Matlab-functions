function tab=myunpackgroups(N,colNames)
% get proportions or number of cases with dimensions refering to variables

N = round(N);
ndim = numel(size(N));
sum_rows  = sum(N,2);
sum_cols  = sum(N,1);
nrow = size(N,1);
ncol = size(N,2);

if ndim<3
    var1 = [];
    var2 = [];

    for icol = 1:ncol
        val2 = icol*ones(sum_cols(icol),1);
        var2 =vertcat(var2,val2);
        for irow = 1:nrow
            val1 = irow*ones(N(irow,icol),1);
            var1 =vertcat(var1,val1);

        end
    end
    VAR = [var1 var2];
elseif ndim ==3
    ndim3 = size(N,3);
        N3 = sum(N,[1 2]);
    var1 = [];
    var2 = [];
    var3 = [];

    for i3 = 1:ndim3
        val3 = i3*ones(N3(i3),1);
        var3 = vertcat(var3,val3);
        for icol = 1:ncol
            val2 = icol*ones(sum_cols(icol),1);
            var2 =vertcat(var2,val2);
            for irow = 1:nrow
                val1 = irow*ones(N(irow,icol),1);
                var1 =vertcat(var1,val1);
            end
        end
        VAR = [var1 var2 var3];
    end
end
if isempty(colNames)
    colNames = cellfun(@(x) sprintf('col%g',x),num2cell(1:ndim),'UniformOutput',false);%provisory
end
tab = array2table(VAR,'VariableNames',colNames);

