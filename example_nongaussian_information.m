function example_nongaussian_information
% Seeded location-information comparison; see docs/examples.md and docs/statistical-information.md.
old_rng = rng;
cleanup = onCleanup(@() rng(old_rng));
rng(17, 'twister');
sample_count = 100000;
sigma = 2;
gaussian_residual = sigma*randn(1, sample_count);
u = rand(1, sample_count);
u = max(u, realmin);
magnitude = -(sigma/sqrt(2))*log(u);
signs = 2*(rand(1, sample_count) >= 0.5) - 1;
laplace_residual = magnitude .* signs;
[~, gaussian_score] = noise_log_likelihood(gaussian_residual, sigma, 'gaussian');
[~, laplace_score] = noise_log_likelihood(laplace_residual, sigma, 'laplace');
J_gaussian = monte_carlo_information(gaussian_score);
J_laplace = monte_carlo_information(laplace_score);
assert(abs(J_gaussian - 1/sigma^2) < 0.01, 'Gaussian information should approach the analytical value');
assert(abs(J_laplace - 2/sigma^2) < 1e-12, 'Laplace location-score squared is constant almost everywhere');
fprintf('Gaussian information: %.6f; analytical: %.6f\n', J_gaussian, 1/sigma^2);
fprintf('Laplace information: %.6f; analytical: %.6f\n', J_laplace, 2/sigma^2);
fprintf('Plug-in inverse information: Gaussian %.6f, Laplace %.6f\n', ...
    cramer_rao_bound(J_gaussian), cramer_rao_bound(J_laplace));
end
