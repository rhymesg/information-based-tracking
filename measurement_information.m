function J_meas = measurement_information(H, R)
% Independent measurement information, doi:10.1109/ICUAS.2015.7152358, Eqs. (12), (24).
% Full covariance is supported; see docs/algorithm.md and README.md for citation.
validateattributes(H, {'double'}, {'real', 'finite', '2d', 'nonempty'});
R = symmetric_matrix(R, size(H, 1));
[~, failure] = chol(R);
if failure
    error('tracking:NotPositiveDefinite', 'Measurement covariance must be positive definite.');
end
J_meas = H'*(R \ H);
if any(~isfinite(J_meas(:)))
    error('tracking:NumericalRange', 'Measurement information is outside the finite numerical range.');
end
J_meas = J_meas/2 + J_meas'/2;
end
