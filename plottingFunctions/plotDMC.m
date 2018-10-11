function plotDMC(res)
% function plotDMC(res)
%
% Plot results from dmcSim
% 
%
% Examples
% dmc = dmcSim()
% plotDMC(dmc)

figH          = figure;
figH.Color    = [1 1 1];
figH.Units    = 'centimeters';
figH.Position = [0 0 35 30];

% lower left panel (just plot first 5 trials)
h(1) = subplot(6, 4, [13 14 17 18 21 22]);
plotDMC_activation(res)

% upper left panel
h(2) = subplot(6, 4, [1 2 5 6 9 10]);
plotDMC_trials(res)

% upper right panel (left)
h(3) = subplot(6, 4, [3 7]);
plotDMC_pdf(res)

% upper right panel (right)
h(4) = subplot(6, 4, [4 8]);
plotDMC_cdf(res)

% middle right panel (Fig 8 simulated conditional accuracy functions)
h(5) = subplot(6, 4, [11 12 15 16]);
plotDMC_caf(res)

% lower right panel
h(6) = subplot(6, 4, [19 20 23 24]);
plotDMC_delta(res)

% common xy axis settings
ylim(h(1:2),[-res.prms.bnds-20 res.prms.bnds+20])
yticks(h(1:2), [-res.prms.bnds 0 res.prms.bnds])
xlim(h([1:2 6]), [0 1000])
xticks(h([1:2 6]), 0:200:1200)
xlim(h(3:4), [0 1000])
xticks(h(3:4), 0:500:1200)