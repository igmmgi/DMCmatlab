function fitDMC(datOb, varargin)
% fitDMC(datOb, varargin)
%
% Fit theoretical data generated from dmcSim to observed data by minimizing
%   the root-mean-square error (RMSE) between a weighted combination of the
%   CAF and CDFs.
%
% The minimizing procedure uses the iFit optimization library:
% http://ifit.mccode.org/
% method: 'fminsearchbnds', 'fminsimplex', 'fminsimpsa', 'fminswarm', and so on ...
%   see http://ifit.mccode.org/Optimizers.html#mozTocId184231 for all options
%
% Inputs:
% dat is a MATLAB data structure that should contain the following fields:
%    summary
%    caf
%    rtDist
%
% See example data analysis scripts to create required data structure
%
% dat = flankerTask1
% dat.summary
%
%      Comp*     nTotal    nCorr    nErr    nOut    rtCorr*    sdRtCorr*  seRtCorr    rtErr*   sdRtErr*    seRtErr    perErr*    sdPerErr*   sePerErr
%    ________    ______    _____    ____    ____    ______    ________    ________    ______    _______    _______    _______    ________    ________
%
%    'comp'        18      8988      84      77      475.7     52.099       12.28     439.45     72.54     17.098     0.92593     1.1162     0.26309
%    'incomp'      18      8764     308     106     511.79     57.634      13.584     447.82     60.42     14.241      3.3951     2.5815     0.60847
%
% The columns with an * are required!
%
% dat.caf
%
% 0.9792    0.9944    0.9967    0.9967    0.9926
% 0.9190    0.9783    0.9810    0.9826    0.9857
%
% First row is compatible trials, second row is incompatible trials
%
% dat.rtDist
%
%  370.1353  400.5217  417.8543  433.2564  448.0002  463.3567  480.9648  504.3130  541.8942  696.3665
%  385.2554  422.1616  444.4134  463.3169  480.9268  500.4709  523.4527  551.1924  593.2329  753.0271
%  377.6954  411.3416  431.1338  448.2867  464.4635  481.9138  502.2087  527.7527  567.5635  724.6968
%   15.1200   21.6399   26.5591   30.0605   32.9266   37.1143   42.4879   46.8794   51.3387   56.6606
%   11.8302   14.9741   15.2656   16.0158   17.0580   17.1810   18.5293   20.4348   24.2567   33.1665
%    2.7884    3.5294    3.5981    3.7750    4.0206    4.0496    4.3674    4.8165    5.7174    7.8174
%
% First row is compatible trials, second row is incompatible trials,
%   third row is mean comp + incomp, 4th row is incomp - comp (delta), 5th row
%   is SD delta, 6th row is SE delta
%
%
% Examples 1
% datOb = flankerTask1;
% fitDMC(datOb)
%
% Example 2
% datOb = flankerTask2;
% fitDMC(datOb, 'numIterations', 10, 'nTrl', 10000)

%% setup
startVals         = [20 100 2 0.5 4  75 350 100 3];
constraints.min   = [15  20 1 0   2  25 100  10 2];
constraints.max   = [25 180 3 1   6 125 600 200 4];
constraints.fixed = [0    0 0 0   0   0   0   0 0];
constraints.steps = [1    1 1 1   1   1   1   1 1];
numIterations     = 500;
nTrl              = 50000;
useGPU            = false;
method            = str2func('fminsearchbnd');
exportFig         = false;
expName           = 'DMC Fit';
for i = 1:2:length(varargin)
  switch varargin{i}
    case 'startVals'
      startVals = varargin{i+1};
    case 'constraints.min'
      constraints.min = varargin{i+1};
    case 'constraints.max'
      constraints.max = varargin{i+1};
    case 'constraints.fixed'
      constraints.fixed = varargin{i+1};
    case 'constraints.steps'
      constraints.steps = varargin{i+1};
    case 'numIterations'
      numIterations = varargin{i+1};
    case 'nTrl'
      nTrl = varargin{i+1};
    case 'useGPU'
      useGPU = varargin{i+1};
    case 'method'
      method = str2func(varargin{i+1});
    case 'exportFig'
      exportFig = varargin{i+1};
    case 'expName'
      expName = varargin{i+1};
    otherwise
      error('varargin not recognised');
  end
