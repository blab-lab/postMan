function [h] = plot_postManFigs(figs2plot)

colors.shiftUp = [0.2 0.6 0.8]; % blue
colors.shiftDown = [.8 0 0]; % red
colors.postUp = [0.2 0.6 0.8]; % blue
colors.postDown = [.8 0 0]; % red
colors.noShift = [0.5 0.5 0.5]; 

fullPageWidth = 20; %cm
%% Figure 1: Experiment Design
[lia,locb] = ismember(1,figs2plot);
if lia
    %Fig 1A
    sid = 'sp068';
    dataPath = get_acoustLoadPath('noisyfb',sid,'normal', 'alt');
    load(fullfile(dataPath, 'expt.mat'));
    
     F1shiftMag = expt.shiftMags(102:142);
   %list shift inds
   shifts = struct;
   shifts.up = [];
   shifts.down = [];
   shifts.postUp = [];
   shifts.postDown = [];
   shifts.no = [];
   for i = 1:length(F1shiftMag)
       fsm = F1shiftMag(i);
       if i > 1
           psm = F1shiftMag(i-1);
       elseif i == 1
           psm = 0;
       end
        if fsm > 0 
           shifts.up = [shifts.up, i];
        elseif fsm < 0 
            shifts.down = [shifts.down, i];
        elseif fsm == 0 && psm > 0
            shifts.postUp = [shifts.postUp, i];
        elseif fsm == 0 && psm < 0 
            shifts.postDown = [shifts.postDown, i];
        elseif fsm == 0 && psm == 0 
            shifts.no = [shifts.no, i];  
        end
   end      
     
markerSize = 5;
stem(shifts.up, F1shiftMag(shifts.up), 'MarkerEdgeColor',colors.shiftUp,'MarkerSize',markerSize)
hold on
stem(shifts.down, F1shiftMag(shifts.down), 'MarkerEdgeColor',colors.shiftDown,'MarkerSize',markerSize)
stem(shifts.no, F1shiftMag(shifts.no), 'MarkerEdgeColor',colors.noShift,'MarkerFaceColor',colors.noShift,'Color',colors.noShift,'MarkerSize',markerSize)
stem(shifts.postUp, F1shiftMag(shifts.postUp), 'MarkerEdgeColor', colors.shiftUp, 'MarkerFaceColor',colors.shiftUp,'Color',colors.shiftUp, 'MarkerSize', markerSize)
stem(shifts.postDown, F1shiftMag(shifts.postDown), 'MarkerEdgeColor', colors.shiftDown, 'MarkerFaceColor',colors.shiftDown,'Color',colors.shiftDown,'MarkerSize', markerSize)
ylim([-150 150]);
xlim([0 40]);
set(gca,'YTick',-125:125:125)
xlabel('Trial sequence')
ylabel({'F1 perturbation' '(mels)'})
set(gca,'TickLength',[0.005 0.025]);
lgd = legend;
lgd.String = {'shift up', 'shift down', 'no shift', 'post up', 'post down'};
 pbaspect([1 0.4 1])
makeFig4Printing
hold off

%Fig 1B
load(fullfile(dataPath,'data.mat'),'data');
    trials2plot = [196];
    plotData = data(trials2plot);
    plotData(1).fmts(500:576) = 0;
    plotData(1).sfmts(500:576) = 0;
    params.fmtsColor = [1 0.87 0];
    params.fmtsLineWidth = 1.5;
    params.sfmtsColor = colors.shiftUp;
    params.sfmtsLineWidth = 1.5;
    params.ylim =3500;
    params.figpos = [35 500 1000 50];
    
    params.thresh_gray = .65;
    params.max_gray = .75;
    
    h1(1) = plot_audapterF1(plotData(1),params);
    set(gca,'YTick',[1000 2000 3000]); % 1000, 1500, 2000 in mels
    trials2plot = [102];
    plotData = data(trials2plot);
    plotData(1).fmts(330:340) = 0;
    plotData(1).sfmts(330:340) = 0;
    plotData(1).fmts(460:532) = 0;
    plotData(1).sfmts(460:532) = 0;
    params.sfmtsColor = colors.shiftDown;
    h1(2) = plot_audapterF1(plotData(1),params);
    set(gca,'YTick',[1000 2000 3000]);
    makeFig4Screen;
  
end

