function plotDMC_delta(res)
% plotDMC_delta(res)

plot(res.rtDist(3, :), res.rtDist(4, :), '-ok', 'MarkerSize', 4)
ylim([-50 110]);
xlabel('Time (ms)'), ylabel('\Delta');