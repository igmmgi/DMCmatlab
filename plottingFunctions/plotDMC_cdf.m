function plotDMC_cdf(res)
% plotDMC_cdf(res)

hold on, box on
ch(1) = cdfplot(res.rts.comp(:, 1));
set(ch(1),'Color', 'g');
ch(2) = cdfplot(res.rts.incomp(:, 1));
set(ch(2),'Color', 'r');
ylim([-0.05 1.05]);
xlabel(''), ylabel('CDF');
title('')
grid off