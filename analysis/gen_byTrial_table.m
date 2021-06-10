function fulltable = gen_byTrial_table(dataPaths)

for dp = 1:length(dataPaths)
    dataPath = dataPaths{dp}
    %get appropriate time window of interest
    trialTypes = [{'oneShot'}, {'compensation'}];
%loop through to get data for both trial types
    for i = 1:length(trialTypes)
        trialType = trialTypes{i};
        load(fullfile(dataPath,'expt.mat'),'expt');
        load(fullfile(dataPath, 'ind_list.mat'), 'ind_list'); %ind list has trial numbers in same order as fmt_matrix file

        if strcmp(trialType, 'oneShot')
            params = make_params_postMan(0, 0.1);
        elseif strcmp(trialType, 'compensation')
            params = make_params_postMan(0.15, 0.25);
        end
        %% make table with by-trial means
        %create new matrix for correct trial types
        newMatrix = get_time_window_postMan(dataPath, params, trialType);

        % get average in time window
        newTable.(trialType).upMean = nanmean(newMatrix.Up, 1);
        newTable.(trialType).downMean = nanmean(newMatrix.Down, 1);
        %create new structure to house corresponding trial means and their
        %indices
        if strcmp(trialType, 'oneShot')
            newTable.(trialType).upInds = ind_list.postUp;
            newTable.(trialType).downInds = ind_list.postDown;
        elseif strcmp(trialType, 'compensation')
            newTable.(trialType).upInds = ind_list.shiftUp;
            newTable.(trialType).downInds = ind_list.shiftDown;
        end
    end
    %% get info for exp / snum/ group
    %get exp name
    if strcmp(expt.name, 'default') %account for expt formatting
            exp = 'reachAndSpeech';
        elseif strcmp(expt.name, 'random')
            exp = 'cereb';
        else
            exp = expt.name;
    end
    %get group for noisy fb
    if isfield(expt, 'group')
            group = expt.group;
        else
            group = [];
    end

    %add pp num
    if isfield(expt, 'snum')
        snum = (expt.snum);
        if strcmp(exp, 'fmtAlt')
            snum = sprintf('s%d', snum);
        end
    elseif isfield(expt, 'subject')
        snum = sprintf('c%d', (expt.subject.nr));
    end
    %get group
    if strcmp(exp, 'noisyfb') || strcmp(exp, 'reachAndSpeech')
        upshiftMag = 125;
        downshiftMag = -125;
    else
        upshiftMag = expt.shifts.mels{1}(1);
        downshiftMag = expt.shifts.mels{2}(1);
    end
%% assemble table
    %one shot table & exp info
     upTable = table(newTable.oneShot.upMean.', newTable.oneShot.upInds.');
     upTable.cond(:,1) = {'up'};
     upTable.shiftMag(:, 1) = upshiftMag;
     downTable = table(newTable.oneShot.downMean.', newTable.oneShot.downInds.');
     downTable.cond(:,1) = {'down'};
     downTable.shiftMag(:, 1) = downshiftMag;
     OSTable = [upTable; downTable];
     OSTable.exp(:,1) = {(exp)};
     OSTable.snum(:,1) = {(snum)};
     OSTable.group(:,1) = {(group)};
     OSTable.Properties.VariableNames = {'oneShot', 'OSTrial', 'cond', 'shiftMag', 'exp', 'participant', 'group'};
     OSTable.compTrial = OSTable.OSTrial -1; %add in corresponding compensation trial numbers to join tables by
     
    %for cat data - remove trials that don't have corresponding comp data
     if contains(dataPath, 'cat')
        load(fullfile(dataPath, 'dataVals.mat'), 'dataVals');
        allToken = (extractfield(dataVals, 'token'));
        missTrials2 = setdiff(1:max(allToken), allToken) + 1;
        rm = intersect(OSTable.OSTrial, missTrials2); %find trials that occur after missing comp trial
        rmIndex = find(ismember(OSTable.OSTrial, rm));
        OSTable([rmIndex.'], :) = [];
     end
     %compensation data table
     cUpTable = table(newTable.compensation.upMean.', newTable.compensation.upInds.');
     cDownTable = table(newTable.compensation.downMean.', newTable.compensation.downInds.');
     compTable = [cUpTable; cDownTable];
     compTable.Properties.VariableNames = {'compensation', 'compTrial'};
%join tables by comptrial number
     spfulltable = join(OSTable, compTable);
%join all participant data together
 if dp == 1
     fulltable = spfulltable;
 else 
     fulltable = [fulltable; spfulltable];
 end
end
 