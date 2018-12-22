function plotDMC_pdf(res)
% plotDMC_pdf(res)

[fC, xiC] = ksdensity(res.rts.comp(:, 1));
[fI, xiI] = ksdensity(res.rts.incomp(:, 1));

hold on, grid off, box on
plot(xiC, fC, 'g', xiI, fI, 'r');
xlabel('Time (ms)'), ylabel('PDF');
ylim([-0.0005 10e-03])
