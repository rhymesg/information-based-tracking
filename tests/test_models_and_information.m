function test_models_and_information
% Deterministic equation checks; see tests/README.md.
check_elevation;
check_information;
check_prediction;
check_failures;
for coordinate = 1:3
    check_measurement_derivative(coordinate);
end
end

function check_elevation
[z, H] = azimuth_elevation_model([6; 8; 10], [0; 0; 0]);
assert(norm(z - [atan2(6, 8); pi/4]) < 1e-12, 'AE measurement convention');
expected = [0.08, -0.06, 0; -0.03, -0.04, 0.05];
assert(norm(H(:, 1:3) - expected, 'fro') < 1e-12, 'Elevation derivative includes slant range');
assert(all(all(H(:, 4:6) == 0)), 'Position measurement has zero velocity derivative');
end

function check_measurement_derivative(coordinate)
target = [7; -2; 15]; sensor = [1; -10; 5];
[~, H] = azimuth_elevation_range_model(target, sensor);
offset = zeros(3, 1); offset(coordinate) = 1e-5;
[z_plus, ~] = azimuth_elevation_range_model(target + offset, sensor);
[z_minus, ~] = azimuth_elevation_range_model(target - offset, sensor);
assert(norm(H(:, coordinate) - (z_plus - z_minus)/2e-5) < 1e-9, 'AER target Jacobian');
end

function check_information
H = [1, 2; 3, 4];
R = [2, 1; 1, 2];
J = measurement_information(H, R);
assert(norm(J - [14/3, 6; 6, 8], 'fro') < 1e-12, 'Correlated-channel covariance solve');
assert(norm(measurement_information(H, 4*R) - J/4, 'fro') < 1e-12, 'Larger noise gives less information');
end

function check_prediction
J = diag([1/2, 1/3]); F = [1, 1; 0, 1]; Q = diag([0, 1]);
[J_pred, P_pred] = predict_information(J, F, Q);
assert(norm(P_pred - [5, 3; 3, 4], 'fro') < 1e-12, 'Covariance propagation');
assert(norm(J_pred - [4, -3; -3, 5]/11, 'fro') < 1e-12, 'Information prediction');
end

function check_failures
expect_error(@() azimuth_elevation_model([0; 0; 10], [0; 0; 0]), 'tracking:UndefinedAzimuth');
expect_error(@() measurement_information(eye(2), [1, 2; 0, 1]), 'tracking:NotSymmetric');
expect_error(@() measurement_information(eye(2), diag([1, 0])), 'tracking:NotPositiveDefinite');
expect_error(@() predict_information(eye(2), eye(2), diag([1, -1])), 'tracking:NegativeProcessCovariance');
expect_error(@() predict_information(eye(2), zeros(2), zeros(2)), 'tracking:SingularPrediction');
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
