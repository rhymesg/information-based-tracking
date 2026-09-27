function [J, score_mean] = monte_carlo_information(scores)
% Empirical Fisher information from score outer products; see docs/statistical-information.md.
% Related non-Gaussian CRB application: Kim and Bang, APISAT 2017; see docs/papers.md.
validateattributes(scores, {'double'}, {'real', 'finite', '2d', 'nonempty'});
scaled = scores / sqrt(size(scores, 2));
J = scaled*scaled';
score_mean = mean(scores, 2);
if any(~isfinite(J(:))) || any(~isfinite(score_mean(:)))
    error('tracking:NumericalRange', 'Sample information is outside the finite numerical range.');
end
J = J/2 + J'/2;
end
