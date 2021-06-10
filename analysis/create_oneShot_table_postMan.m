function [meanTable] = create_oneShot_table_postMan(trialMeansUp, trialMeansDown, i, nSubs, params, meanTable, expt)
%function to calculate the mean one-shot or compensation response and store
%value with participant and experiment data in a table

%keep track of table cycles
upNum = (i * 2) - 1;
downNum = i * 2;
nums = [upNum, downNum];

%load mean values in to table
meanTable(upNum).adjustment = nanmean(trialMeansUp);
meanTable(downNum).adjustment = nanmean(trialMeansDown);

%add cond
meanTable(upNum).cond = 'up';
meanTable(downNum).cond = 'down';
%add pp num - fixes inconsistencies across studies
if isfield(expt, 'snum')
    if iscell(expt.snum)
        meanTable(upNum).participant = expt.snum;
        meanTable(downNum).participant = expt.snum;
    elseif ~iscell(expt.snum)
        meanTable(upNum).participant = {expt.snum};
        meanTable(downNum).participant = {expt.snum};
    end
elseif isfield(expt, 'subject')
    meanTable(upNum).participant = {expt.subject.nr};
    meanTable(downNum).participant = {expt.subject.nr};
end

%add exp name / groups - fix inconsistencies across studies
%add group name
if strcmp(expt.name, 'default')
        exp = 'reachAndSpeech';
    else
        exp = expt.name;
end
if isfield(expt, 'group')
        group = expt.group;
    else
        group = [];
end
% add to mean table entries
meanTable(upNum).exp = exp;
meanTable(downNum).exp = exp;

if strcmp(exp, 'noisyfb') || strcmp(exp, 'reachAndSpeech')
    meanTable(upNum).shiftMag = 125;
    meanTable(downNum).shiftMag = -125;
else
    meanTable(upNum).shiftMag = expt.shifts.mels{1}(1);
    meanTable(downNum).shiftMag = expt.shifts.mels{2}(1);
end

if ~isempty(group)
    meanTable(upNum).group = group;
    meanTable(downNum).group = group;
else
    meanTable(upNum).group = 'na';
    meanTable(downNum).group = 'na';
end

if i == nSubs
    %convert to table
    meanTable = struct2table(meanTable);
end
end