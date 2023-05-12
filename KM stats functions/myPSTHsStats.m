function PSTHs_values=myPSTHsStats(allPSTHs_values,params)

ncells = size(allPSTHs_values,1);
ncond = size(allPSTHs_values,2);
nsound = size(allPSTHs_values,3);

i4post = params.i4post;
i4pre = params.i4pre;

IsModulatedPos = false(ncells,ncond,nsound);
RespMax = nan(ncells,ncond,nsound);
tic
sz=fprintf('starting par for loop');
ncases = ncells*ncond*nsound;
parfor ica = 1:ncases

    trials = allPSTHs_values{ica};
    if isempty(trials)
        continue;
    end
    [~, ~,~,IsModulatedPos(ica),~,ModSizeTemp,~,~,RespMaxTemp] = ...
        myIsModulated(trials,i4pre,i4post,params);

    RespMax(ica) = max(RespMaxTemp(:));
end
toc
cleanline(sz);

%% For each cell, choose best sound response
PSTHs_values = cell(ncells,ncond);
parfor ice = 1:ncells

   % Initialize variables to keep track of best sound response
    BEST_sound = 0;
    BEST_resp = -Inf;
    BEST_cond = nan;
    for isound = 1:nsound
        % Check if sound response is modulated
        if ~any(IsModulatedPos(ice, :, isound))
            continue;
        end
        
        % Compute modulation index for sound response
        [thisresp,bestcond] = max(RespMax(ice, :, isound),[],2);
        
        % Update best sound response if necessary
        if thisresp > BEST_resp
            BEST_sound = isound;
            BEST_cond = bestcond;
            BEST_resp = thisresp;
        end
    end
    
    % Save best sound response and its statistics
    if BEST_resp == -Inf
        continue;
    end
    PSTHs_values(ice,:) = allPSTHs_values(ice, :, BEST_sound);
 
end









end