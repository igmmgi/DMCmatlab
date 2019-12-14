function  res = flankerTask1(makePlots)
% res = flankerTask1([makePlots])
%
% Produces results summary of a standard Flanker Task for compatible and
%   incompatible trials including CAF and rt distributions.

if nargin == 0
  makePlots = false;
end

% read data from flankerTask1.txt into MATLAB table
% NB. must be better way of doing some of this! MATLAB table datatype seems
%   limited compated to R with dplyr!
dat = readtable('flankerTask1.txt');

% define outliers
dat.Outlier = dat.RT < 200 | dat.RT > 1200;

% aggregate data across trials
varNames = {'SNo', 'Comp', 'nTotal', 'nCorr', 'nErr', 'nOut', 'rtCorr', 'sdCorr', 'perErr','rtErr', 'sdErr'};
datAggVP = array2table(nan(0, 11), 'VariableNames', varNames);

for vp = transpose(unique(dat.VP))
  for comp = {'comp', 'incomp'}
    
    datVP  = dat(dat.VP == vp & strcmp(dat.Comp, comp), :);
    nTotal = height(datVP);
    nCorr  = sum(datVP.Error == 0);
    nErr   = sum(datVP.Error == 1);
    nOut   = sum(datVP.Outlier == 1);
    
    rtCorr   = mean(datVP.RT(datVP.Error == 0 & datVP.Outlier == 0));
    sdRtCorr = std(datVP.RT(datVP.Error == 0  & datVP.Outlier == 0));
    
    perErr  = (nErr/nTotal)*100;
    rtErr   = mean(datVP.RT(datVP.Error == 1 & datVP.Outlier == 0));
    sdRtErr = std(datVP.RT(datVP.Error == 1 & datVP.Outlier == 0));
    
    % data table
    datAggVP = [datAggVP; cell2table({vp,comp,nTotal,nCorr,nErr,nOut,rtCorr,sdRtCorr,perErr,rtErr,sdRtErr}, 'VariableNames', varNames); ];
    
  end
end

% aggregate data across vps
varNames = {'Comp','nTotal', 'nCorr', 'nErr', 'nOut', 'rtCorr', 'sdRtCorr', 'seRtCorr', 'rtErr', 'sdRtErr', 'seRtErr', 'perErr', 'sdPerErr', 'sePerErr'};
datAgg   = array2table(nan(0, 14), 'VariableNames', varNames);
for comp = {'comp', 'incomp'}
  
  datVP    = datAggVP(strcmp(datAggVP.Comp, comp), :);
  nTotal   = height(datVP);
  nCorr    = sum(datVP.nCorr);
  nErr     = sum(datVP.nErr);
  nOut     = sum(datVP.nOut);
  
  rtCorr   = nanmean(datVP.rtCorr);
  sdRtCorr = nanstd(datVP.rtCorr);
  seRtCorr = sdRtCorr/sqrt(nTotal);
  
  rtErr   = nanmean(datVP.rtErr);
  sdRtErr = nanstd(datVP.rtErr);
  seRtErr = sdRtErr/sqrt(nTotal);
  
  errPer   = nanmean(datVP.perErr);
  sdErrPer = nanstd(datVP.perErr);
  seErrPer = sdErrPer/sqrt(nTotal);
  
  % datatable
  datAgg = [datAgg; cell2table({comp,nTotal,nCorr,nErr,nOut,rtCorr,sdRtCorr,seRtCorr,rtErr,sdRtErr,seRtErr,errPer,sdErrPer,seErrPer}, 'VariableNames', varNames);];
  
end

res.summary = datAgg;

