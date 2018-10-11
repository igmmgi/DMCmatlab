function dmcFig11(amp, tau, alpha, sigma, bounds, resMean, resSD, driftRates, nTrl)
% dmcFig11(amp, tau, alpha, sigma, bounds, resMean, resSD, driftRates, nTrl)
%
% DMC model from Ulrich, Schröter, Leuthold & Birngruber (2015)
% Code adapted from Appendix C. Basic Matlab Code
% Tested using Matlab 2017a (implicit expansion required from Matlab 2016b+)
%
% Reproduces Figure 11 with changes in drift rate
%
% Example:
% dmcFig11(20, 30, 2, 4, 75, 300, 30)

%% setup
if nargin == 8
  nTrl = 100000;
elseif nargin == 7
  driftRates = 0.2:0.05:0.7;
  nTrl       = 100000;
elseif nargin == 0 % just run examples to produce figure in paper
  dmcFig11(20, 30, 2, 4, 75, 300, 30, 0.2:0.05:0.7, 100000)
  return
elseif nargin ~= 9
  error('Check number of input arguments.')
end

%% simulations
% compute time-dependent drift rate mu(t)
tmax = 1000;
t    = linspace(1, tmax, tmax);
eq4  = amp .* exp(-t ./ tau) .* (exp(1) .* t ./ (alpha-1) ./tau) .^(alpha-1);

rts(length(driftRates), 3) = 0;
runNum = 1;
for mu_c = driftRates
  
  % simulate time-dependent Wiener process X(t) for comp/incomp trials
  muC =  eq4 .* ((alpha-1) ./ t-1/tau) + mu_c;   % eq7
  muI = -eq4 .* ((alpha-1) ./ t-1/tau) + mu_c ;  % eq8
  xC  = muC + (sigma*randn(nTrl, length(t)));
  xI  = muI + (sigma*randn(nTrl, length(t)));
  xC  = cumsum(xC, 2);
  xI  = cumsum(xI, 2);
  
  %% find RTs for correct/incorrect trials (point where X exceeds crit +-bounds)
  [~, rtC] = max(abs(xC) >=  bounds, [], 2);
  [~, rtI] = max(abs(xI) >=  bounds, [], 2);
  
  rtCidx = sub2ind(size(xC), 1:size(xC, 1), rtC');
  rtIidx = sub2ind(size(xC), 1:size(xC, 1), rtI');
  
  rtsC = [rtC + normrnd(resMean, resSD, nTrl, 1), (xC(rtCidx) < 0)'];
  rtsI = [rtI + normrnd(resMean, resSD, nTrl, 1), (xI(rtIidx) < 0)'];
  
  rts(runNum, 1:2) = [mean(rtsC(rtsC(:, 2) == 0, 1)), mean(rtsI(rtsI(:, 2) == 0, 1))];
  
  runNum = runNum + 1;
  
end

% calculate comp effect
rts(:, 3) = rts(:, 2) - rts(:, 1);

% plot
figH             = figure;
figH.NumberTitle = 'off';
figH.MenuBar     = 'none';
figH.Color       = [1 1 1];
figH.Units       = 'centimeters';
figH.Position    = [0 0 25 15];

subplot(1,2,1)
plot(rts(:, 1:2), '-o')
xlabel('Drift Rate \mu_c of Controlled Process')
xticks(1:length(driftRates))
xticklabels(driftRates)
ylabel('Mean Reaction Time (ms)')
legend('Compatible', 'Incompatible')

subplot(1,2,2)
plot(rts(:, 3), '-o')
xlabel('Drift Rate \mu_c of Controlled Process')
xticks(1:length(driftRates))
xticklabels(driftRates)
ylabel('\Delta')

