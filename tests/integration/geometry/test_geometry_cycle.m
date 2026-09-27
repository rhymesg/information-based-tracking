function test_geometry_cycle
% Measurement-to-information and objective checks; see this directory's README.md.
test_ring;
test_additivity;
test_translation;
for sensor = 1:3
    for axis = 1:2
        test_derivative(sensor, axis);
    end
end
end

function test_ring
theta = (1:8)*2*pi/8;
sensors = 20*[cos(theta); sin(theta)];
[cost, ~, J] = d_optimality([0; 0], sensors, [0.07; 0.5]);
expected_J = (4/0.5^2 + 4/(0.07^2*20^2))*eye(2);
assert(norm(J - expected_J, 'fro') < 1e-10, 'Inverse covariance weighting');
assert(abs(cost + 325.4710537276135) < 1e-9, 'Ring determinant');
end

function test_additivity
target = [2; -3]; sensors = [8, -9, 4; 1, 13, -15];
noise = [0.07, 0.1, 0.05; 0.5, 0.8, 1];
J_all = azimuth_range_information(target, sensors, noise);
J_local = azimuth_range_information(target, sensors(:, [1, 3]), noise(:, [1, 3]));
J_other = azimuth_range_information(target, sensors(:, 2), noise(:, 2));
assert(norm(J_all - J_local - J_other, 'fro') < 1e-12, 'Independent neighborhood contributions');
end

function test_translation
target = [2; -3]; sensors = [8, -9, 4; 1, 13, -15];
noise = [0.07, 0.1, 0.05; 0.5, 0.8, 1];
[cost, gradient, J] = d_optimality(target, sensors, noise);
[cost_shifted, gradient_shifted, J_shifted] = d_optimality(target + [9; -7], ...
    sensors + repmat([9; -7], 1, 3), noise);
assert(abs(cost_shifted - cost) < 1e-10, 'Translation-invariant cost');
assert(norm(gradient_shifted - gradient, 'fro') < 1e-10, 'Translation-invariant gradient');
assert(norm(J_shifted - J, 'fro') < 1e-10, 'Translation-invariant information');
end

function test_derivative(sensor, axis)
target = [2; -3]; sensors = [8, -9, 4; 1, 13, -15];
noise = [0.07, 0.1, 0.05; 0.5, 0.8, 1];
[~, gradient] = d_optimality(target, sensors, noise);
[~, derivatives] = azimuth_range_information(target, sensors, noise);
plus = sensors; minus = sensors;
plus(axis, sensor) = plus(axis, sensor) + 1e-5;
minus(axis, sensor) = minus(axis, sensor) - 1e-5;
[cost_plus, ~, J_plus] = d_optimality(target, plus, noise);
[cost_minus, ~, J_minus] = d_optimality(target, minus, noise);
assert(abs(gradient(axis, sensor) - (cost_plus - cost_minus)/2e-5) < 1e-6, 'Objective sensor gradient');
assert(norm(derivatives(:, :, axis, sensor) - (J_plus - J_minus)/2e-5, 'fro') < 1e-7, 'Information sensor derivative');
end
