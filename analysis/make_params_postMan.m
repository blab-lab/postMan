function params = make_params_postMan(startMs, endMs, measSel, byTrialMeans)

params = struct;
if nargin < 1 || isempty(startMs), startMs = 0.15; end
if nargin < 2 || isempty(endMs), endMs = 0.3; end
if nargin < 3 || isempty(measSel), measSel = 'diff1'; end
if nargin < 4 || isempty(byTrialMeans), byTrialMeans = 0; end
% 0 = create an average response trial first, then average within a window; 1 = average within window for each trial, then average across trials

%make params
params.startTimeMs = startMs;
params.endTimeMs = endMs;
params.measSel = measSel;
params.byTrialMeans = byTrialMeans;
params.avgType = 'mean';


