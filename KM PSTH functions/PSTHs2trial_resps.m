function         [trial_resps_xCond,trial_vals_xCond] = PSTHs2trial_resps(PSTHs)
% trial_resps = PSTHs2trial_resps(PSTHs)
t = PSTHs.time;

i4resp = t>=0 &  t<1.5;
i4bsl = t<0;
trial_vals_xCond=mymax(PSTHs.data(:,i4resp,:,PSTHs.ISRESP_ROI),2);
bsl_vals = mymean(PSTHs.data(:,i4bsl,:,PSTHs.ISRESP_ROI),2);
trial_resps_xCond=trial_vals_xCond-bsl_vals;

%trials_resps_xCond(:,:,:,1)