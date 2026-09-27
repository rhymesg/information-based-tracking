function [z, H, dH] = azimuth_range_model(target, sensor)
% Azimuth/range model, doi:10.1109/ICUAS.2016.7502547, Eqs. (21)-(24).
% Contracts and corrected derivative: docs/algorithm.md; citation: README.md.
validateattributes(target, {'double'}, {'real', 'finite', 'size', [2, 1]});
validateattributes(sensor, {'double'}, {'real', 'finite', 'size', [2, 1]});
delta = target - sensor;
x = delta(1); y = delta(2);
r = norm(delta);
if r == 0
    error('tracking:CoincidentPosition', 'Target and sensor must have distinct positions.');
end
direction = delta/r;
ux = direction(1); uy = direction(2);
inverse_r = 1/r;
z = [atan2(x, y); r];
H = [uy*inverse_r, -ux*inverse_r; ux, uy];
dH = zeros(2, 2, 2);
dH(:, :, 1) = [2*ux*uy*inverse_r^2, (uy^2 - ux^2)*inverse_r^2; ...
    -uy^2*inverse_r, ux*uy*inverse_r];
dH(:, :, 2) = [(uy^2 - ux^2)*inverse_r^2, -2*ux*uy*inverse_r^2; ...
    ux*uy*inverse_r, -ux^2*inverse_r];
if any(~isfinite(z)) || any(~isfinite(H(:))) || any(~isfinite(dH(:)))
    error('tracking:NumericalRange', 'Geometry is outside the finite numerical range.');
end
end
