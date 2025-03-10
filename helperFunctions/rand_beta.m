function x = rand_beta(num, shape, lim)
% x = rand_beta(num, shape, lim)
%
% Return random vector between limits (lim) weighted by beta function
%
% Examples:
% xx = rand_beta(100000, 3, [-75 75])
% hist(xx, 500)
% x = rand_beta(100000, 1, [-2 2])
% hist(x, 50)

if nargin == 2
  lim   = [0 1];  
elseif nargin == 1
  lim   = [0 1];
  shape = 3;  
elseif nargin == 0
  lim   = [0 1];
  shape = 3;
  num   = 1;
end

x = betarnd(shape, shape, num, 1);   % select from beta distribution
x = x * (lim(2) - lim(1)) + lim(1);  % scale
