function test_statistical_information
% Analytical score moments, stable log densities, and directional derivatives.
check_logdet;
check_logdet_direction;
check_likelihood;
check_score_moments;
check_failures;
end

function check_logdet
[cost, derivative] = logdet_information_cost(diag([4, 9]), eye(2));
assert(abs(cost + log(6)) < 1e-14, 'Natural logarithm with one-half factor');
assert(abs(derivative + 13/72) < 1e-14, 'Trace directional derivative');
cost = logdet_information_cost(diag([1e200, 1e200]));
assert(abs(cost + 200*log(10)) < 1e-12, 'Log determinant must not overflow with determinant');
end

function check_logdet_direction
J = [4, 1; 1, 3];
D = [1, -0.2; -0.2, -1];
[~, derivative] = logdet_information_cost(J, cat(3, D, -D));
finite_difference = (logdet_information_cost(J + 1e-5*D) - ...
    logdet_information_cost(J - 1e-5*D))/2e-5;
assert(abs(derivative(1) - finite_difference) < 1e-9, 'Non-diagonal matrix derivative');
assert(abs(derivative(2) + derivative(1)) < 1e-14, 'Direction indexing');
end

function check_likelihood
[logp, score] = noise_log_likelihood([0, 2, -2], 2, 'gaussian');
assert(norm(logp - (-log(2*sqrt(2*pi)) - [0, 0.5, 0.5])) < 1e-14, 'Gaussian density normalization');
assert(norm(score - [0, 0.5, -0.5]) < 1e-14, 'Score differentiates prediction, not residual');
[logp, score] = noise_log_likelihood([0, 2, -2], 2, 'laplace');
assert(norm(logp - (-log(2*sqrt(2)) - [0, sqrt(2), sqrt(2)])) < 1e-14, 'Laplace standard deviation conversion');
assert(norm(score - [0, 1/sqrt(2), -1/sqrt(2)]) < 1e-14, 'Laplace score and zero convention');
[logp, ~] = noise_log_likelihood(1000, 1, 'gaussian');
assert(abs(logp + 500000 + 0.5*log(2*pi)) < 1e-9, 'Direct log formula avoids density underflow');
[~, score] = noise_log_likelihood([2, 2], [1, 2], 'gaussian');
assert(norm(score - [2, 0.5]) < 1e-14, 'Per-entry standard deviations');
end

function check_score_moments
scores = [1, -1, 3, -3; 2, -2, 0, 0];
[J, mean_score] = monte_carlo_information(scores);
assert(norm(J - [5, 1; 1, 2], 'fro') < 1e-14, 'Mean outer product preserves cross-information');
assert(norm(mean_score) < 1e-14, 'Mean-score diagnostic');
[J, mean_score] = monte_carlo_information([1, 3]);
assert(abs(J - 5) < 1e-14 && abs(mean_score - 2) < 1e-14, 'Do not center or use N-minus-one normalization');
end

function check_failures
expect_error(@() logdet_information_cost(diag([1, 0])), 'tracking:NotPositiveDefinite');
expect_error(@() logdet_information_cost(eye(2), ones(2, 3)), 'tracking:DirectionShape');
expect_error(@() noise_log_likelihood([1, 2], ones(2), 'gaussian'), 'tracking:NoiseShape');
expect_error(@() noise_log_likelihood(1, 1, 'uniform'), 'tracking:NoiseDistribution');
end

function expect_error(action, identifier)
try
    action();
catch exception
    assert(strcmp(exception.identifier, identifier), 'Unexpected error identifier');
    return
end
error('Expected error %s was not raised.', identifier);
end
