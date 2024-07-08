% Parameters for the power calculation
m1 = -43.11; %smaller n
m2 = -43.04; % bigger n
sd1 = 6.58; % smaller n
n1 = 26; % Smaller
n2 = 27; % Bigger
% sd2 = 8.47;
% meanDiff = 11; % Example mean difference between two groups
% pooledSD = 7.24; % Pooled standard deviation of the groups
% alpha = 0.05; % Significance level

% tail = 'both'; % Type of test ('both' for two-tailed, 'right' for one-tailed)

% Calculate the effect size
% effectSize = meanDiff / pooledSD;

% Calculate the effective sample size for unequal group sizes
% neff = 1 / ((1/n1) + (1/n2));
nrat = n2/n1;

% Calculate the power using the effective sample size
% [~, power] = sampsizepwr('t2', [0 pooledSD], meanDiff, [], round(neff), tail, 'Alpha', alpha);
power = sampsizepwr('t2', [m1 sd1], m2, [], n2, 'Ratio', nrat);

% Display the power
fprintf('The power of the test with unequal group sizes (n1=%d, n2=%d) is: %.3f\n', n1, n2, power);
