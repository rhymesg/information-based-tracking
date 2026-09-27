# information-based-tracking

## Overview

[Reusable MATLAB](https://github.com/rhymesg/information-based-tracking) measurement models, Fisher information matrices, Cramér–Rao bounds (CRB), and information-based calculations for target tracking and sensor management.

Use the modules to compare sensor geometry, combine independent measurements, predict information, and evaluate uncertainty under Gaussian or non-Gaussian noise. Four [research applications](docs/papers.md) illustrate decentralized tracking, multisensor management, informative path planning, and Monte Carlo bound calculations.

The decentralized-tracking and multisensor-management research has two related [granted Korean patents](#related-patents).

## Method

Turn a measurement Jacobian and noise covariance into Fisher information, combine independent information contributions, and evaluate local uncertainty bounds or log-determinant objectives. These building blocks connect sensor geometry to tracking and sensing decisions.

### Find a calculation

| Reader's purpose | Public API |
|---|---|
| Predict 2-D azimuth/range and differentiate sensor geometry | [azimuth_range_model](azimuth_range_model.m) |
| Linearize a 3-D camera observation | [azimuth_elevation_model](azimuth_elevation_model.m) |
| Add a range channel to a 3-D observation | [azimuth_elevation_range_model](azimuth_elevation_range_model.m) |
| Calculate information from a measurement Jacobian and covariance | [measurement_information](measurement_information.m) |
| Predict information under linear-Gaussian dynamics | [predict_information](predict_information.m) |
| Invert nonsingular information to obtain a CRB matrix | [cramer_rao_bound](cramer_rao_bound.m) |
| Sum 2-D sensor information and its position derivatives | [azimuth_range_information](azimuth_range_information.m) |
| Evaluate a 2-D D-optimality objective and sensor gradients | [d_optimality](d_optimality.m) |
| Evaluate a log-determinant cost, gradient, or cost rate | [logdet_information_cost](logdet_information_cost.m) |
| Calculate Gaussian/Laplace log densities and location scores | [noise_log_likelihood](noise_log_likelihood.m) |
| Estimate Fisher information from sampled score vectors | [monte_carlo_information](monte_carlo_information.m) |

The [algorithm reference](docs/algorithm.md) specifies array shapes, units, covariance assumptions, singular cases, and bound interpretation.

## Examples

Open this directory as MATLAB's current folder or add it to the MATLAB path. The modules use base MATLAB and require no toolboxes or datasets.

Calculate information and a local position bound from a 2-D azimuth/range sensor:

```matlab
[z, H] = azimuth_range_model([0; 0], [6; 8]);
R = diag([0.1, 2].^2); % Azimuth/range variances: rad^2 and m^2.
J = measurement_information(H, R);
B = cramer_rao_bound(J);
position_std_bound = sqrt(diag(B));
```

Here `B = [2.08, 1.44; 1.44, 2.92]` m². For nonlinear models this is a bound evaluated at the supplied geometry; interpreting it as an exact Bayesian PCRLB requires more than a local Jacobian.

Run the sensor geometry example:

```bash
matlab -batch "example_sensor_geometry"
```

Run the prediction and assigned-target measurement example:

```bash
matlab -batch "example_multitarget_information"
```

Compare Gaussian and Laplace observation information with a reproducible sample-based example:

```bash
matlab -batch "example_nongaussian_information"
```

[Examples and expected results](docs/examples.md) describe the deterministic geometry examples and the seeded Monte Carlo example.

## Implementation scope

The toolkit supplies measurement and information calculations for estimators and planners. Tracking filters, data association, deployment policies, and complete navigation controllers belong to the application layer; see the [paper-to-API mapping](docs/papers.md). The [verification guide](docs/verification.md) describes the analytical and source checks.

### Checks

Run the [test suite](tests/README.md), covering analytical fixtures, finite-difference derivatives, and Gaussian conditioning:

```bash
matlab -batch "addpath('tests'); run_tests"
```

## Papers and citation

The papers are examples of applying these mathematical building blocks. [Research applications](docs/papers.md) maps their equations to the APIs and distinguishes implemented calculations from application-specific algorithms.

Please cite the relevant paper when using its research methods:

- Youngjoo Kim and Hyochoong Bang. “Decentralized Control of Multiple Unmanned Aircraft for Target Tracking and Obstacle Avoidance.” ICUAS 2016, pp. 327–331. [DOI: 10.1109/ICUAS.2016.7502547](https://doi.org/10.1109/ICUAS.2016.7502547).
- Youngjoo Kim and Hyochoong Bang. “Airborne Multisensor Management for Multitarget Tracking.” ICUAS 2015, pp. 751–756. [DOI: 10.1109/ICUAS.2015.7152358](https://doi.org/10.1109/ICUAS.2015.7152358).
- Youngjoo Kim, Wooyoung Jung, and Hyochoong Bang. “Real-time path planning to dispatch a mobile sensor into an operational area.” *Information Fusion*, 45, 27–37, 2019. [DOI: 10.1016/j.inffus.2018.01.010](https://doi.org/10.1016/j.inffus.2018.01.010). [Dedicated repository: mobile-sensor](https://github.com/rhymesg/mobile-sensor).
- Youngjoo Kim and Hyochoong Bang. “Monte-Carlo Calculation of Cramer-Rao Bound for non-Gaussian Recursive Filtering.” APISAT 2017. [Dedicated repository: MC_CRB_nonGaussian](https://github.com/rhymesg/MC_CRB_nonGaussian).

[CITATION.cff](CITATION.cff) contains all four references. General measurement and information identities are not presented as inventions of these papers.

## Related patents

Patent records are listed by [research application](docs/papers.md#related-patents). This toolkit provides mathematical components; the papers' complete navigation controllers and sensor-management policies are not included.

## License

The code and documentation use the [MIT license](LICENSE). Paper citation is requested as academic attribution; the license requires retaining the copyright and permission notices. [Provenance](docs/provenance.md) identifies the source adaptations and reference materials.
