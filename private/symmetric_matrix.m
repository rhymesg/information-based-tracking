function A = symmetric_matrix(A, n)
% Validate and symmetrize roundoff-level asymmetry; see docs/algorithm.md.
validateattributes(A, {'double'}, {'real', 'finite', 'size', [n, n]});
scale = max(1, norm(A, 'fro'));
if norm(A - A', 'fro') > 1e-12*scale
    error('tracking:NotSymmetric', 'Information and covariance matrices must be symmetric.');
end
A = A/2 + A'/2;
end
