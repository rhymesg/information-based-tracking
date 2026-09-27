# Statistical information calculations

These modules extend the measurement and prediction [core](algorithm.md) with information objectives and non-Gaussian observation information. [Research applications](papers.md) explains their relationship to the mobile-sensor and Monte Carlo CRB repositories.

## Log-determinant cost and derivatives

[logdet_information_cost](../logdet_information_cost.m) accepts a real, finite, symmetric positive-definite `n×n` information matrix `J` and optional symmetric directions `dJ` of size `n×n×K`.

```text
cost = -0.5*ln(det(J))
derivative(k) = -0.5*trace(J \ dJ(:,:,k)).
```

The scalar cost uses `-sum(log(diag(chol(J))))`, avoiding determinant overflow. Optional derivatives form a `K×1` vector; omitting directions returns an empty derivative vector.

- If each direction is `dJ/dq_k`, the output is the cost gradient with respect to `q`.
- If the direction is `J_dot`, the output is the cost rate in the mobile-sensor paper's equation (15).
- For the spatial gradient of that rate, hold the current `J` fixed and pass `dJ_dot/dq_k`. If `J` also varies with `q`, the total derivative includes the derivative of `J^-1`; this call alone does not compute it.

This natural-log objective differs from the existing specialized `d_optimality` objective `-det(J)`, including gradient scale. Compare costs only for identical state coordinates and units; no trajectory, convexity, or steering claim follows from evaluating the objective.

## Stable additive-noise likelihoods

[noise_log_likelihood](../noise_log_likelihood.m) takes a nonempty real finite residual array `r = observation - prediction`, positive standard deviations `sigma` (scalar or exactly the residual shape), and `'gaussian'` or `'laplace'`. Outputs `logp` and `location_score` have the residual shape.

```text
Gaussian: logp = -ln(sigma*sqrt(2*pi)) - 0.5*(r/sigma)^2
          location_score = r/sigma^2
Laplace:  b = sigma/sqrt(2)
          logp = -ln(2*b) - abs(r)/b
          location_score = sign(r)/b.
```

The formulas compute log densities directly; they do not form a tiny density before taking its logarithm. Values are per independent scalar observation, not a joint likelihood for correlated noise.

The score differentiates with respect to the predicted location, holding noise scale fixed. For a vector observation model `h(theta)` with Jacobian `H`, the parameter score is `H' * location_score`; sum channel log densities to obtain the independent joint log likelihood.

Laplace log density is not differentiable at zero residual. The module returns score zero there as a convention; that event has probability zero under the continuous model, and rounded or discrete data need a different likelihood model.

## Monte Carlo information

[monte_carlo_information](../monte_carlo_information.m) accepts a real finite nonempty `p×N` array, one parameter-score column per sample drawn from the model at the evaluation parameter:

```text
s_i = gradient_theta log p(y_i | theta)
J_hat = (1/N) * sum_i s_i*s_i'
score_mean = (1/N) * sum_i s_i.
```

The `p×p` result is an empirical **second moment**, not centered sample covariance; no `N-1` correction is used. The `p×1` mean-score diagnostic should approach zero for a regular model sampled consistently with its score.

The module does not generate observations or evaluate their scores. Each column represents the score of one full observation record; independent replicates can support Monte Carlo averaging, whereas importance samples require appropriate weighting not provided by this API.

The estimate is positive semidefinite and may be singular. Its inverse, when it exists, is a plug-in estimate of inverse information; finite-sample inversion is biased and does not itself provide a guaranteed lower bound. Non-Gaussian conditional observation information also does not establish the full recursive/Bayesian CRB.

For the scalar location model `y = theta + noise` with fixed standard deviation `sigma`, analytic information is `1/sigma^2` for Gaussian noise and `2/sigma^2` for Laplace noise. These fixtures check scale and score conventions without a terrain model or particle filter.

## Validation and errors

All numeric inputs are MATLAB doubles. Malformed numeric values fail MATLAB validation; incompatible shapes raise `tracking:DirectionShape` or `tracking:NoiseShape`, and unsupported distributions raise `tracking:NoiseDistribution`.

The log-determinant module uses the core symmetry tolerance and raises `tracking:NotPositiveDefinite` for singular or indefinite information. Nonfinite computed values raise `tracking:NumericalRange`; extreme scales and ill-conditioning can still lose accuracy without raising an error.
