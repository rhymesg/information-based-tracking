function [z, H] = azimuth_elevation_model(target, sensor)
% Azimuth/elevation observation, doi:10.1109/ICUAS.2015.7152358, Eqs. (20)-(21).
% State layout and corrected Jacobian: docs/algorithm.md; citation: README.md.
validateattributes(target, {'double'}, {'real', 'finite', 'size', [3, 1]});
validateattributes(sensor, {'double'}, {'real', 'finite', 'size', [3, 1]});
delta = target - sensor;
e = delta(1); n = delta(2); u = delta(3);
rho = hypot(e, n);
r = norm(delta);
if rho == 0
    error('tracking:UndefinedAzimuth', 'Azimuth is undefined at zero horizontal separation.');
end
z = [atan2(e, n); atan2(u, rho)];
H = [n/rho/rho, -e/rho/rho, 0, 0, 0, 0; ...
    -(e/rho)*(u/r)/r, -(n/rho)*(u/r)/r, (rho/r)/r, 0, 0, 0];
if any(~isfinite(z)) || any(~isfinite(H(:)))
    error('tracking:NumericalRange', 'Geometry is outside the finite numerical range.');
end
end
