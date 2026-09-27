# Measurement, information, and bounds

This reference defines the core mathematical contracts. [Statistical information](statistical-information.md) covers log-determinant costs and non-Gaussian score estimation; [research applications](papers.md) maps the calculations to the related papers.

## Coordinates and measurements

All numeric inputs are real, finite MATLAB doubles. Positions use a common east-north-up Cartesian frame in metres; angles use radians, with azimuth zero along north and increasing toward east.

For target position `p`, sensor position `q`, and displacement `[e;n;u] = p-q`, define horizontal range `rho = hypot(e,n)` and slant range `r = norm(p-q)`.

```text
2-D: z = [atan2(e,n); rho]
H_AR = [ n/rho^2, -e/rho^2
         e/rho,    n/rho ]

3-D: z = [atan2(e,n); atan2(u,rho)]
H_AE_position = [ n/rho^2,         -e/rho^2,         0
                 -e*u/(r^2*rho),  -n*u/(r^2*rho),   rho/r^2 ]
H_AER_position = [ H_AE_position; e/r, n/r, u/r ].
```

The 3-D models append three zero velocity columns for state order `[e;n;u;ve;vn;vu]`. Jacobians differentiate with respect to target state; `azimuth_range_model` additionally returns `dH(:,:,a)`, the derivative of that Jacobian with respect to sensor coordinate `a`.

Wrap azimuth residuals at ±pi in a filter. Coincident 2-D positions and zero horizontal separation in 3-D are rejected because azimuth is undefined.

## Measurement information

For Gaussian measurement noise with covariance `R` independent of the unknown state:

```text
J_measurement = H' * (R \ H).
```

[measurement_information](../measurement_information.m) accepts a full positive-definite `R`, including correlated channels. For independent sensors, add their information matrices or stack their Jacobians with block-diagonal `R`; correlated sensors require a joint covariance.

[azimuth_range_information](../azimuth_range_information.m) composes the 2-D model for independent sensors with diagonal channel covariance. Its noise inputs are standard deviations, squared internally; it also returns

```text
dJ/dq_i,a = (dH_i/dq_i,a)' * (R_i \ H_i)
           + H_i' * (R_i \ (dH_i/dq_i,a)).
```

These geometry derivatives hold the supplied noise covariances fixed.

Pass a subset of sensor columns for a local neighborhood. Adding overlapping neighborhood information double-counts shared measurements; this toolkit does not implement decentralized fusion protocols.

## Prediction and CRB interpretation

[predict_information](../predict_information.m) propagates full matrices, including cross-target correlations, under linear-Gaussian dynamics:

```text
P_pred = Q + F * (J_prior \ F')
J_pred = P_pred \ I
J_post = J_pred + sum(J_measurement).
```

`J_prior` and `P_pred` must be positive definite; `Q` may be positive semidefinite. Supply `F` and `Q` for the same time interval and state ordering.

[cramer_rao_bound](../cramer_rao_bound.m) returns `B = J \ I`. For a regular likelihood and unbiased estimation of a deterministic parameter, inverse Fisher information is a covariance lower bound; this does not imply that a particular estimator attains it.

For linear-Gaussian conditioning, inverse posterior information is the posterior covariance. For nonlinear measurements, a Jacobian at a supplied state gives local information; its inverse is not automatically an exact Bayesian posterior CRB, which requires the relevant expectations over states and measurements.

A single camera's instantaneous information is rank-deficient. The bound function rejects singular or indefinite information: a pseudoinverse would not establish a finite full-state bound for unobservable directions. Prior information or additional independent observations can make the total matrix invertible.

## Geometry objective

[d_optimality](../d_optimality.m) specializes the 2-D independent azimuth/range calculation:

```text
cost = -det(J)
gradient(a,i) = -det(J) * trace(J \ dJ(:,:,a,i)).
```

Compare determinants only for the same state parameterization and units. The objective is not asserted convex, and it supplies no stand-off, obstacle avoidance, or controller convergence guarantee.

## API shapes

| Function | Inputs | Outputs |
|---|---|---|
| `azimuth_range_model` | `target`, `sensor`: `2×1` | `z`: `2×1`; `H`: `2×2`; `dH`: `2×2×2` |
| `azimuth_elevation_model` | `target`, `sensor`: `3×1` | `z`: `2×1`; `H`: `2×6` |
| `azimuth_elevation_range_model` | Same 3-D positions | `z`: `3×1`; `H`: `3×6` |
| `measurement_information` | `H`: nonempty `m×n`; `R`: `m×m` | `J`: `n×n` |
| `predict_information` | `J`, `F`, `Q`: nonempty `n×n` | `J_pred`, optional `P_pred`: `n×n` |
| `cramer_rao_bound` | `J`: nonempty `n×n` | `B`: `n×n` |
| `azimuth_range_information` | `target`: `2×1`; `sensors`: `2×N`; `noise_std`: `2×1` or `2×N` | `J`: `2×2`; `dJ`: `2×2×2×N` |
| `d_optimality` | Same 2-D sensor inputs | Scalar `cost`; `gradient`: `2×N`; `J`: `2×2` |

## Numerical behavior

Symmetry and process-covariance eigenvalue checks tolerate roundoff at `1e-12*max(1,norm(A,'fro'))`; accepted asymmetry is averaged. Ill-conditioned matrices can lose accuracy even when finite; no regularization or covariance floor is applied.

Invalid shapes fail MATLAB validation. Explicit errors use the `tracking:` prefix: `CoincidentPosition`, `UndefinedAzimuth`, `NoiseShape`, `NotSymmetric`, `NotPositiveDefinite`, `NegativeProcessCovariance`, `SingularPrediction`, `SingularInformation`, or `NumericalRange`. The last identifies nonfinite results or unrepresentable noise variances.