%% calculate conditional accuracy functions (CAF)
datAggVPcaf = array2table(nan(0, 10));
for vp = transpose(unique(dat.VP))
  
  datVP = dat(dat.VP == vp & dat.Outlier == 0, :);
  
  rtC = [datVP.RT(strcmp(datVP.Comp, 'comp')),   datVP.Error(strcmp(datVP.Comp, 'comp'))];
  rtI = [datVP.RT(strcmp(datVP.Comp, 'incomp')), datVP.Error(strcmp(datVP.Comp, 'incomp'))];
  
  [~, ~, rtC(:, 3)] = histcounts(rtC(:,1), prctile(rtC(:, 1), 0:20:100));
  [~, ~, rtI(:, 3)] = histcounts(rtI(:,1), prctile(rtI(:, 1), 0:20:100));
  
  caf  = transpose([calcCAF(rtC), calcCAF(rtI)]);
  
  datAggVPcaf = [datAggVPcaf; array2table(caf(:)')];
  
end

res.caf = [mean(datAggVPcaf{:,1:2:end}); mean(datAggVPcaf{:,2:2:end})];

%% calculate delta points
% aggregate data across trials
datAggVPrt = array2table(nan(0, 10));
for vp = transpose(unique(dat.VP))
  for comp = {'comp', 'incomp'}
    
    datVP = dat(dat.VP == vp & strcmp(dat.Comp, comp) & dat.Error == 0 & dat.Outlier == 0, :);
    
    [~, ~, datVP.bin] = histcounts(datVP.RT, prctile(datVP.RT, 0:10:100));
    binRt             = splitapply(@mean, datVP.RT, findgroups(datVP.bin));
    
    datAggVPrt = [datAggVPrt; array2table(binRt')];
    
  end
end

compDat   = datAggVPrt{1:2:end,:};
incompDat = datAggVPrt{2:2:end,:};

meanCI    = mean((compDat + incompDat)/2);
meanDelta = mean(incompDat - compDat);
sdDelta   = std(incompDat - compDat);
seDelta   = sdDelta/sqrt(size(compDat, 1));

res.rtDist = [mean(compDat); mean(incompDat); meanCI; meanDelta; sdDelta; seDelta];

%%
if makePlots
  
  figH       = figure;
  figH.Color = [1 1 1];
  
  subplot(2, 3, 1)
  errorbar([1, 2], datAgg.rtCorr, datAgg.seRtCorr, 'ko-', 'MarkerSize', 5, 'MarkerFaceColor', 'k')
  xlim([0.5 2.5])
  ylim([400 540])
  ylabel('RT Correct (ms)')
  xticks([1 2])
  xticklabels({'Compatible', 'Incompatible'})
  yticks(400:20:540)
  set(gca, 'FontSize', 6)
  grid on
  
  subplot(2, 3, 2)
  errorbar([1, 2], datAgg.rtErr, datAgg.seRtErr, 'ko-', 'MarkerSize', 5, 'MarkerFaceColor', 'k')
  xlim([0.5 2.5])
  ylim([400 540])
  ylabel('RT Error (ms)')
  xticks([1 2])
  xticklabels({'Compatible', 'Incompatible'})
  yticks(400:20:540)
  set(gca, 'FontSize', 6)
  grid on
  
  subplot(2, 3, 3)
  errorbar([1, 2], datAgg.perErr, datAgg.sePerErr, 'ko-', 'MarkerSize', 5, 'MarkerFaceColor', 'k')
  xlim([0.5 2.5])
  ylim([0 5])
  ylabel('Error Rate (%)')
  xticks([1 2])
  xticklabels({'Compatible', 'Incompatible'})
  yticks(0:5)
  set(gca, 'FontSize', 6)
  grid on
  
  % CDF, CAF and delta plots
  % CDF
  h = subplot(2, 3, 4);
  hold on
  ch(1) = cdfplot(dat.RT(dat.Error == 0 & dat.Outlier == 0 & strcmp(dat.Comp, 'comp')));
  set(ch(1),'Color','g');
  ch(2) = cdfplot(dat.RT(dat.Error == 0 & dat.Outlier == 0 & strcmp(dat.Comp, 'incomp')));
  set(ch(2),'Color','r');
  ylim([-0.05 1.05]);
  xlim([0 1000]);
  xlabel('')
  ylabel('CDF')
  xlabel('t (ms)')
  title('')
  legend('Comp', 'Incomp', 'Location', 'southeast')
  set(gca, 'FontSize', 6)
  grid on, box on
  
  subplot(2, 3, 5);
  hold on, box on
  plot(1:5, res.caf(1, :), '-og', 'MarkerSize', 5, 'MarkerFaceColor', 'g')
  plot(1:5, res.caf(2, :), '-or', 'MarkerSize', 5, 'MarkerFaceColor', 'r')
  xlim([0.5 5.5]);
  xlabel('RT Bin (%)')
  xticks(1:4)
  xticklabels({'0-20', '20-40', '40-60', '60-80', '80-100'})
  ylim([0 1.1]);
  ylabel('CAF')
  set(gca, 'FontSize', 6)
  legend('Comp', 'Incomp', 'Location', 'southeast')
  grid on
  
  % delta
  subplot(2, 3, 6);
  errorbar(meanCI, meanDelta, seDelta, 'ko-', 'MarkerSize', 2, 'MarkerFaceColor', 'k')
  ylim([-50 150]);
  xlim([300 800]);
  xlabel('Time (ms)')
  ylabel('Incompatible - Compatible')
  set(gca, 'FontSize', 6)
  grid on
  
  % save figure
  orient(gcf, 'landscape')
  print('FlankerTask1_Mplot','-dpdf', '-fillpage')
  
end