end

%% run optimisation function
startTime = tic;

% optimisation settings
opts.Display     = 'iter';
opts.TolX        = 1.e-12;
opts.MaxFunEvals = numIterations;

% function to optimize
fun = @(x) minimizeCostValue(x(1), x(2), x(3), x(4), x(5), x(6), x(7), x(8), x(9), datOb, nTrl, useGPU);
[endVals, fval, ~, out] = method(fun, startVals, opts, constraints);

% dmc sim
datTh = dmcSim('amp', endVals(1), 'tau', endVals(2), 'aaShape', endVals(3), 'mu', endVals(4), ...
  'sigma', endVals(5), 'bnds', endVals(6), 'resMean', endVals(7), 'resSD', endVals(8), ...
  'tmax', 1000, 'nTrl', nTrl, 'varSP', true, 'spShape', endVals(9), 'makePlots', false);

% calculate final RMSE
RMSE = calcCostvalue(datTh, datOb);

%% table
table1 = array2table([startVals; endVals], ...
  'RowNames', {'Start Values'; 'End Values'}, ...
  'VariableNames', {'amp' 'tau' 'aaShape' 'mu' 'sigma' 'bnds' 'resMean' 'resSD' 'spShape'});

table2 = table(RMSE, fval, out.iterations, toc(startTime), ...
  'VariableNames', {'RMSE' 'fval' 'nIterations' 'time'});

%clc
fprintf('\nStart/End Values:\n\n')
disp(table1)
fprintf('\nModel Fit:\n\n')
disp(table2)
fprintf('\nObserved Results:\n\n')
disp(datOb.summary(:, [1 6 7 12 9 10]))
fprintf('\nPredicted Results:\n\n')
disp(datTh.summary)


%% Plot Summary Figure
plotDMC_fit(expName, datTh, datOb, table1, table2, exportFig);

end

%%
function costValue = minimizeCostValue(amp, tau, aaShape, mu, sigma, bnds, resMean, resSD, spShape, datOb, nTrl, useGPU)
% function costValue = minimizeCostValue(amp, tau, aa_shape, mu, sigma, bnds, resMean, resSD, spShape, datOb, nTrl, useGPU)

datTh = dmcSim('amp', amp, 'tau', tau, 'aaShape', aaShape, 'mu', mu, 'sigma', sigma, ...
  'bnds', bnds, 'resMean', resMean, 'resSD', resSD, 'nTrl', nTrl, ...
  'varSP', true, 'spShape', spShape, 'makePlots', false);

costValue = calcCostvalue(datTh, datOb);

end

%%
function costValue = calcCostvalue(datTh, datOb)
% costValue = calcCostvalue(datTh, datOb)

n_err = size(datTh.caf, 2)    * 2;
n_rt  = size(datTh.rtDist, 2) * 2;

costCAF = sqrt((1/n_err) * sum((sum(datTh.caf - datOb.caf).^2)));
costRT  = sqrt((1/n_rt)  * sum((sum(datTh.rtDist(1:2, :) - datOb.rtDist(1:2, :)).^2)));

costValue = (((1 - (2*n_rt)/(2*n_rt + 2*n_err)) * 1500) * costCAF) + costRT;

end

%%
function plotDMC_fit(exp, datTh, datOb, table1, table2, exportFig)
% plotDMC(datTh, datOb, table1, table2, exportFig)

figH          = figure;
figH.Units    = 'centimeters';
figH.Position = [0 0 30 25];
figH.Color    = [1 1 1];
figH.Name     = exp;

subplot(4,2,1)
hold on, box on, grid off
plot(1:2, [datOb.summary.rtCorr(1), datOb.summary.rtCorr(2)], '-o', 'Color', 'k')
plot(1:2, [datTh.summary.rtCorr(1), datTh.summary.rtCorr(2)], '--o', 'Color', 'k')
xticks(1:2)
xlim([0.5 2.5])
ylim([300 800])
xticklabels({'Comp', 'Incomp'})
ylabel('RT [ms] Correct')
legend('Observed', 'Predicted', 'Location', 'best')

