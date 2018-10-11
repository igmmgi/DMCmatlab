% dmc_figB1
% DMC model from Ulrich, Schröter, Leuthold & Birngruber (2015)
% Code adapted from Appendix C. Basic Matlab Code
% Matlab 2017a (implicit expansion required from Matlab 2016a+)
%
% Reproduces Figures B1 with changes in tau parameter (50, 100, 150)

% compute time-dependent drift rate mu(t)
tmax = 1000;
time = linspace(1, tmax, tmax);
amp  = 20;

count = 1;
for tau = [50 100 150]
  eq4(count, :) = amp .* exp(-time ./ tau) .* (exp(1) .* time ./tau);
  eq5(count, :) = eq4(count, :) .*(1 ./ time-1/tau); 
  count = count + 1;
end

figH       = figure;
figH.Color = [1 1 1];
subplot(2, 1, 1)  
plot(time, eq4')
xlabel('Time (ms)')
ylabel('E[X_a(t)]')
subplot(2, 1, 2)  
plot(time, eq5')
xlabel('Time (ms)')
ylabel('\mu_a(t)')
legend('\tau=50', '\tau=100', '\tau=150')
