function [cost, gradient, J] = d_optimality(target, sensors, noise_std)
% Negative determinant objective, doi:10.1109/ICUAS.2016.7502547, Eqs. (4), (11).
% Sensor-position gradient for supplied neighbors; see docs/algorithm.md and README.md.
[J, dJ] = azimuth_range_information(target, sensors, noise_std);
[~, not_positive_definite] = chol(J);
if not_positive_definite
    error('tracking:SingularInformation', 'Information matrix must be positive definite.');
end
cost = -det(J);
gradient = zeros(size(sensors));
for i = 1:size(sensors, 2)
    for axis = 1:2
        gradient(axis, i) = cost * trace(J \ dJ(:, :, axis, i));
    end
end
if ~isfinite(cost) || any(~isfinite(gradient(:)))
    error('tracking:NumericalRange', 'Objective or gradient is outside the finite numerical range.');
end
end
