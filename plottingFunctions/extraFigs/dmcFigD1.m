% dmc_figD1
% DMC model from Ulrich, Schröter, Leuthold & Birngruber (2015)
% Code adapted from Appendix C. Basic Matlab Code
% Matlab 2017a (implicit expansion required from Matlab 2016b+)
%
% Reproduces Figures D1 BUT A = 1?

b = [-50 50];
x = linspace(-50, 50);

figH             = figure;
figH.NumberTitle = 'off';
figH.MenuBar     = 'none';
figH.Color       = [1 1 1];
hold on
box on
for a = 1:4 
  fx = (x-b(1)).^(a-1) .* (b(2)-x).^(a-1) ./  (beta(a,a)*((b(2)-b(1)))^(2*a-1)); % eq9    
  plot(x, fx)
end

legend('\alpha=1', '\alpha=2', '\alpha=3', '\alpha=4')
xlim([-55 55])
ylim([-0.001 0.025])
xlabel('Starting Point')
ylabel('PDF')
xticks(-50:10:50)

% sample from the distribution
% hist(datasample(x, 100000, 'Weights', fx));



