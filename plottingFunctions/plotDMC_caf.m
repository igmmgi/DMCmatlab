function plotDMC_caf(res)
% plotDMC_caf(res)

numBins = size(res.caf, 2);
hold on, box on
plot(1:numBins, res.caf(1, :), '-og', 1:numBins, res.caf(2, :), '-or')
xlim([0.5 numBins+0.5]); ylim([0 1.1]);
xlabel('RT Bin'), ylabel('CAF')
xticks(1:numBins)
legend('Comp', 'Incomp', 'Location', 'southeast')
