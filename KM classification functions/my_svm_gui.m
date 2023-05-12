classdef my_svm_gui < handle
    properties

        X;
        Y;
        gui;
        data;
        params;
      

    end

    methods
        function o = my_svm_gui(varargin)
            % Load example data or initialize with empty data
            if ~isempty(varargin)
                o.X = varargin{1};
                o.Y = varargin{2};
            else
            if exist('SVM_example_data.mat', 'file') == 2
                load('SVM_example_data.mat');
                o.X = X;
                o.Y = Y;
            else
                o.X = [];
                o.Y = [];
            end
            end
            o.constructGUI();
            o.set_params();

            figure(o.gui.fig);
        end

        function constructGUI(o)
            clc;
            % Find and close existing figure with the same name if it exists
            existing_fig = findobj('type', 'figure', 'Name', 'SVM Parameter Tuning');
            if ~isempty(existing_fig)
                close(existing_fig);
            end

            % Create the main figure
            o.gui.fig = figure('Name', 'SVM Parameter Tuning', 'Position', [100, 100, 800, 500],'WindowStyle','normal');
            mybestfigpos(o.gui.fig);%
            %o.gui.fig.Position = [2500, 700, 800, 400]
            % Create context menu with help option
            cmenu = uicontextmenu;
            uimenu(cmenu, 'Label', 'Help', 'Callback', @(src, event) o.help_message(src, event));
            o.gui.fig.UIContextMenu = cmenu;

            % Create labels, sliders, and buttons
            o.createUIControls();

            % Create axes for confusion matrix
            o.gui.confusion_axes = axes('Parent', o.gui.fig, 'Position', [0.55, 0.15, 0.4, 0.7]);
            xlabel('Predicted Label');
            ylabel('True Label');
            title('Confusion Matrix (test data)');
        end

        function createUIControls(o)

            y0 = 450;
            vOff = 30;
            y = y0;
            x1 = 230;
            x2 = 255;

            % create params holdout
            y = y-vOff;
            uicontrol('Style', 'text', 'String', 'Proportion Hold Out:', 'Position', [30, y, 130, 20]);
            o.gui.holdout_edit = uicontrol('Style', 'edit', 'String', '0.2', 'Position', [170, y, 50, 20], ...
                'Callback', @(src, event) o.update_plot(src, event),'UserData',struct('incrementStep',0.05,'minVal',0,'maxVal',0.99));
            o.gui.holdout_minus_button = uicontrol('Style', 'pushbutton', 'String', '-', 'Position', [x1, y, 20, 20], ...
                'Callback', @(src, event) o.increment_param(src, event),'UserData','holdout_edit');
            o.gui.holdout_plus_button = uicontrol('Style', 'pushbutton', 'String', '+', 'Position', [x2, y, 20, 20], ...
                'Callback', @(src, event) o.increment_param(src, event),'UserData','holdout_edit');

            % create params C
            y = y-vOff;
            uicontrol('Style', 'text', 'String', 'C (Regularization):', 'Position', [30, y, 100, 20]);
            o.gui.C_edit = uicontrol('Style', 'edit', 'String', '1', 'Position', [170, y, 50, 20], ...
                'Callback', @(src, event) o.update_plot(src, event),'UserData',struct('incrementStep',10,'minVal',0.001,'maxVal',1000));
            o.gui.C_minus_button = uicontrol('Style', 'pushbutton', 'String', '-', 'Position', [x1, y, 20, 20], ...
                'Callback', @(src, event) o.increment_param(src, event),'UserData','C_edit');
            o.gui.C_plus_button = uicontrol('Style', 'pushbutton', 'String', '+', 'Position', [x2, y, 20, 20], ...
                'Callback', @(src, event) o.increment_param(src, event),'UserData','C_edit');

            % create params Kernel
            y = y-vOff;
            uicontrol('Style', 'text', 'String', 'Kernel Function:', 'Position', [30, y, 100, 20]);
            o.gui.kernel_popup = uicontrol('Style', 'popupmenu', 'String', {'linear', 'rbf', 'polynomial'}, 'Position', [170, y, 100, 20], ...
                'Callback', @(src, event) o.update_plot(src, event));

            % create params Gamma
            y = y-vOff;
            uicontrol('Style', 'text', 'String', 'Gamma (RBF kernel):', 'Position', [30, y, 120, 20]);
            o.gui.gamma_edit = uicontrol('Style', 'edit', 'String', '1', 'Position', [170, y, 50, 20], ...
                'Callback', @(src, event) o.update_plot(src, event),'UserData',struct('incrementStep',10,'minVal',0.001,'maxVal',1000));
            o.gui.gamma_minus_button = uicontrol('Style', 'pushbutton', 'String', '-', 'Position', [x1, y, 20, 20], ...
                'Callback', @(src, event) o.increment_param(src, event),'UserData','gamma_edit');
            o.gui.gamma_plus_button = uicontrol('Style', 'pushbutton', 'String', '+', 'Position', [x2, y, 20, 20], ...
                'Callback', @(src, event) o.increment_param(src, event),'UserData','gamma_edit');

            % create params Degree
            y = y-vOff;
            uicontrol('Style', 'text', 'String', 'Degree (Polynomial kernel):', 'Position', [30, y, 140, 20]);
            o.gui.degree_edit = uicontrol('Style', 'edit', 'String', '3', 'Position', [170, y, 50, 20], 'Callback', @(src, event) o.update_plot(src, event),'UserData',struct('incrementStep',1,'minVal',1,'maxVal',10));
            uicontrol('Style', 'pushbutton', 'String', '-', 'Position', [x1, y, 20, 20], 'Callback', @(src, event) o.increment_param(src, event),'UserData','degree_edit');
            uicontrol('Style', 'pushbutton', 'String', '+', 'Position', [x2, y, 20, 20], 'Callback', @(src, event) o.increment_param(src, event),'UserData','degree_edit');

            % create params Degree
            y = y-vOff;
            o.gui.leave_one_out_cross_validation_checkbox = uicontrol('Style', 'checkbox', 'String', 'Leave-one-out cross-validation', 'Value', 1, 'Position', [30, y, 200, 20]);

            % create params Chance level
            y = y-vOff;
            o.gui.compute_chance_level = uicontrol('Style', 'checkbox', 'String', 'Compute chance level', 'Value', 1, 'Position', [30, y, 200, 20]);

            % create  plot Chance level
            y = y-vOff;
            o.gui.plot_chance_level = uicontrol('Style', 'checkbox', 'String', 'Plot chance level', 'Value', 1, 'Position', [30, y, 200, 20]);            

            % create buttons
            o.gui.load_data_button = uicontrol('Style', 'pushbutton', 'String', 'Load Data', 'Position', [30, 130, 100, 30], 'Callback', @(src, event) o.load_data(src, event));
            o.gui.load_example_data_button = uicontrol('Style', 'pushbutton', 'String', 'Load Example Data', 'Position', [140, 130, 120, 30], 'Callback', @(src, event) o.load_example_data(src, event));
            o.gui.train_svm_button = uicontrol('Style', 'pushbutton', 'String', 'Train SVM', 'Position', [30, 80, 100, 30], 'Callback', @(src, event) o.update_plot(src, event));
            o.gui.find_best_parameters_button = uicontrol('Style', 'pushbutton', 'String', 'Find Best Parameters', 'Position', [140, 80, 130, 30], 'Callback', @(src, event) o.find_best_parameters(src, event));

            o.add_tooltipstrings();

            o.gui.msg = uicontrol('Style', 'text', 'String', {'GUI ready to go!'}, 'Position', [30, 10, 200, 90],'HorizontalAlignment','left');
            set(o.gui.msg,'position',[30, 10, 350, 60])
        end


        function add_tooltipstrings(o)
            % Add tooltipstrings to UI controls

            set(o.gui.holdout_edit, 'TooltipString', sprintf(['Specify the proportion of trials to hold out\n'...
                'for the test data. Recommended value: 0.2']))
            set(o.gui.C_edit, 'TooltipString', sprintf(['Adjust the regularization parameter C to balance\n'...
                'between classification accuracy and margin width.\n'...
                'Recommended values: 0.1 to 100.\n\n' ...
                'In general, increasing the value of C will increase the complexity of the model, making it more likely to overfit the training data. Decreasing the value of C will reduce the complexity of the model, making it more likely to underfit the data. Therefore, the optimal value of C will depend on the specific problem and data at hand. Current value: %0.2f'], get(o.gui.C_edit, 'Value')));

            set(o.gui.gamma_edit, 'TooltipString', sprintf(['Change the decision boundary shape for the\n'...
                'RBF kernel by adjusting the gamma parameter.\n'...
                'Recommended values: 0.001 to 10. Current value: %0.2f'], get(o.gui.gamma_edit, 'Value')));

            set(o.gui.degree_edit, 'TooltipString', sprintf(['Set the complexity of the polynomial kernel\n'...
                'by adjusting the degree parameter.\n'...
                'Recommended values: 1 to 10. Current value: %d'], round(get(o.gui.degree_edit, 'Value'))));

            set(o.gui.leave_one_out_cross_validation_checkbox, 'TooltipString', sprintf(['Ignores pHoldout. Do if low number of observations.\n'...
             ]))
        end


        function Params = set_params(o,varargin)
            o.params.niter = 5;
            o.params.C = 0.022;
            o.params.gamma = 2200;
            o.params.kernel = 'linear';
            o.params.degree = '1';
            if ~isempty(varargin)

                Params = varargin{1};
                f = fieldnames(Params);
                n = numel(f);
                for i = 1:n
                    o.params.(f{i}) = Params.(f{i});
                    if ~isstring(Params.(f{i}))
                        o.gui.(f{i}).String = num2str( Params.(f{i}));
                    else
                        o.gui.(f{i}).Value = find(strcmp(o.gui.(f{i}).String,Params.(f{i})));
                    end
                end

            end
            Params = o.params;
        end
        
        function increment_param(o, src, ~)


            % Determine increment step and direction from UserData of source object
            Name = src.UserData;
            h = o.gui.(Name);
            inc = h.UserData.incrementStep;
            switch  src.String
                case '+'
                    dir = +1;
                case '-'
                    dir = -1;
            end
            % Get current parameter value
            current_value = str2double(h.String);
            % Calculate new parameter value
            new_value = current_value + dir * inc;

            % Set new parameter value
            h.String = num2str(new_value);

         
        end

        function [C, kernel, gamma, degree,params] = get_params(o)
            C = str2num(o.gui.C_edit.String);
            kernel = o.gui.kernel_popup.String{o.gui.kernel_popup.Value};
            gamma = str2num(o.gui.gamma_edit.String);
            degree = str2num(o.gui.degree_edit.String);

        end

        function [pval,Accuracy,fig,confusion_mat]=update_plot(o, ~, ~)
            if isempty(o.X) || isempty(o.Y)
                return;
            end

            o.gui.train_svm_button.BackgroundColor = 'r';
            drawnow;
            % Get parameters from sliders and popup
            [C, kernel, gamma, degree] = get_params(o);

            % Create and train SVM model with the selected parameters
            [Accuracy,confusion_mat] = o.train_svm(C, kernel, gamma, degree);


            % Update confusion matrix plot
            imagesc(o.gui.confusion_axes, confusion_mat);
            colormap(o.gui.confusion_axes, 'jet');
            colorbar;
            axis square;
            xticks(1:size(confusion_mat, 2));
            yticks(1:size(confusion_mat, 1));
            xlabel('Predicted Label');
            ylabel('True Label');
            title(sprintf('Confusion Matrix\nAccuracy = %.2f',Accuracy));

            o.gui.train_svm_button.BackgroundColor = 'g';drawnow;
            fig = gobjects(1);
            if o.gui.compute_chance_level.Value

                [chanceAccuracies,chanceAccuracy ]=o.compute_chance_level(C, kernel, gamma, degree);
                
                if o.gui.plot_chance_level.Value==0
                    pval = o.test_chance_level(Accuracy,chanceAccuracies);
                else
                    [fig,pval]=o.plot_chance_level(Accuracy,chanceAccuracies);
                end
            end



        end

        function [svm_model,Accuracy,confMat] = train_svm(o, C, kernel, gamma, degree)
                X = o.X;%#ok
                Y = o.Y;%#ok

