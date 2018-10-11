function plotDMC_trials(res)
% plotDMC_trials(res)

hold on, box on
for trl = 1:5
  idx = find(abs(res.trials.comp(trl, :)) >= res.prms.bnds, 1, 'first');
  plot(res.trials.comp(trl, 1:idx), '-g')
  idx = find(abs(res.trials.incomp(trl, :)) >= res.prms.bnds, 1, 'first');
  plot(res.trials.incomp(trl, 1:idx), '-r')
end
plot([0 res.prms.tmax], [res.prms.bnds res.prms.bnds], '-k', [0 res.prms.tmax], [-res.prms.bnds -res.prms.bnds], '-k')
xlabel('Time (ms)'), ylabel('X(t)');