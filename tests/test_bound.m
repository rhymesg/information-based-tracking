function test_bound
% Analytical inverse and failure checks for CRB interpretation; see tests/README.md.
J = [4, 1; 1, 3];
B = cramer_rao_bound(J);
assert(norm(B - [3, -1; -1, 4]/11, 'fro') < 1e-14, 'Correlated-state analytical bound');
assert(norm(cramer_rao_bound(4*J) - B/4, 'fro') < 1e-14, 'More information reduces the bound');
expect_error(@() cramer_rao_bound(diag([1, 0])), 'tracking:NotPositiveDefinite');
expect_error(@() cramer_rao_bound(diag([1, -1])), 'tracking:NotPositiveDefinite');
expect_error(@() cramer_rao_bound([1, 2; 0, 1]), 'tracking:NotSymmetric');
[~, H] = azimuth_elevation_model([6; 8; 10], [0; 0; 0]);
J_camera = measurement_information(H, eye(2));
expect_error(@() cramer_rao_bound(J_camera), 'tracking:NotPositiveDefinite');
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
