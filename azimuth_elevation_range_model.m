function [z, H] = azimuth_elevation_range_model(target, sensor)
% Azimuth/elevation/range extension from the supplied multisensor MATLAB archive.
% Relationship to doi:10.1109/ICUAS.2015.7152358: docs/papers.md; citation: README.md.
[angles, H_angles] = azimuth_elevation_model(target, sensor);
delta = target - sensor;
r = norm(delta);
z = [angles; r];
H = [H_angles; delta'/r, zeros(1, 3)];
if any(~isfinite(z)) || any(~isfinite(H(:)))
    error('tracking:NumericalRange', 'Geometry is outside the finite numerical range.');
end
end
