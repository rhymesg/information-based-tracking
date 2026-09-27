function B = cramer_rao_bound(J)
% Inverse Fisher information for a nonsingular CRB; see docs/algorithm.md.
% Interpretation depends on the supplied information model, not on inversion alone.
validateattributes(J, {'double'}, {'real', 'finite', '2d', 'square', 'nonempty'});
n = size(J, 1);
J = symmetric_matrix(J, n);
[~, failure] = chol(J);
if failure
    error('tracking:NotPositiveDefinite', 'A finite full-state bound requires positive-definite information.');
end
B = J \ eye(n);
if any(~isfinite(B(:)))
    error('tracking:NumericalRange', 'The bound is outside the finite numerical range.');
end
B = B/2 + B'/2;
end
