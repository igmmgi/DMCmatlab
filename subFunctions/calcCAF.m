function caf = calcCAF(dat)
% caf = calcCAF(dat)
%
% Calculate conditional accuracy function (CAF)
%
% Inputs:
% dat: n*3 matrix with the following columns:
%     col1: rt data
%     col2: error logical (0 = correct, 1 = error)
%     col3: bin number

nBins = length(unique(dat(:, 3)));
caf   = zeros(nBins, 1);
for i = 1:nBins
  nObs   = length(dat(dat(:, 3) == i, 2));
  caf(i) = 1 - sum(dat(dat(:, 3) == i, 2)) / nObs;
end
