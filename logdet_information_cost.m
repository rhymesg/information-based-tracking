function [cost, derivative] = logdet_information_cost(J, dJ)
% Log-determinant information cost and directions, doi:10.1016/j.inffus.2018.01.010, (7), (15).
% Direction shapes and rate interpretation: docs/statistical-information.md.
validateattributes(J, {'double'}, {'real', 'finite', '2d', 'square', 'nonempty'});
n = size(J, 1);
J = symmetric_matrix(J, n);
[factor, failure] = chol(J);
if failure
    error('tracking:NotPositiveDefinite', 'Log-determinant cost requires positive-definite information.');
end
cost = -sum(log(diag(factor)));
derivative = [];
if nargin > 1
    validateattributes(dJ, {'double'}, {'real', 'finite', 'nonempty'});
    if ndims(dJ) > 3 || size(dJ, 1) ~= n || size(dJ, 2) ~= n
        error('tracking:DirectionShape', 'Directions must be n-by-n-by-K matrices.');
    end
    derivative = zeros(size(dJ, 3), 1);
    for k = 1:size(dJ, 3)
        direction = symmetric_matrix(dJ(:, :, k), n);
        derivative(k) = -0.5*trace(J \ direction);
    end
end
if ~isfinite(cost) || any(~isfinite(derivative))
    error('tracking:NumericalRange', 'Cost or derivative is outside the finite numerical range.');
end
end
