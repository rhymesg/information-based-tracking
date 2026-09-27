function [J, dJ] = azimuth_range_information(target, sensors, noise_std)
% Measurement Fisher information, doi:10.1109/ICUAS.2016.7502547, Eqs. (3), (23).
% Independent azimuth/range noise; see docs/algorithm.md and README.md for citation.
validateattributes(sensors, {'double'}, {'real', 'finite', '2d', 'nrows', 2, 'nonempty'});
validateattributes(noise_std, {'double'}, {'real', 'finite', '2d', 'nrows', 2, 'positive'});
N = size(sensors, 2);
if size(noise_std, 2) == 1
    noise_std = repmat(noise_std, 1, N);
elseif size(noise_std, 2) ~= N
    error('tracking:NoiseShape', 'noise_std must have one column or one column per sensor.');
end
variances = noise_std.^2;
if any(~isfinite(variances(:))) || any(variances(:) == 0)
    error('tracking:NumericalRange', 'Noise variances must be finite and strictly positive.');
end
J = zeros(2);
dJ = zeros(2, 2, 2, N);
for i = 1:N
    [~, H, dH] = azimuth_range_model(target, sensors(:, i));
    R = diag(variances(:, i));
    J = J + measurement_information(H, R);
    for axis = 1:2
        derivative = dH(:, :, axis);
        dJ(:, :, axis, i) = derivative' * (R \ H) + H' * (R \ derivative);
    end
end
if any(~isfinite(J(:))) || any(~isfinite(dJ(:)))
    error('tracking:NumericalRange', 'Information or its derivatives are outside the finite numerical range.');
end
end
