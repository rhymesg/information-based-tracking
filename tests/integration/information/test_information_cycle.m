function test_information_cycle
% Connect bearing geometry, information addition and covariance conditioning.
P = diag([4, 9, 16, 1, 1, 1]);
F = eye(6); F(1:3, 4:6) = 0.1*eye(3);
Q = diag([0, 0, 0, 0.01, 0.01, 0.01]);
[J_pred, P_pred] = predict_information(P \ eye(6), F, Q);
[~, H1] = azimuth_elevation_model([0; 0; 0], [10; 0; 20]);
[~, H2] = azimuth_elevation_model([0; 0; 0], [0; 15; 20]);
R1 = diag([0.01, 0.02].^2); R2 = diag([0.02, 0.03].^2);
J_meas = measurement_information(H1, R1) + measurement_information(H2, R2);
H = [H1; H2]; R = blkdiag(R1, R2);
assert(norm(J_meas - measurement_information(H, R), 'fro') < 1e-10, 'Independent-sensor additivity');
J_post = J_pred + J_meas;
K = (P_pred*H') / (H*P_pred*H' + R);
A = eye(6) - K*H;
P_post = A*P_pred*A' + K*R*K';
assert(norm(J_post*P_post - eye(6), 'fro') < 1e-10, 'Information matches Gaussian covariance update');
assert(norm(cramer_rao_bound(J_post) - P_post, 'fro') < 1e-10, 'Bound agrees with Gaussian posterior covariance');
check_likelihood_score_composition;
end

function check_likelihood_score_composition
H = [1, 2; 3, 1];
residuals = [2, -2, 2, -2; 2, 2, -2, -2];
[~, gaussian_scores] = noise_log_likelihood(residuals, 2, 'gaussian');
[~, laplace_scores] = noise_log_likelihood(residuals, 2, 'laplace');
J_gaussian = monte_carlo_information(H'*gaussian_scores);
J_laplace = monte_carlo_information(H'*laplace_scores);
assert(norm(J_gaussian - [2.5, 1.25; 1.25, 1.25], 'fro') < 1e-12, 'Multi-parameter Gaussian score information');
assert(norm(J_laplace - [5, 2.5; 2.5, 2.5], 'fro') < 1e-12, 'Multi-parameter Laplace score information');
end
