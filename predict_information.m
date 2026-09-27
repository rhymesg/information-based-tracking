function [J_pred, P_pred] = predict_information(J, F, Q)
% Linear-Gaussian information prediction, doi:10.1109/ICUAS.2015.7152358, Eqs. (9), (23).
% Supply the full transition and process covariance; see docs/algorithm.md and README.md.
validateattributes(J, {'double'}, {'real', 'finite', '2d', 'square', 'nonempty'});
n = size(J, 1);
J = symmetric_matrix(J, n);
Q = symmetric_matrix(Q, n);
validateattributes(F, {'double'}, {'real', 'finite', 'size', [n, n]});
[~, failure] = chol(J);
if failure
    error('tracking:NotPositiveDefinite', 'Prior information must be positive definite.');
end
if min(eig(Q)) < -1e-12*max(1, norm(Q, 'fro'))
    error('tracking:NegativeProcessCovariance', 'Process covariance must be positive semidefinite.');
end
P_pred = Q + F*(J \ F');
if any(~isfinite(P_pred(:)))
    error('tracking:NumericalRange', 'Predicted covariance is outside the finite numerical range.');
end
P_pred = P_pred/2 + P_pred'/2;
[~, failure] = chol(P_pred);
if failure
    error('tracking:SingularPrediction', 'Predicted covariance must be positive definite.');
end
J_pred = P_pred \ eye(n);
if any(~isfinite(J_pred(:)))
    error('tracking:NumericalRange', 'Predicted information is outside the finite numerical range.');
end
J_pred = J_pred/2 + J_pred'/2;
end
