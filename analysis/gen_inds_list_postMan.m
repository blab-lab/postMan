function [] = gen_inds_list_postMan(dataPath);
%Function to extract the trial numbers to assign to fmtMatrix_merged files.
%The generated list corresponds to the columns in the fmtMatrix file

load(fullfile(dataPath,'expt.mat'),'expt');
load(fullfile(dataPath, 'dataVals.mat'), 'dataVals');
trialTypes = [{'oneShot'}, {'compensation'}];

if contains(dataPath, 'fmtAlt') %fmtAlt is labeled differently, but moving towards 'AE' is equivalent to moving up, and 'I' is in the opposite, downward direction
        noShift = find(contains(expt.conds, 'noshift'));
        upShift = find(contains(expt.conds, 'shiftAE'));
        downShift = find(contains(expt.conds, 'shiftI'));
    else %for all other exp which are labeled using up/down/no 
        noShift = find(contains(expt.conds,'noshift', 'IgnoreCase', true)|(contains(expt.conds, 'nopert')));
        upShift = find(contains(expt.conds, 'up', 'IgnoreCase', true));
        downShift = find(contains(expt.conds, 'down', 'IgnoreCase', true));
end
%first need to regenerate indShift - this code is copied from the
%gen_fmtMatrix code. However, I didn't permanently save the index info for postMan
%trials in the expt.mat so need to repeate this
for t = 1:length(trialTypes)
    trialType = trialTypes{t};
    
    if strcmp(trialType, 'oneShot') %for calculating oneShot fmtMatrix
    %add new conditions to expt file
    expt.newConds = {'postNo', 'postUp', 'postDown'};

    for ind = 2:length(expt.allConds) %we know that first trial will not be eligible (start on second)
       if (expt.allConds(ind)==noShift && expt.allConds(ind-1) == noShift)
            expt.allNewCond(ind) = 1; %all no shift / no shift trials
       elseif (expt.allConds(ind)==noShift && expt.allConds(ind-1)== upShift)
            expt.allNewCond(ind) = 2; %all up shift / no shift trials
       elseif (expt.allConds(ind)==noShift && expt.allConds(ind-1) == downShift)
            expt.allNewCond(ind) = 3; %all down shift / no shift trials
       else
            expt.allNewCond(ind) = 0; %all other trials (will not be used in analysis)
       end
    end

        %get indices for expt.inds
        expt.inds.conds.postNo = find(expt.allNewCond == 1);
        expt.inds.conds.postUp = find(expt.allNewCond == 2);
        expt.inds.conds.postDown = find(expt.allNewCond == 3);

        %set conditions
        conds = {'postUp','postDown'};
        basecond = 'postNo';

    elseif strcmp(trialType, 'compensation') %start for calc comp matrix
        conds = {'shiftUp', 'shiftDown'};
        basecond = 'noShift';

    end

    nconds = length(conds);
    words = expt.words(~strcmp(expt.words, '***')); %excludes non-words that were included in expt.words field for 'cat' study
    nwords = length(words);

    %find indices for intersecting words & conditions
    for c=1:nconds
        cond = conds{c};
        for w=1:nwords
            word = words{w};
            shiftnum = (c-1)*nwords + w;

            indShift(shiftnum).name = sprintf('%s%s',cond,word);
            indShift(shiftnum).inds = intersect(expt.inds.conds.(cond),expt.inds.words.(word));
             if strcmp(trialType, 'oneShot') && contains(dataPath, 'cat') %need to remove trials that come after *** trials in cat
                 rmTrials = (find((expt.allWords == 9) | (expt.allWords == 10)) +1);
                 indShift(shiftnum).inds = setdiff(indShift(shiftnum).inds, rmTrials);
            end
        end
    end

    %convert to ordered list, in which the trial number corresponds to each
    %column in the fmt_Matrix ___ merged file
    if strcmp(trialType, 'oneShot')
        for i = 1:length(words)
            if i == 1 %the first half will be for up
                ind_list.postUp = indShift(i).inds;
            else
                ind_list.postUp = [ind_list.postUp indShift(i).inds];
            end
            z = i +length(words); % the second half of indShift is for down
            if z == length(words) + 1
                ind_list.postDown = indShift(z).inds;
            else
                ind_list.postDown = [ind_list.postDown indShift(z).inds];
            end
        end
    elseif strcmp(trialType, 'compensation')
         for i = 1:length(words)
            if i == 1 %the first half will be for up
                ind_list.shiftUp = indShift(i).inds;
            else
                ind_list.shiftUp = [ind_list.shiftUp indShift(i).inds];
            end
            z = i +length(words); % the second half of indShift is for down
            if z == length(words) + 1
                ind_list.shiftDown = indShift(z).inds;
            else
                ind_list.shiftDown = [ind_list.shiftDown indShift(z).inds];
            end
         end
    end
end
    %remove trials that occur after bad trials
    postbadtrials = [dataVals(find([dataVals.bExcl])).token] +1;
    ind_list.postUp = setdiff(ind_list.postUp, postbadtrials, 'stable');
    ind_list.postDown = setdiff(ind_list.postDown, postbadtrials, 'stable');
    %remove bad trials 
    badtrials = [dataVals(find([dataVals.bExcl])).token];
    ind_list.shiftUp = setdiff(ind_list.shiftUp, badtrials, 'stable');
    ind_list.shiftDown = setdiff(ind_list.shiftDown, badtrials, 'stable');
    ind_list.postDown = setdiff(ind_list.postDown, badtrials, 'stable');
    ind_list.postUp = setdiff(ind_list.postUp, badtrials, 'stable');
    %remove trials inds that are not in 'cat' dataVals (there are some not
    %included in the dataVals file?
    if contains(dataPath, 'cat')
        allToken = (extractfield(dataVals, 'token'));
        missTrials= setdiff(1:max(allToken), allToken); %create list of missing trials
        ind_list.shiftUp = setdiff(ind_list.shiftUp, missTrials, 'stable');
        ind_list.shiftDown = setdiff(ind_list.shiftDown, missTrials, 'stable');
        ind_list.postDown = setdiff(ind_list.postDown, missTrials, 'stable');
        ind_list.postUp = setdiff(ind_list.postUp, missTrials, 'stable');
    end
    save(fullfile(dataPath, 'ind_list.mat'), 'ind_list')
end