%                 if isempty(varargin)
% 
%                 else
%                     
%                 end

            if o.gui.leave_one_out_cross_validation_checkbox.Value
                [svm_model, Accuracy,confMat] = o.train_svm_leave1out(X,Y,C, kernel, gamma, degree);%#ok
            else
                [svm_model, Accuracy,confMat] = o.train_svm_pHoldOut(X,Y,C, kernel, gamma, degree);%#ok
            end
        end

        function [Accuracy, conf_mat,svm_model] = train_svm_leave1out(o,X,Y, C, kernel, gamma, degree)
            % leave-one-out cross-validation
            o.msg('train_svm_leave1out');
            % variables
   
            num_trials = size(X, 1);



            % Preallocate
            Accuracy = zeros(num_trials, 1);
            conf_mat = zeros(numel(unique(Y)));
            if strcmp(kernel, 'linear')
                svm_model = fitcecoc(X, Y, 'Learners', templateSVM('Standardize', true, 'BoxConstraint', C, 'KernelFunction', 'Linear'));
            elseif strcmp(kernel, 'polynomial')
                svm_model = fitcecoc(X, Y, 'Learners', templateSVM('Standardize', true, 'BoxConstraint', C, 'KernelFunction', 'Polynomial', 'PolynomialOrder', degree));
            elseif strcmp(kernel, 'rbf')
                svm_model = fitcecoc(X, Y, 'Learners', templateSVM('Standardize', true, 'BoxConstraint', C, 'KernelFunction', 'RBF', 'KernelScale', gamma));
            end

            if iscell(Y)
                YPRED = cell(num_trials,1);
            else
                YPRED = nan(num_trials,1);
            end

            parfor i = 1:num_trials
                sz=fprintf('%g/%g',i,num_trials);
                X_train = X;
                X_train(i, :) = [];
                Y_train = Y;
                Y_train(i) = [];


                % Train SVM model
                if strcmp(kernel, 'linear')
                    svm_model = fitcecoc(X_train, Y_train, 'Learners', templateSVM('Standardize', true, 'BoxConstraint', C, 'KernelFunction', 'Linear'));
                elseif strcmp(kernel, 'polynomial')
                    svm_model = fitcecoc(X_train, Y_train, 'Learners', templateSVM('Standardize', true, 'BoxConstraint', C, 'KernelFunction', 'Polynomial', 'PolynomialOrder', degree));
                elseif strcmp(kernel, 'rbf')
                    svm_model = fitcecoc(X_train, Y_train, 'Learners', templateSVM('Standardize', true, 'BoxConstraint', C, 'KernelFunction', 'RBF', 'KernelScale', gamma));
                else
                    error('Unknown kernel type.')
                end

                Y_pred = predict(svm_model, X(i, :));
                if iscell(Y_pred)
                    Accuracy(i) = strcmp(Y_pred , Y(i));
                else
                    Accuracy(i) = Y_pred == Y(i);
                end

                % Update the local confusion matrix
                YPRED(i) = Y_pred;
                fprintf(repmat('\b',1,sz));
            end

            conf_mat = confusionmat(Y, YPRED);

            Accuracy = mean(Accuracy);
        end


        function [svm_model, Accuracy, confusionMatrix] = train_svm_pHoldOut(o,X,Y, C, kernel, gamma, degree)

                % Split data into training and testing sets
                c = cvpartition(size(o.X, 1), 'HoldOut', str2num(o.gui.holdout_edit.String));
                Accuracy = zeros(c.NumTestSets,1);

                % Loop through each fold
                for i = 1:c.NumTestSets
                    train_idx = c.training(i);
                    test_idx = c.test(i);

                    Xtrain = X(train_idx,:);
                    Ytrain = Y(train_idx,:);
                    % Train SVM model
                    if strcmp(kernel, 'linear')
                        svm_model = fitcecoc(Xtrain, Ytrain, 'Learners', templateSVM('Standardize', true, 'BoxConstraint', C, 'KernelFunction', 'Linear'));
                    elseif strcmp(kernel, 'polynomial')
                        svm_model = fitcecoc(Xtrain, Ytrain, 'Learners', templateSVM('Standardize', true, 'BoxConstraint', C, 'KernelFunction', 'Polynomial', 'PolynomialOrder', degree));
                    elseif strcmp(kernel, 'rbf')
                        svm_model = fitcecoc(Xtrain, Ytrain, 'Learners', templateSVM('Standardize', true, 'BoxConstraint', C, 'KernelFunction', 'RBF', 'KernelScale', gamma));
                    else
                        error('Unknown kernel type.')
                    end

                    % Predict labels for testing set
                    y_pred = predict(svm_model, X(test_idx,:));

                    % Calculate accuracy
                    if iscell(Y)

                        Accuracy(i) = sum(strcmp(y_pred,Y(test_idx,:))) / numel(y_pred);
                    else
                        Accuracy(i) = sum(y_pred == Y(test_idx,:)) / numel(y_pred);
                    end
                end

                % Calculate mean accuracy across all folds
                Accuracy = mean(Accuracy);
