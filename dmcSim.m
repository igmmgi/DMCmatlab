function res = dmcSim(varargin)
% res = dmcSim(varargin)
%
% DMC model simulation
% Ulrich, R., Schröter, H., Leuthold, H., & Birngruber, T. (2015).
% Automatic and controlled stimulus processing in conflict
%   tasks: Superimposed diffusion processes and delta functions.
%   Cognitive psychology, 78, 148-174.
% Code adapted from Appendix C. Basic Matlab Code.
%
% Tested using Matlab 2017a+ (implicit broadcasting required from Matlab 2016b+)
%
% varargin:
% 'amp',       amplitude of automatic activation
% 'tau',       time to peak automatic activation
% 'aaShape',   shape parameter of automatic activation
% 'mu',        drift rate of controlled processes
% 'sigma',     diffusion constant
% 'bnds',      +- response barrier
% 'resMean',   mean of non-decisional component
% 'resSD',     standard deviation of non-decisional component
% 'tmax',      integer
% 'varSP',     true/false variable starting point
% 'spShape',   shape parameter of starting point distribution
% 'varDR',     true/false variable drift rate
% 'drLim',     limit range of distribution of drift rate
% 'drShape',   shape parameter of drift rate
% 'nTrl',      integer between ~1000 and 200000
% 'nTrlData',  integer beteen ~5 and 10
% 'cafBins',   bins to calculate conditional accuracy functions
% 'deltaBins', bins to calculate incomp-comp delta plots
% 'makePlots', true/false
%
% Outputs:
% struct with the following fields:
%     activation: drift, comp, incomp
%     trials: comp, incomp
%     rts: comp, incomp with n rows (trials) and 3 columns (rt, error, bin)
%     caf: 2 rows (comp, incomp * n columns (bins)
%     rtDist: 4 rows (comp, incomp, mean, effect) * n columns (bins)
%     prms: model input parameters
%     summary: table with comp, incomp with mean/sd/percentage errors
%
% Reproduces Figures 3 (30), 4 (150), & 5 (90) with changes in tau parameter (see Table 1)
% Reproduces Figure 6 with varSP (variable start point)
% Reproduces Figure 7 with varDR (variable drift rate)
% Reproduces Figure 8 (CAF) varies with changes in bounds (speed/accuracy)
%
% Examples:
% res = dmcSim();               Fig 3
% res = dmcSim('tau', 150);     Fig 4
% res = dmcSim('tau', 90);      Fig 5
% res = dmcSim('varSP', true);  Fig 6
% res = dmcSim('varDR', true);  Fig 7
% res = dmcSim('amp', 25, 'tau', 15, 'resMean', 350, ...)

%% setup
prms.amp       = 20;          % amplitude of automatic activation
prms.tau       = 30;          % time to peak automatic activation
prms.aaShape   = 2;           % shape parameter of automatic activation
prms.mu        = 0.5;         % drift rate of controlled processes
prms.sigma     = 4;           % diffusion constant
prms.bnds      = 75;          % +- response barrier
prms.resMean   = 300;         % mean of non-decisional component
prms.resSD     = 30;          % standard deviation of non-decisional component
prms.tmax      = 1000;        % vector length
prms.varSP     = false;       % variable start point
prms.spShape   = 3;           % shape parameter of variable start point
prms.varDR     = false;       % variable drift rate
prms.drLim     = [0.1 0.7];   % range of beta distribution
prms.drShape   = 3;           % shape parameter of variable drift rate
prms.nTrl      = 100000;      % number of trials within each comp/incomp conditions
prms.nTrlData  = 5;           % number of individual trials to return
prms.cafBins   = 0:20:100;    % bins to calculate conditional accuracy functions
prms.deltaBins = 5:10:95;     % bins to calculate incomp-comp delta plots
prms.makePlots = true;
for i = 1:2:length(varargin)
  switch varargin{i}
    case 'amp'
      prms.amp = varargin{i+1};
    case 'tau'
      prms.tau = varargin{i+1};
    case 'aaShape'
      prms.aaShape = varargin{i+1};
    case 'mu'
      prms.mu = varargin{i+1};
    case 'sigma'
      prms.sigma = varargin{i+1};
    case 'bnds'
      prms.bnds = varargin{i+1};
    case 'resMean'
      prms.resMean = varargin{i+1};
    case 'resSD'
      prms.resSD = varargin{i+1};
    case 'tmax'
      prms.tmax = varargin{i+1};
    case 'varSP'
      prms.varSP = varargin{i+1};
    case 'spShape'
      prms.spShape = varargin{i+1};
    case 'varDR'
      prms.varDR = varargin{i+1};
    case 'drLim'
      prms.drLim = varargin{i+1};
    case 'drShape'
      prms.drShape = varargin{i+1};
    case'nTrl'
      prms.nTrl = varargin{i+1};
    case'nTrlData'
      prms.nTrlData = varargin{i+1};
    case 'cafBins'
      prms.cafBins = varargin{i+1};
    case 'deltaBins'
      prms.deltaBins = varargin{i+1};
    case'makePlots'
      prms.makePlots = varargin{i+1};
    otherwise
      error('varargin not recognised');
  end
end

%% create results structure
res = resStruct(prms);

%% simulation
t = 1:prms.tmax;
drift = prms.amp .* exp(-t ./ prms.tau) .* (exp(1) .* t ./ (prms.aaShape-1) ./ prms.tau) .^ (prms.aaShape-1); 

for comp = {'comp', 'incomp'}
  
  if strcmp(comp, 'comp'); sign = 1; else, sign = -1; end
  
  if ~prms.varDR  % constant drift rate across trials
    muVec =  (sign * drift) .* ((prms.aaShape-1) ./ t - 1/prms.tau) + prms.mu;  % eq7/eq8
  else  % variable drift rate (vdr): beta distribution
    res.prms.mu = rand_beta(prms.nTrl, prms.drShape, prms.drLim);
    muVec =  repmat((sign * drift) .* ((prms.aaShape-1) ./ t - 1/prms.tau), prms.nTrl, 1) + res.prms.mu;  % eq7/eq8
  end
  
  activation = muVec + (prms.sigma*randn(prms.nTrl, prms.tmax, 'single'));
  
  if prms.varSP  % variable starting point: beta distribution (+- bounds)
    activation(:, 1) = activation(:, 1) + rand_beta(prms.nTrl, prms.spShape, [-prms.bnds prms.bnds]);
  end
  
  % accumulate activation
  activation = cumsum(activation, 2);
  
  %% find RTs for correct/incorrect trials (point where X exceeds crit +-bounds)
  [~, rt] = max(abs(activation) > prms.bnds, [], 2);
  rt(rt == 1, 1) = prms.tmax;  % does not reach boundary classified as error
  rt_idx  = sub2ind(size(activation), 1:size(activation, 1), rt');
  rt      = [rt + normrnd(prms.resMean, prms.resSD, prms.nTrl, 1), (activation(rt_idx) < prms.bnds)'];
  
  %% calculate conditional accuracy functions (CAF)
  [~, ~, rt(:, 3)]  = histcounts(rt(:, 1), prctile(rt(:, 1), prms.cafBins));
  res.caf = [res.caf; transpose(calcCAF(rt))];
  
  %% calculate percentiles
  res.rtDist = [res.rtDist; prctile(rt(rt(:, 2) == 0, 1), prms.deltaBins)];
  
  %% store required results
  res.activation.drift     = drift;
  res.activation.(comp{:}) = mean(activation);
  res.trials.(comp{:})     = activation(1:prms.nTrlData, :);
  res.rts.(comp{:})        = rt;
  res.summary              = [res.summary; [comp(:)', ...
    {round(mean(rt(rt(:, 2) == 0)))}, ...
    {round(std(rt(rt(:, 2) == 0)))}, ...
    {round(sum(rt(:,2)/prms.nTrl) * 100, 1)}, ...
    {round(mean(rt(rt(:, 2) == 1)))}, ...
    {round(std(rt(rt(:, 2) == 1)))}]];
  
end

%% calculate comp effect and delta
res.rtDist(3,:) = (res.rtDist(1, :) + res.rtDist(2, :)) / 2;
res.rtDist(4,:) = (res.rtDist(2, :) - res.rtDist(1, :));

%% plots
if prms.makePlots
  plotDMC(res);
end

end

%%
function res = resStruct(prms)
% res = resStruct(prms)
%
% Creates output structure for dmcSim.

res.prms       = prms;
res.activation = [];
res.trials     = [];
res.rts        = [];
res.caf        = [];
res.rtDist     = [];
res.summary    = array2table(nan(0, 6), ...
  'VariableNames', {'Comp', 'rtCorr', 'sdRtCorr', 'perErr', 'rtErr', 'sdRtErr'});

end
