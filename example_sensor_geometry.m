function example_sensor_geometry
% Deterministic multisensor and neighborhood calculations; see README.md.
target = [0; 0];
noise_std = [0.07; 0.5];
theta = (1:8)*2*pi/8;
sensors = 20*[cos(theta); sin(theta)];
[cost, gradient, J] = d_optimality(target, sensors, noise_std);
assert(abs(cost + 325.4710537276135) < 1e-9);
assert(norm(J - 18.0408163265306*eye(2), 'fro') < 1e-10);
fprintf('Eight-sensor information diagonal: %.9f, %.9f\n', J(1, 1), J(2, 2));
B = cramer_rao_bound(J);
[~, dJ] = azimuth_range_information(target, sensors, noise_std);
[log_cost, sensor1_gradient] = logdet_information_cost(J, dJ(:, :, :, 1));
fprintf('Log-determinant cost: %.9f; sensor 1 gradient: %.9f %.9f\n', ...
    log_cost, sensor1_gradient(1), sensor1_gradient(2));
fprintf('Local position CRB diagonal: %.9f, %.9f m^2\n', B(1, 1), B(2, 2));
fprintf('D-optimality cost: %.9f\n', cost);
assert(norm(gradient(:, 1) - 0.920449812578092*sensors(:, 1)/20) < 1e-10);
fprintf('Sensor 1 radial cost derivative: %.9f\n', norm(gradient(:, 1)));

neighbors = [1, 2, 8];
J_local = azimuth_range_information(target, sensors(:, neighbors), noise_std);
[z, H] = azimuth_range_model([6; 8], [0; 0]);
assert(norm(z - [atan2(6, 8); 10]) < 1e-12);
fprintf('Three-neighbor information trace: %.9f\n', trace(J_local));
fprintf('Measurement: azimuth %.9f rad, range %.1f m\n', z(1), z(2));
assert(norm(H - [0.08, -0.06; 0.6, 0.8], 'fro') < 1e-12);
end
