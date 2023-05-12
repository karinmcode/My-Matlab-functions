function [trainedSVM, validationAccuracy] = mytrainAndTestSVM(data, labels)
% Train and test SVM using fitcecoc with a coarse Gaussian kernel and 5-fold cross-validation

% Set up SVM options
svmOptions = templateSVM('KernelFunction', 'gaussian', 'KernelScale',19);

% Set up cross-validation options
cvOptions = cvpartition(labels, 'KFold', 3);

% Train SVM using fitcecoc
trainedSVM = fitcecoc(data, labels, 'Learners', svmOptions, 'CVPartition', cvOptions);

% Compute cross-validation accuracy
validationAccuracy = 1 - kfoldLoss(trainedSVM, 'LossFun', 'ClassifError');
end
