function [savefile] = gen_fmtMatrix_postMan(dataPath,dataValsStr,bSaveCheck, trialType)

if nargin < 1 || isempty(dataPath), dataPath = cd; end
if nargin < 2 || isempty(dataValsStr), dataValsStr = 'dataVals.mat'; end
if nargin < 3 || isempty(bSaveCheck), bSaveCheck = 1; end
if nargin < 4 || isempty(trialType), trialType = 'oneShot'; end

load(fullfile(dataPath,dataValsStr));
load(fullfile(dataPath,'expt.mat'),'expt');

%add shift information to expt.mat
%if ~isfield(expt,'shifts')
%    expt.shifts.mels{1} = [125 0];
%    expt.shifts.mels{2} = [-125 0];
%end
%save(fullfile(dataPath,'expt.mat'),'expt');

%find condition based on experiment type
% find assigned condition numbers for study
if contains(dataPath, 'fmtAlt')
    upShift = find(contains(expt.conds, 'shiftAE'));
    downShift = find(contains(expt.conds, 'shiftI'));
else %for all other exp
    upShift = find(contains(expt.conds, 'up', 'IgnoreCase', true));
    downShift = find(contains(expt.conds, 'down', 'IgnoreCase', true));
end
%find no shift / no pert condition
noShift = find(contains(expt.conds,'noshift', 'IgnoreCase', true)|(contains(expt.conds, 'nopert'))); %addition of nopert for cereb formatting

%% Set conditions based on trial type

if strcmp(trialType, 'oneShot') 
%add new conditions to expt file
expt.newConds = {'postNo', 'postUp', 'postDown'};
%find indices for each condition
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

    %save indices to expt.inds
    expt.inds.conds.postNo = find(expt.allNewCond == 1);
    expt.inds.conds.postUp = find(expt.allNewCond == 2);
    expt.inds.conds.postDown = find(expt.allNewCond == 3);

    %set conditions
    conds = {'postUp','postDown'};
    basecond = 'postNo';

% Set colors
    colors.postUp = [.2 .6 .8];
    colors.postDown = [.8 0 0];
    colors.postNo = [.5 .5 .5];

elseif strcmp(trialType, 'compensation') %start for calc comp matrix
    conds = {'shiftUp', 'shiftDown'};
    basecond = 'noShift';

    % Set colors
    colors.shiftUp = [.2 .6 .8];
    colors.shiftDown = [.8 0 0];
    colors.noShift = [.5 .5 .5];
end

nconds = length(conds);
words = expt.words(~strcmp(expt.words, '***'));
nwords = length(words);
%% find indices for each word/condition combination
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
        indShift(shiftnum).shiftind = c;
        indShift(shiftnum).linecolor = colors.(cond);
        
        indBase(shiftnum).name = sprintf('%s%s',basecond,word);
        indBase(shiftnum).inds = intersect(expt.inds.conds.(basecond),expt.inds.words.(word));
        indBase(shiftnum).linecolor = colors.(basecond);
    end
end
%% remove bad trials
if isfield(dataVals, 'bExcl')
if strcmp(trialType, 'oneShot')
%remove trials that came after bad trials
    postbadtrials = [dataVals(find([dataVals.bExcl])).token] +1;
    for i=1:length(indShift)
        indShift(i).inds = setdiff(indShift(i).inds,postbadtrials);
        indBase(i).inds = setdiff(indBase(i).inds,postbadtrials);
    end
elseif strcmp(trialType, 'compensation') %remove bad trials
    badtrials = [dataVals(find([dataVals.bExcl])).token];
    for i=1:length(indShift)
        indShift(i).inds = setdiff(indShift(i).inds,badtrials);
        indBase(i).inds = setdiff(indBase(i).inds,badtrials);  
    end
end
end

%% write out fmt_matrix files
%save files (separated matrices)

savefile = gen_fmtMatrixByCond_postMan(dataPath,indBase,indShift,dataValsStr,trialType, 1,1,bSaveCheck);

%get fieldnames for merge
load(fullfile(dataPath, savefile));
fields = fieldnames(fmtMatrix.rawf1);
base = fields(contains(fields, 'No', 'IgnoreCase', true));
downs = fields(contains(fields, 'Down'));
ups = fields(contains(fields, 'Up'));

%merge matrices
merge_fmtMatrices_postMan(dataPath,savefile,{...
            {ups{1:end}},
            {downs{1:end}},
            {base{1:end}}},...
            {conds{1} conds{2} basecond},0);

