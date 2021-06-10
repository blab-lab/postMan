function newMatrix = get_time_window_postMan(dataPath, params, trialType)

if nargin < 2 || isempty(params) 
    params = struct;
    params.startTimeMs = 0.15;
    params.endTimeMs = 0.3;
    params.measSel = 'diff1';
end

measSel = params.measSel;
%load matrix file
if strcmp(trialType, 'oneShot')
    load(fullfile(dataPath,'fmtMatrix_postUppostDownpostNo_merged.mat'));
elseif strcmp(trialType, 'compensation')
    load(fullfile(dataPath, 'fmtMatrix_shiftUpshiftDownnoShift_merged.mat'));
end

%set tstep
load(fullfile(dataPath,'dataVals.mat'),'dataVals');
goodtrials = find(~[dataVals.bExcl]); 
if ~contains(dataPath, 'cat')
    tstep = mean(diff(dataVals(goodtrials(1)).ftrack_taxis));
elseif contains(dataPath, 'cat')
    tstep = 0.004;
end

% set time windows
if params.startTimeMs == 0
    startTime = 1;
else
    startTime = floor(params.startTimeMs/tstep);
end
endTime = floor(params.endTimeMs/tstep);

if strcmp(trialType, 'oneShot')
    maxEndTime = min([size(fmtMatrix.(measSel).postUp,1) size(fmtMatrix.(measSel).postDown,1)]);
    endTime = min(endTime,maxEndTime);
    newMatrix.Up = (fmtMatrix.(measSel).postUp(startTime:endTime,:));
    newMatrix.Down = (fmtMatrix.(measSel).postDown(startTime:endTime,:));
elseif strcmp(trialType, 'compensation')
    maxEndTime = min([size(fmtMatrix.(measSel).shiftUp,1) size(fmtMatrix.(measSel).shiftDown, 1)]);
    endTime = min(endTime, maxEndTime);
    newMatrix.Up = (fmtMatrix.(measSel).shiftUp(startTime:endTime,:));
    newMatrix.Down = (fmtMatrix.(measSel).shiftDown(startTime:endTime, :));
end

