function [meanTable, errs] = get_responses_by_participant_postMan(dataPaths, params, trialType)
%Get oneshot learning means

nSubs = length(dataPaths);
meanTable = struct;
%compStd = struct;
%sigComp = struct;
errs = struct;

for i = 1:nSubs
   %get appropriate time window of interest
    newMatrix = get_time_window_postMan(dataPaths{i}, params, trialType);
    load(fullfile(dataPaths{i},'expt.mat'),'expt');
        
    % get average compensation in time window
    if params.byTrialMeans
        trialMeansUp = nanmean(newMatrix.Up, 1);
        trialMeansDown = nanmean(newMatrix.Down, 1);
    else 
        trialMeansUp = nanmean(newMatrix.Up, 2);
        trialMeansDown = nanmean(newMatrix.Down, 2);
    end 
     meanTable = create_oneShot_table_postMan(trialMeansUp, trialMeansDown, i, nSubs, params, meanTable, expt);      
end
end
 