%% Figure 2. Formant tracks & distributions
[lia,locb] = ismember(2,figs2plot);
if lia
%% Figure 2A
%% 1. plot cross sub compensation
    fig_position = [100 100 500 500]; % position for figure
    h2(1)= plot_fmtMatrix_crossSubj('\\wcs-cifs\wc\smng\experiments\postMan', 'fmtMatrix_shiftUpshiftDownnoShift_merged_131s', 'diff1', [], [], {'rfx'});
    title(['Compensation'])
    ylabel('Normalized F1 (mels)')
    p1 = [0.15 0.15 0.25 0.25];
    p2 = [-10 10 10 -10];
    patch(p1, p2, [0.83 0.83 0.83], 'LineStyle', 'none')
    set(gca, 'Position', fig_position, 'XLim', [0 0.25],'YLim', [-10 10],'children',flipud(get(gca,'children')), 'Layer', 'top')
    lgd = legend;
    lgd.String = {'Shift Up', 'Shift Down'};
    makeFig4Printing;
%% 2. Plot cross Subject oneShot
    h2(2) = plot_fmtMatrix_crossSubj('\\wcs-cifs\wc\smng\experiments\postMan', 'fmtMatrix_postUppostDownpostNo_merged_131s', 'diff1', [], [], 'rfx', colors);
    title(['One-Shot Adaptation'])
    ylabel('')
    p1 = [0 0 0.1 0.1];
    p2 = [-10 10 10 -10];
    fill(p1, p2, [0.83 0.83 0.83], 'LineStyle', 'none')
    set(gca, 'Position', fig_position, 'XLim', [0 0.25], 'YLim', [-10 10],'children',flipud(get(gca,'children')), 'Layer', 'top')
    lgd = legend;
    lgd.String = {'Post Shift Up', 'Post Shift Down'};
    makeFig4Printing; 
    
%% Figure 2b. One-Shot/Compensation distributions
    %read in data tables
    oneshotTable = readtable('\\wcs-cifs\wc\smng\experiments\postMan\oneShot_postMan_final.csv');%('\\wcs-cifs\wc\smng\experiments\postMan\oneShot_fulltable_postMan.csv');
    compTable = readtable('\\wcs-cifs\wc\smng\experiments\postMan\compensation_postMan_final.csv');%('\\wcs-cifs\wc\smng\experiments\postMan\compensation_fulltable_postMan.csv');

    %remove outlier?
    oneshotTable = oneshotTable(~strcmp(oneshotTable.participant, 'HOC8'), :);
    oneshotTable = oneshotTable(~strcmp(oneshotTable.participant, 'OA14'), :);
    %filter by condition 
    upOS = oneshotTable(strcmp(oneshotTable.cond, 'up'), :);
    downOS = oneshotTable(strcmp(oneshotTable.cond, 'down'), :);

%% 1. oneshot raincloud plot
    fig_position = [200 200 600 350]; % position for figure
    h2(4) = figure('Position', fig_position);
    set(gca, 'XLim', [-35 35], 'YLim', [-0.08 0.08], 'YTick', [], 'YTickLabel', []);
    hold on
    r1 = raincloud_plot(upOS.oneShot, 'box_on', 1, 'color',  colors.shiftUp, 'alpha', 0.5,...
         'box_dodge', 1, 'box_dodge_amount', .3, 'dot_dodge_amount', .3,...
         'box_col_match', 0, 'line_width', 1, 'lwr_bnd', 1.2);
    title(['One-Shot Adaptation']);
    xlabel('');
    box off
    r2 = raincloud_plot(downOS.oneShot, 'box_on', 1, 'color', colors.shiftDown, 'alpha', 0.5,...
         'box_dodge', 1, 'box_dodge_amount', .8, 'dot_dodge_amount', .8,...
         'box_col_match', 0, 'line_width', 1, 'lwr_bnd', 1.2);
    box off
    plot([0 0], [-0.2 0.07], 'Color', [0 0 0], 'LineStyle', '--') 
    lgd = legend([r1{1} r2{1}]);
    lgd.String = {'postUp', 'postDown', '0'};
    view([90 -90])
    pbaspect([1 0.3 1])
    makeFig4Printing;
    hold off