% 
%   % Split the data into training and test sets based on the holdout proportion
%                 cv = cvpartition(size(o.X, 1), 'HoldOut', str2num(o.gui.holdout_edit.String));
%                 X_train = o.X(training(cv), :);
%                 y_train = o.Y(training(cv), :);
%                 X_test = o.X(test(cv), :);
%                 y_test = o.Y(test(cv), :);
% 
%                 num_classes = numel(unique(o.Y));
% 
%                 if num_classes <= 2
%                     if strcmp(kernel, 'linear')
%                         svm_model = fitcsvm(X_train, y_train, 'BoxConstraint', C, 'KernelFunction', kernel);
%                     elseif strcmp(kernel, 'rbf')
%                         svm_model = fitcsvm(X_train, y_train, 'BoxConstraint', C, 'KernelFunction', kernel, 'KernelScale', gamma);
%                     else
%                         svm_model = fitcsvm(X_train, y_train, 'BoxConstraint', C, 'KernelFunction', kernel, 'PolynomialOrder', degree);
%                     end
%                 else
%                     t = templateSVM('KernelFunction', kernel, 'BoxConstraint', C, 'PolynomialOrder', degree, 'KernelScale', gamma);
%                     svm_model = fitcecoc(X_train, y_train, 'Learners', t);
%                 end

                y_pred = predict(svm_model,X_test);
                confusionMatrix = confusionmat(y_test,y_pred);


        end

        function load_data(o, ~, ~)
            [filename, pathname] = uigetfile('*.mat', 'Select Data File');
            if isequal(filename, 0) || isequal(pathname, 0)
                return;
            end

            data = load(fullfile(pathname, filename));
            if isfield(data, 'X') && isfield(data, 'Y')
                o.X = data.X;
                o.Y = data.Y;
            else
                msgbox('Invalid data file. It should contain variables X and Y.', 'Error', 'error');
            end
        end

        function load_example_data(o, ~, ~)
            X = load('fisheriris');
            o.Y = X.species;
            o.X = X.meas;
            o.load_example_data_button.BackgroundColor = 'g';
        end

        function help_message(o, ~, ~)
            help_text = sprintf(['Optimally varying parameters:\n' ...
                '\nC: Increase for better classification at the cost of a smaller margin. Decrease for a larger margin but potentially more classification errors.' ...
                '\n\nKernel: Choose the most appropriate kernel for your data. Linear for linearly separable, RBF for complex boundaries, and polynomial for intermediate complexity.' ...
                '\n\nGamma (RBF kernel): Increase for a more flexible decision boundary, decrease for a smoother decision boundary.' ...
                '\n\nDegree (Polynomial kernel): Increase for a more complex decision boundary, decrease for a simpler decision boundary.']);
            msgbox(help_text, 'Help');
        end

        function find_best_parameters(o, src, event)

            o.gui.find_best_parameters_button.BackgroundColor = 'r';
            drawnow;
            best_params = [];
            best_cv_accuracy = -Inf;

            C_values = logspace(-3, 3, 10);% default logspace(-3, 3, 10)
            gamma_values = logspace(-3, 3, 10);%default logspace(-3, 3, 10)
            degree_values = 1:3;% defaul 1:10

            nLinear = length(C_values);
            nRBF = length(C_values) * length(gamma_values);
            nPoly = length(C_values) *length(degree_values);
            total_combinations = nLinear+nRBF+nPoly;
            current_combination = 0;

            fprintf('Performing parameter search...\n');
            TESTED_PARAMS = nan(total_combinations,4);
            ACCURACY =  nan(total_combinations,1);

            X = o.X;
            Y = o.Y;
            for kernel_idx = 1:length(o.gui.kernel_popup.String)
                kernel = o.gui.kernel_popup.String{kernel_idx};
                for C = C_values

                    if strcmp(kernel, 'linear')
                        gamma = 1;  % Dummy value, not used for linear kernel
                        degree = 1; % Dummy value, not used for linear kernel
                        current_combination = current_combination + 1;
                        progress = current_combination / total_combinations;
                        remaining_time = toc / progress * (1 - progress);

                        Accuracy = o.train_svm(C, kernel, gamma, degree);

                        if Accuracy > best_cv_accuracy
                            best_cv_accuracy = Accuracy;
                            best_params = [C, kernel_idx, gamma, degree];
                        end
                        TESTED_PARAMS(current_combination,:)= [C, kernel_idx, gamma, degree];
                        ACCURACY(current_combination)=Accuracy;
                        fprintf('Tested C=%f, kernel=%s, gamma=%f, degree=%d, accuracy=%.2f Progress: %.2f%%, Remaining time: %s\n', C, kernel, gamma, degree,Accuracy, progress*100, datestr(seconds(remaining_time), 'HH:MM:SS'));
                    elseif strcmp(kernel, 'rbf')
                        degree = 1; % Dummy value, not used for rbf kernel
                        for gamma = gamma_values

                            current_combination = current_combination + 1;
                            progress = current_combination / total_combinations;
                            remaining_time = toc / progress * (1 - progress);


                            Accuracy = o.train_svm(C, kernel, gamma, degree);

                            if Accuracy > best_cv_accuracy
                                best_cv_accuracy = Accuracy;
                                best_params = [C, kernel_idx, gamma, degree];
                            end

                            fprintf('Tested C=%f, kernel=%s, gamma=%f, degree=%d, accuracy=%.2f Progress: %.2f%%, Remaining time: %s\n', C, kernel, gamma, degree,Accuracy, progress*100, datestr(seconds(remaining_time), 'HH:MM:SS'));
                            TESTED_PARAMS(current_combination,:)= [C, kernel_idx, gamma, degree];
                            ACCURACY(current_combination)=Accuracy;
                        end % End gamma loop for rbf kernel
                    elseif strcmp(kernel, 'polynomial')
                        gamma = 1;  % Dummy value, not used for polynomial kernel
                        for degree = degree_values

                            current_combination = current_combination + 1;
                            progress = current_combination / total_combinations;
                            remaining_time = toc / progress * (1 - progress);


                            Accuracy = o.train_svm(C, kernel, gamma, degree);

                            if Accuracy > best_cv_accuracy
                                best_cv_accuracy = Accuracy;
                                best_params = [C, kernel_idx, gamma, degree];
                            end
                            fprintf('Tested C=%f, kernel=%s, gamma=%f, degree=%d, accuracy=%.2f Progress: %.2f%%, Remaining time: %s\n', C, kernel, gamma, degree,Accuracy, progress*100, datestr(seconds(remaining_time), 'HH:MM:SS'));
                            TESTED_PARAMS(current_combination,:)= [C, kernel_idx, gamma, degree];
                            ACCURACY(current_combination)=Accuracy;
                        end % End degree loop for polynomial kernel
                    end

                end
            end

            % Display the best parameters found
            fprintf('Best parameters: C = %f, kernel = %s, gamma = %f, degree = %d\n', best_params(1), o.gui.kernel_popup.String{best_params(2)}, best_params(3), best_params(4));

            % Update UI controls with the best parameters
            o.gui.C_edit.String = num2str(best_params(1));
            o.gui.kernel_popup.Value = best_params(2);
            o.gui.gamma_edit.String = num2str(best_params(3));
            o.gui.degree_edit.String = num2str(best_params(4));

            % Train the SVM with the best parameters and update the confusion matrix plot
            o.update_plot(src, event);

            % Plot all params accuracies
            o.plotFindBestParameters(TESTED_PARAMS,ACCURACY);
            o.data.TESTED_PARAMS =TESTED_PARAMS;
            o.data.ACCURACY =ACCURACY;
            o.gui.find_best_parameters_button.BackgroundColor = 'g';
        end




        function             fig = plotFindBestParameters(o,TESTED_PARAMS,ACCURACY)
            % TESTED_PARAMS = [C, kernel_idx, gamma, degree]
            fig = makegoodfig('My params tuning','slide');

            C = TESTED_PARAMS(:,1);
            kernel_idx = TESTED_PARAMS(:,2);
            gamma = TESTED_PARAMS(:,3);
            degree = TESTED_PARAMS(:,4);

            nax = numel(o.gui.kernel_popup.String);
            for iax = 1:nax
                ax=subplot(1,nax,iax,"replace");
                i4kernel = kernel_idx==iax;
                switch iax
                    case 1
                        X = C(i4kernel);
                        XLAB = 'C';
                        set(gca,'XScale','log')
                    case 2
                        X1 = C(i4kernel);
                        X2 = gamma(i4kernel);
                        X = [X1 X2];
                        XLAB = 'gamma';
                    case 3
                        X1 = C(i4kernel);
                        X2 = degree(i4kernel);
                        X = [X1 X2];                
                        XLAB = 'degree';
                end
                Y = ACCURACY(i4kernel,:);%#ok
                if size(X,2)==1
                    plot(X, Y, 'bo');%#ok
                else
                    uX1 = unique(X1);
                    nx1 = numel(uX1);
                    CM = jet(nx1);
                    pl = gobjects(nx1,1);
                    for ix1 = 1:nx1
                        i4x1 = X1==uX1(ix1);
                        pl(ix1)=plot(X2(i4x1), Y(i4x1), 'bo-','color',CM(ix1,:),'MarkerFaceColor',CM(ix1,:));
                        hold on;
                    end
                    set(ax,'Colormap',CM);
                    cb=colorbar(ax);

                    ylabel(cb,'C')
                    CLIM = [min(X1) max(X1)];
                    clim(ax,CLIM)
                    caxis(CLIM);
                end
                xlabel(XLAB);
                ylabel('Accuracy');
                [bestAccu,i4best]=max(ACCURACY(i4kernel));
                best_params = X(i4best);
                title(sprintf('Kernel = %s\nBest %s = %0.2g\nAccuracy = %0.2g',o.gui.kernel_popup.String{iax},XLAB,best_params,bestAccu));
               
                switch iax
                    case 1
                   
                        set(gca,'XScale','log')
                    case 2
                        set(gca,'XScale','log')
                    case 3
                        set(gca,'XScale','linear')
                end          
                axis square;
            end
            AX = findobj(fig,'type','axes');
            linkaxes(AX,'y')
            for iax = 1:numel(AX)
            AX(iax).Position(3:4)=AX(1).Position(3:4);
            end
            keyboard;

        end



        function [chanceAccuracies, chanceAccuracy] =compute_chance_level(o, C, kernel, gamma, degree)

            if o.gui.leave_one_out_cross_validation_checkbox.Value
                [chanceAccuracies,chanceAccuracy]=o.compute_chance_level_leave1out( C, kernel, gamma, degree);
            else
                [chanceAccuracies,chanceAccuracy]=o.compute_chance_level_pHoldOut(C, kernel, gamma, degree);
            end
        end

        function pval = test_chance_level(o,Accuracy,chanceAccuracies)
            [h, pval, ~, stats] = ttest(chanceAccuracies, Accuracy);
        end



        function [fig,pval] = plot_chance_level(o,Accuracy,chanceAccuracies)
            fig = makegoodfig('plot_chance_level','slide_half_width');

            nrow = 2;
            ncol = 1;
            ax1 = subplot(nrow,ncol,1);
            p = ax1.Position;
            delete(ax1);
            ax1 = copyobj(o.gui.confusion_axes,fig);
            set(ax1,'position',p);
            axis(ax1,'square')

            chanceLevel = mean(chanceAccuracies);
            % plot accuracy versus chance level
            ax2=subplot(2,1,2,'replace');
            ba=bar(Accuracy, 'FaceColor', 'k');
            hold on;
            plot([0 2],[chanceLevel chanceLevel],':k')
            [lower_bound, upper_bound] = my_compute_confidence_interval(chanceAccuracies, 0.90);
            patch([0.5 1.5 1.5 0.5], [upper_bound upper_bound lower_bound lower_bound], 'k', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            ylim([0 1]);
            ylabel('Accuracy');
            if o.gui.leave_one_out_cross_validation_checkbox.Value==0
            xticklabels({ sprintf('Test %g%%',o.pHoldOut*100)});
            else
            xticklabels({sprintf('Leave 1 out')});
            end
            X  =o.X;
            Y = o.Y;

            ntrials = size(o.X,1);
            nce = size(o.X,2);
            [G,pG] = findgroups(o.Y);
            nG=groupcounts(G);
            M=groupsummary(X,Y,"mean");
            MM=mean(M,2);
            nrep = replace(num2str(nG'),'  ',' ');
            xlabel(sprintf('Chance level: %.2f\nn test trials=%g\nnce=%g\nnrep=%s', chanceLevel,ntrials,nce,nrep), 'Color', [1 1 1]*0.5,'FontAngle','italic','FontSize',10);
            set(gca,'Box','off');
            axis square;

            % compute t-test and plot significance star if necessary
            pval = o.test_chance_level(Accuracy,chanceAccuracies);

            if pval<=0.05
                stars = repmat('*', 1, sum(pval < [0.05 0.01 0.001]));
                text(1, Accuracy+0.1, stars, 'FontSize', 18, 'HorizontalAlignment', 'center');
            end
            title({'Statistical comparison' 'with chance level accuracy'},'HorizontalAlignment','center');
           
            align([ax1 ax2],"Left","None")
            align([ax1 ax2],'none',"Distribute")
            ax1.Position(3:4)=0.3;
            ax2.Position(3:4)=0.3;
            ax2.Position(2)=0.15;


        end

        function [chanceAccuracies,ChanceAccuracy]=compute_chance_level_leave1out(o, C, kernel, gamma, degree)
            % compute chance level accuracy and distribution
            niter = o.params.niter;
            chanceAccuracies = zeros(niter, 1);
            Y = o.Y;
            X = o.X;
            o.msg(sprintf('Computing chance level (niter = %g',niter));
            s = 0;
            for i = 1:niter
                cleanline(s);
                s=fprintf('progress %g/%g',i,niter);
                % shuffle labels
                Yshuffled = Y(randperm(length(Y)));
                [chanceAccuracies(i), conf_mat, svm_model] = o.train_svm_leave1out(X,Yshuffled, C, kernel, gamma, degree);

            end
            ChanceAccuracy = mean(chanceAccuracies);

        end


        function [chanceAccuracies,chanceAccuracy]=compute_chance_level_pHoldOut(o, C, kernel, gamma, degree)

            % compute chance level accuracy and distribution
            niter = o.params.niter;
            chanceAccuracies = zeros(niter, 1);
            Y = o.Y;%#ok
            X = o.X;%#ok

            for i = 1:niter
                % shuffle labels
                Yshuffled = Y(randperm(length(Y)));%#ok
                [chanceAccuracies(i), conf_mat,svm_model] = train_svm_pHoldOut(X,Yshuffled, C, kernel, gamma, degree);

            end
            chanceAccuracy = mean(chanceAccuracies);

        end

        function msg(o,txt)

            % check txt validy => need a string
            while iscell(txt)
                txt=txt{1};
            end
            
            sz=size(txt);
            if sz(1)>1% several lines
                txt2 = [];
                for i = 1:sz(1)
                    txt2 = horzcat(txt2,' ' ,txt(i,:));
                end
                txt = txt2;
            end
            txt = {[datestr(now,'HH:MM:SS') ' : ' txt]};
            
            % width limit
            w = round(o.gui.msg.Position(3)/4);
            new_txt =vertcat(o.gui.msg.String,txt{1});
            n = cellfun(@(x) numel(x),new_txt);
            while any(n>w)
                i= find(n>w,1);
                new_txt = vertcat(new_txt(1:i-1),{new_txt{i}(1:w)},{new_txt{i}(w+1:end)},new_txt(i+1:end));
                n = cellfun(@(x) numel(x),new_txt);
            end
            % height limit
            End = size(new_txt,1);
            height_box = o.gui.msg.Position(4);
            maxNumLines = round(End-(height_box/11));
            o.gui.msg.String = new_txt(max(1,maxNumLines):end);


        end
    end
end
