function test_geometry
% Deterministic numerical regression checks; see tests/README.md.
test_measurement;
test_large_geometry;
test_single_sensor;
test_invalid_geometry;
for axis = 1:2
    test_measurement_derivative(axis);
end
end

function test_measurement
[z, H] = azimuth_range_model([4; 9], [-2; 1]);
assert(norm(z - [atan2(6, 8); 10]) < 1e-12, 'Azimuth/range convention');
assert(norm(H - [0.08, -0.06; 0.6, 0.8], 'fro') < 1e-14, 'Target Jacobian');
[z, ~] = azimuth_range_model([-6; -8], [0; 0]);
assert(abs(z(1) - atan2(-6, -8)) < 1e-14, 'Azimuth must preserve quadrant');
end

function test_large_geometry
[z, H, derivatives] = azimuth_range_model([6e100; 8e100], [0; 0]);
assert(abs(z(2)/1e101 - 1) < 1e-14, 'Large representable range');
assert(norm(H(1, :)/1e-101 - [0.8, -0.6]) < 1e-14, 'Scaled azimuth derivative');
assert(abs(derivatives(1, 1, 1)/1e-202 - 0.96) < 1e-14, 'Scaled sensor derivative');
end

function test_measurement_derivative(axis)
target = [4; 9]; sensor = [-2; 1];
[~, H, derivatives] = azimuth_range_model(target, sensor);
offset = zeros(2, 1); offset(axis) = 1e-5;
[z_plus, ~] = azimuth_range_model(target + offset, sensor);
[z_minus, ~] = azimuth_range_model(target - offset, sensor);
assert(norm(H(:, axis) - (z_plus - z_minus)/2e-5) < 1e-9, 'Target measurement derivative');
[~, H_plus] = azimuth_range_model(target, sensor + offset);
[~, H_minus] = azimuth_range_model(target, sensor - offset);
assert(norm(derivatives(:, :, axis) - (H_plus - H_minus)/2e-5, 'fro') < 1e-9, 'Sensor Jacobian derivative');
end

function test_single_sensor
[cost, gradient] = d_optimality([0; 0], [6; 8], [0.1; 2]);
assert(abs(cost + 0.25) < 1e-12, 'Single-sensor information determinant');
assert(norm(gradient - [0.03; 0.04]) < 1e-12, 'Single-sensor radial cost derivative');
J = azimuth_range_information([0; 0], [6; 8], [0.1; 2]);
J_noisier = azimuth_range_information([0; 0], [6; 8], [0.2; 4]);
assert(norm(J_noisier - J/4, 'fro') < 1e-12, 'More noise must reduce information');
end

function test_invalid_geometry
expect_error(@() azimuth_range_model([0; 0], [0; 0]), 'tracking:CoincidentPosition');
expect_error(@() azimuth_range_information([0; 0], [1; 2], ones(2, 3)), 'tracking:NoiseShape');
expect_error(@() azimuth_range_information([0; 0], [1; 2], [realmin; realmin]), 'tracking:NumericalRange');
end

function expect_error(action, identifier)
try
    action();
catch exception
    assert(strcmp(exception.identifier, identifier), 'Unexpected error identifier');
    return
end
error('Expected error %s was not raised.', identifier);
end
