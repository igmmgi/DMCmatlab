function plotDMC_activation(res)
% plotDMC_activation(res)

hold on, box on
plot(1:res.prms.tmax, res.activation.comp, '-g', 1:res.prms.tmax, res.activation.incomp, '-r')
plot(1:res.prms.tmax,  res.activation.drift, '.k', 1:res.prms.tmax, -res.activation.drift, '--k', 'MarkerSize', 0.5)
plot(1:res.prms.tmax, cumsum(repmat(mean(res.prms.mu), 1, res.prms.tmax)), 'k')
xlabel(''), ylabel('E[X(t)]');
