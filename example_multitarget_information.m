function example_multitarget_information
% Data-free measurement and multitarget prediction/update example; see README.md.
[z, H] = azimuth_elevation_model([6; 8; 10], [0; 0; 0]);
J_measurement = measurement_information(H, 0.01*eye(2));
assert(abs(trace(J_measurement) - 1.5) < 1e-12);
fprintf('Azimuth %.9f rad, elevation %.9f rad\n', z(1), z(2));
fprintf('Single-camera information trace: %.9f\n', trace(J_measurement));

positions = [0, 30; 0, -20; 0, 0];
sensors = [10, 0; 0, 15; 20, 20];
assignment = logical([1, 1; 1, 0]);
F = eye(6); F(1:3, 4:6) = 0.1*eye(3);
Q = diag([0, 0, 0, 0.001, 0.001, 0.001]);
R = diag([0.01, 0.02].^2);
for target = 1:size(positions, 2)
    J = predict_information(eye(6), F, Q);
    for sensor = 1:size(sensors, 2)
        if assignment(sensor, target)
            [~, H] = azimuth_elevation_model(positions(:, target), sensors(:, sensor));
            J = J + measurement_information(H, R);
        end
    end
    P_local = cramer_rao_bound(J);
    fprintf('Target %d position covariance diagonal: %.9f %.9f %.9f\n', ...
        target, P_local(1, 1), P_local(2, 2), P_local(3, 3));
end
end