%% 2. rain cloud plot for compensation
    
    compTable = compTable(~strcmp(compTable.participant, 'OA14'), :);

    %separate conditions
    upComp = compTable(strcmp(compTable.cond, 'up'), :);
    downComp = compTable(strcmp(compTable.cond, 'down'), :);

    %remove outlier
    %upComp = upComp(~strcmp(upComp.participant, '0'), :);
    %downComp = downComp(~strcmp(downComp.participant, '0'), :);

    %make raincloud plot (horizontal, overlapping)
    fig_position = [200 200 600 350]; % position for figure
    h2(3) = figure('Position', fig_position);
    set(gca, 'XLim', [-35 35], 'YLim', [-0.035 0.08], 'YTick', [], 'YTickLabel', []);
    hold on
    r1 = raincloud_plot(upComp.compensation, 'box_on', 1, 'color', colors.shiftUp, 'alpha', 0.5,...
         'box_dodge', 1, 'box_dodge_amount', .3, 'dot_dodge_amount', .3,...
         'box_col_match', 0, 'line_width', 1, 'lwr_bnd', 1.2);
    title(['Compensation']);
    xlabel('Normalized F1 (mels)');
    box off
    r2 = raincloud_plot(downComp.compensation, 'box_on', 1, 'color', colors.shiftDown, 'alpha', 0.5,...
         'box_dodge', 1, 'box_dodge_amount', .8, 'dot_dodge_amount', .8,...
         'box_col_match', 0, 'line_width', 1, 'lwr_bnd', 1.2);
    box off
    plot([0 0], [-0.07 0.085], 'Color', [0 0 0], 'LineStyle', '--') 
    lgd = legend([r1{1} r2{1}]);
    lgd.String = {'shiftUp', 'shiftDown', '0'};
    view([90 -90])
    pbaspect([1 0.3 1])
    makeFig4Printing;
    hold off

%% BOTH
   figpos_cm = [0 0  fullPageWidth fullPageWidth*.4];
   h(locb) = figure('Units','centimeters','Position',figpos_cm);
   copy_fig2subplot(h2, h(locb), 1, 4, [], 1)
end
%% Figure 3. By-trial correlations
[lia,locb] = ismember(3,figs2plot);

if lia
%read in full table
all_averages = readtable('\\wcs-cifs\wc\smng\experiments\postMan\allParticipants_final.csv');

%save outliers for plot
%outliers = readtable('\\wcs-cifs\wc\smng\experiments\postMan\postMan_outliers.csv');

%flip the signs for 'up' conditions
for i = 1:height(all_averages)
    if strcmp(all_averages.cond{i}, 'up')
        all_averages.oneShot(i) = all_averages.oneShot(i) * -1;
        all_averages.compensation(i) = all_averages.compensation(i) * -1;
    end
end

%for o = 1:height(outliers)
%    if strcmp(outliers.cond{o}, 'up')
 %       outliers.oneShot(o) = outliers.oneShot(o) * -1;
 %       outliers.compensation(o) = outliers.compensation(o) * -1;
 %   end
%end

%plot correlation
figpos_cm = [0 0  fullPageWidth/2 fullPageWidth*.4];
h(locb) = figure('Units','centimeters','Position',figpos_cm);
scatter(all_averages.compensation, all_averages.oneShot, 10, all_averages.shiftMag, 'filled', 'MarkerEdgeColor', 'none')
hold on
%scatter(outliers.compensation, outliers.oneShot, 'x', 'MarkerEdgeColor', [0.6 0.6 0.6], 'MarkerFaceColor', [0.6 0.6 0.6])
xlabel('Compensation Response')
ylabel('One-Shot Adaptation Response')
cb = colorbar('YTick', [50:25:160]);
cb.Label.String = 'F1 Shift Magnitude (mels)'
y = yline(0,'k--')
y.Color = [0.5 0.5 0.5]
x = xline(0, 'k--')
x.Color = [0.5 0.5 0.5]
set(gca, 'XLim', [-40 40], 'YLim', [-40 40], 'xtick', -40:20:40, 'ytick', -40:20:40);
hline = refline(0.14, 0.93)
hline.Color = [0.2 0.2 0.2];
%pbaspect([1 1.5 1])
axis square
makeFig4Printing;

end
%[r, p, ~] = plotcorr(all_averages.compensation, all_averages.oneShot);
%% plot outliers
%s00 in fmtAlt (compensation)
 %plot_fmtMatrix(dataPath,'fmtMatrix_shiftUpshiftDownnoShift_merged.mat', 'diff1')

 
%OA14 in reachAndSpeech
 %plot_fmtMatrix(dataPath,'fmtMatrix_postUppostDownpostNo_merged.mat', 'diff1')
%% ttests

%[~, pUp] = ttest(upOS.oneShot)
%[~, pDown] = ttest(downOS.oneShot)
end