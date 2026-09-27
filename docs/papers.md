# Research applications

These four papers illustrate how measurement geometry and information calculations support tracking, sensor planning, and uncertainty assessment. This toolkit exposes reusable components; the dedicated repositories retain their application-specific source collections.

## Decentralized target tracking

The [2016 paper](../README.md#papers-and-citation) uses information-based objectives within a multi-aircraft navigation controller.

| Reader's purpose | API | Paper equation |
|---|---|---|
| Calculate azimuth/range measurements and target Jacobians | [azimuth_range_model](../azimuth_range_model.m) | (21)–(22) |
| Differentiate geometry with respect to sensor position | Same API, `dH` output | (24), with derivative correction |
| Accumulate local sensor information | [azimuth_range_information](../azimuth_range_information.m) | Measurement term of (3) |
| Evaluate information-based geometry and gradients | [d_optimality](../d_optimality.m) | (4), (10)–(11), (23) |

[example_sensor_geometry](../example_sensor_geometry.m) demonstrates these calculations on a circular sensor array and a local neighborhood. Navigation, obstacle avoidance, and convergence analysis are outside the toolkit.

The published azimuth ratio is implemented with quadrant-preserving `atan2`. Differentiating the measurement Jacobian gives a `y^2` term in the bottom-right sensor-y derivative where printed equation (24) has `x^2`.

The archived source accumulated `H'*R*H`; this toolkit uses inverse covariance weighting `H'*(R\H)`. For eight sensors at radius 20 m and noise standard deviations `[0.07;0.5]`, the corrected negative determinant is approximately `-325.471053728`; the archived weighting gives approximately `-1.000098`, consistent with the paper's reported `-1.0001`.

## Airborne multisensor management

The [2015 paper](../README.md#papers-and-citation) uses information prediction and camera measurements to support deployment timing, target-group selection, and sensor placement.

| Reader's purpose | API | Paper equation |
|---|---|---|
| Calculate camera measurements and state Jacobians | [azimuth_elevation_model](../azimuth_elevation_model.m) | (20)–(21) |
| Accumulate measurement information | [measurement_information](../measurement_information.m) | (12), (24); independent sums in (11), (25) |
| Propagate prior information | [predict_information](../predict_information.m) | Prediction term of (9), (23) |
| Interpret inverse information as an uncertainty bound | [cramer_rao_bound](../cramer_rao_bound.m) | Inverse-information relation in (1); see [interpretation](algorithm.md#prediction-and-crb-interpretation) |

[example_multitarget_information](../example_multitarget_information.m) composes prediction and measurements for explicitly assigned targets. Assignments are illustrative inputs, not outputs of the paper's management algorithm.

The camera elevation derivative with respect to target height is `rho/(rho^2+u^2)`. The archived implementation used `1/rho`; the toolkit corrects it. The separate azimuth/elevation/range model is an archive extension, not the paper's camera example.

The priority/variance score, deployment policy, target-group search, placement optimizer, and sequential EKF are not implemented. The archived experimental scripts differ from the paper in their scores and active sensor model; their policy choices are not adopted here.

## Informative mobile-sensor dispatch

The [2019 Information Fusion paper](../README.md#papers-and-citation) studies dispatching a mobile sensor into an operational area using a two-phase path planner. Its application source is maintained separately in [mobile-sensor](https://github.com/rhymesg/mobile-sensor).

| Reader's purpose | Toolkit API | Paper equation |
|---|---|---|
| Evaluate the natural-log D-optimality cost | [logdet_information_cost](../logdet_information_cost.m) | (7), `-0.5*log(det(J))` |
| Evaluate the cost's time derivative | Same API with `dJ = J_dot` | (15), `-0.5*trace(J\J_dot)` |
| Model a 3-D angle/range observation | [azimuth_elevation_range_model](../azimuth_elevation_range_model.m) | (39), with quadrant-preserving angles and a differentiated Jacobian |

The log-determinant module is independently implemented from the equations using a Cholesky factor and the full information matrix. The [statistical information reference](statistical-information.md) distinguishes cost gradients from the spatial gradient of the cost rate; neither the upstream steering law nor its full path planner is included.

## Monte Carlo non-Gaussian bounds

The [APISAT 2017 paper](../README.md#papers-and-citation) is associated with a one-dimensional terrain-navigation example in [MC_CRB_nonGaussian](https://github.com/rhymesg/MC_CRB_nonGaussian).

| Reader's purpose | Toolkit API | Relationship to the source |
|---|---|---|
| Evaluate Gaussian/Laplace likelihoods without density underflow | [noise_log_likelihood](../noise_log_likelihood.m) | Adapted from `loglikelihood_TRN.m`, with analytic location scores |
| Estimate information by averaging score outer products | [monte_carlo_information](../monte_carlo_information.m) | Related alternative to the upstream perturbation-based negative-Hessian estimator |
| Compare Gaussian and non-Gaussian observation information | [example_nongaussian_information](../example_nongaussian_information.m) | Self-contained scalar location example |

The toolkit estimator uses `mean(score*score')`; it does not reproduce the source's simultaneous perturbation Hessian calculation or recursive bound. Samples and parameter scores are supplied explicitly, leaving the model and sampling distribution to the caller.

The full APISAT paper was unavailable for equation-level inspection; its citation and application description are grounded in the dedicated repository. No paper equation number is asserted for the alternative estimator. Its conditional observation information and plug-in inverse must not be presented as an exact recursive or Bayesian CRB.

## Reuse and attribution

Use the APIs for the stated mathematical purposes and cite the relevant paper when applying its methods. The examples do not validate the papers' full algorithms or reproduce their simulations; [verification](verification.md) records checks of the implemented calculations.