subplot(4,2,3)
hold on, box on, grid off
plot(1:2, [datOb.summary.perErr(1), datOb.summary.perErr(2)], '-o', 'Color', 'k')
plot(1:2, [datTh.summary.perErr(1), datTh.summary.perErr(2)], '--o', 'Color', 'k')
xticks(1:2)
xlim([0.5 2.5])
ylim([0 20])
xticklabels({'Comp', 'Incomp'})
ylabel('Error Rate [%]')
legend('Observed', 'Predicted', 'Location', 'best')

subplot(4,2,5)
hold on, box on, grid off
plot(1:2, [datOb.summary.rtErr(1), datOb.summary.rtErr(2)], '-o', 'Color', 'k')
plot(1:2, [datTh.summary.rtErr(1), datTh.summary.rtErr(2)], '--o', 'Color', 'k')
xticks(1:2)
xlim([0.5 2.5])
xticklabels({'Comp', 'Incomp'})
ylim([300 800])
ylabel('RT Error [ms]')
legend('Observed', 'Predicted', 'Location', 'best')

subplot(4,2,2)
hold on, box on, grid off
plot(datOb.rtDist(1,:), 0.05:0.1:0.95, 'o', 'Color', 'g')
plot(datOb.rtDist(2,:), 0.05:0.1:0.95, 'o', 'Color', 'r')
plot(datTh.rtDist(1,:), 0.05:0.1:0.95, '-', 'Color', 'g')
plot(datTh.rtDist(2,:), 0.05:0.1:0.95, '-', 'Color', 'r')
ylim([-0.05 1.05]);
xlim([200 800])
xlabel('t [ms]')
ylabel('CDF')
legend('Comp Observed', 'Incomp Observed','Comp Predicted', 'Incomp Predicted', 'Location', 'southeast')

subplot(4,2,4)
hold on, box on, grid off
plot(1:5, datOb.caf(1, :), 'og', 1:5, datOb.caf(2, :), 'or')
plot(1:5, datTh.caf(1, :), '-g', 1:5, datTh.caf(2, :), '-r')
xlim([0.5 5.5]);
xlabel('RT Bin (%)')
xticks(1:5)
xticklabels({'0-20', '20-40', '40-60', '60-80', '80-100'})
ylim([0 1.1]);
ylabel('CAF')
legend('Comp Observed', 'Incomp Observed','Comp Predicted', 'Incomp Predicted', 'Location', 'southeast')

subplot(4,2,6)
hold on, box on, grid off
plot(datOb.rtDist(3, :), datOb.rtDist(4, :), '--ok', 'MarkerSize', 4)
plot(datTh.rtDist(3, :), datTh.rtDist(4, :), '-k')
ylim([-20 100]);
xlim([200 800]);
xlabel('Time (ms)')
ylabel('\Delta')
legend('Observed', 'Predicted', 'Location', 'best')

% start/end values
vals = {'amp', 'tau', 'aaShape', 'mu', 'sigma', 'bnds', 'resMean', 'resSD', 'spShape'}';
text(-530, -175, vals, 'FontSize', 14)
text(-520, -80, 'Value', 'FontSize', 14)
text(-370, -80, 'Start', 'FontSize', 14)
text(-220, -80, 'End', 'FontSize', 14)
text(-370, -175, num2str(table2array(table1(1,:))', '%.1f\n'), 'FontSize', 14)
text(-250, -175, num2str(table2array(table1(2,:))', '%.3f\n'), 'FontSize', 14)

% model fit
vals = {'RMSE:', 'fval:', 'nIterations:', 'time:'}';
text(300, -160, vals, 'FontSize', 14)
text(475, -160, num2str(table2array(table2)', '%.2f\n'), 'FontSize', 14)

if exportFig  % save figure
  orient(gcf, 'landscape')
  print([exp '_fit_' datestr(now, 30)],'-dpdf', '-fillpage')
end

end
