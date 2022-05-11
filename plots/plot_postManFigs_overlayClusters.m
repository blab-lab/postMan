%% PostMan Fig2 cluster overlay
colors.shiftUp = [0.2 0.6 0.8]; % blue
colors.shiftDown = [.8 0 0]; % red
colors.postUp = [0.2 0.6 0.8]; % blue
colors.postDown = [.8 0 0]; % red
colors.noShift = [0.5 0.5 0.5]; 
taxis = 0:.003:.25;
lw = 4;

acoustPath = get_acoustLoadPath('postMan');
exptPath = fileparts(acoustPath);

%% cluster-based permutation: compensation
load(fullfile(exptPath,'fmtMatrix_shiftUpshiftDownnoShift_merged_131s.mat'));
rfx_comp = rfx;
shiftUp = rfx_comp.diff1.shiftUp(1:length(taxis),:);
shiftDown = rfx_comp.diff1.shiftDown(1:length(taxis),:);
clustShiftDown = permutest(shiftDown,zeros(size(shiftDown)));
clustShiftBoth = permutest(shiftDown,shiftUp);
clustShiftUp = permutest(zeros(size(shiftUp)),shiftUp);

% plot significant clusters
clusters = clustShiftDown; y = -7;
for i=1:length(clusters), clust = clusters{i}; plot(taxis(clust), y*ones(1,length(clust)), 'Color', colors.shiftDown, 'LineWidth',lw); end
clusters = clustShiftBoth; y = -8;
for i=1:length(clusters), clust = clusters{i}; plot(taxis(clust), y*ones(1,length(clust)), 'Color', colors.noShift, 'LineWidth',lw); end
clusters = clustShiftUp; y = -9;
for i=1:length(clusters), clust = clusters{i}; plot(taxis(clust), y*ones(1,length(clust)), 'Color', colors.shiftUp, 'LineWidth',lw); end

%% cluster-based permuation: adaptation
load(fullfile(exptPath,'fmtMatrix_postUppostDownpostNo_merged_131s.mat'));
rfx_adapt = rfx;
postUp = rfx_adapt.diff1.postUp(1:length(taxis),:);
postDown = rfx_adapt.diff1.postDown(1:length(taxis),:);
clustPostUp = permutest(zeros(size(postUp)),postUp);
clustPostDown = permutest(postDown,zeros(size(postDown)));
clustPostBoth = permutest(postDown,postUp);

% plot significant clusters
clusters = clustPostDown; y = -7;
for i=1:length(clusters), clust = clusters{i}; plot(taxis(clust), y*ones(1,length(clust)), 'Color', colors.postDown, 'LineWidth',lw); end
clusters = clustPostBoth; y = -8;
for i=1:length(clusters), clust = clusters{i}; plot(taxis(clust), y*ones(1,length(clust)), 'Color', colors.noShift, 'LineWidth',lw); end
clusters = clustPostUp; y = -9;
for i=1:length(clusters), clust = clusters{i}; plot(taxis(clust), y*ones(1,length(clust)), 'Color', colors.postUp, 'LineWidth',lw); end
