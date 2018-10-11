function x = rand_beta(n, shape, lim)
% x = rand_beta(n, shape, lim)
%
% Returns and random vector of length nun generated from a beta distribution
%     with shape and scalled between lim
%
% Examples:
% x = rand_beta(100000, 3, [-10 10]);
% hist(x, 50)
% x = rand_beta(100000, 1, [-2 2]);
% hist(x, 50)

if nargin == 2
  lim = [0 1];
elseif nargin == 1
  shape = 3;
  lim   = [0 1];
elseif nargin == 0
  n     = 1;
  lim   = [0 1];
  shape = 3;
end

x = betarnd(shape, shape, n, 1);     % select from beta distribution
x = x * (lim(2) - lim(1)) + lim(1);  % scale 
