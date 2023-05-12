function [IsModulated, IsModulatedAllPeriod,ModDirection,IsModulatedPos,IsModulatedNeg,ModSize,params,pval,RespMax]...
    =myIsModulated(Signal,i4pre,i4post,varargin)
%% myIsModulated(PSTH,ipre,ipost,params)


params = checkStatsParams(varargin);

npost = size(i4post,1);
IsModulatedAllPeriod = nan(1,npost);% 1 = 1 condition for now
ModDirection  = nan(1,npost);
ModSize = nan(1,npost);
RespMax = nan(1,npost);
pval = nan(1,npost);
AlphaCorr = params.Alpha/npost;
params.AlphaCorr = AlphaCorr;
PRE = mymean(Signal(:,i4pre),2);
x = 1:numel(i4pre);
PREme = mymean(PRE);

for ipost = 1:npost

    thoseInd = i4post(ipost,:);
    POST = mymean(Signal(:,thoseInd),2);

    %permutationTest in the future
    
    %[pval, observeddifference, effectsize] = permutationTest(PRE, POST, npermutations);
    pval(ipost) = signrank(PRE,POST);%figure; boxplot([PRE,POST])

    IsModulatedAllPeriod(1,ipost)=pval(ipost)<AlphaCorr;
    ModSize(1,ipost)= mymean(POST)-PREme;% plot(Signal');hold on;plot(Signal(:,i4pre)','-k');plot(x(i4post(3,:)),Signal(:,i4post(3,:))','-b')
    RespMax(1,ipost)= mymax(mymean(Signal(:,thoseInd),1))-PREme;
    ModDirection(1,ipost)= sign(ModSize(1,ipost));
end

IsDiffEnough = RespMax>params.threshold_nSTD ;
IsModulated =  any(   IsModulatedAllPeriod    &  IsDiffEnough ,2);
IsModulatedPos = any(   IsModulatedAllPeriod    &  ModDirection>0 &  IsDiffEnough ,2);
IsModulatedNeg = any(   IsModulatedAllPeriod    &  ModDirection<0  &  IsDiffEnough ,2);

% if 0
% if IsModulated
% [fig,AX,pl]=myPlotData(Signal);
% title(AX(1),num2str(IsModulated));
% keyboard
% end
% end
end



%% checkStatsParams
function params = checkStatsParams(params)

if isempty(params)
    params = struct();
else
    params = params{1};
end

% define default params
default_params.signrankTest = 1;
default_params.permutationTest = 0;
default_params.npermutation = 100;
default_params.Alpha = 0.025;

% check params

% update params
fields_params = fieldnames(params);
dfields_params = fieldnames(default_params);
fields_params_low = lower(fields_params);
dfields_params_low = lower(dfields_params);


for ipa = 1:numel(dfields_params)
    p = dfields_params{ipa};
    p_low = dfields_params_low{ipa};
    if ~ismember(p_low,fields_params_low)
        params.(p) = default_params.(p);
    end

end


end