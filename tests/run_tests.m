function run_tests
% Run deterministic module, integration, and example checks; see tests/README.md.
root = fileparts(fileparts(mfilename('fullpath')));
old_path = path;
cleanup = onCleanup(@() path(old_path));
addpath(root, fullfile(root, 'tests'), ...
    fullfile(root, 'tests', 'integration', 'geometry'), ...
    fullfile(root, 'tests', 'integration', 'information'));
test_geometry;
test_models_and_information;
test_bound;
test_statistical_information;
test_geometry_cycle;
test_information_cycle;
example_sensor_geometry;
example_multitarget_information;
example_nongaussian_information;
fprintf('All information-based tracking checks passed.\n');
end
