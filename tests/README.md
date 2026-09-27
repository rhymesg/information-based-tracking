# Equation regression checks

The test suite uses analytical fixtures and independent numerical identities to check the public modules.

| Coverage | Failure caught |
|---|---|
| 2-D measurement and sensor derivatives | Wrong azimuth convention, sign, or derivative axis |
| 3-D camera and range Jacobians | Incorrect elevation-height derivative or velocity dependence |
| Correlated measurement covariance | Covariance weighting used in place of inverse covariance weighting |
| Linear prediction | Incorrect matrix order or loss of propagated covariance |
| CRB inversion | Wrong off-diagonal covariance or finite bound returned for singular information |
| Log-determinant objective | Wrong logarithm or scale, determinant overflow, or incorrect directional derivatives |
| Gaussian/Laplace scores | Density underflow, wrong scale conversion, or wrong derivative sign |
| Empirical information | Centered covariance substituted for the score second moment |
| [Geometry composition](integration/geometry/README.md) | Inconsistent neighborhood sums or D-optimality gradients |
| [Information cycle](integration/information/README.md) | Disagreement with Gaussian covariance conditioning |
| Three examples | Failure to compose the public APIs, including seeded non-Gaussian sampling |

Run from the repository root:

```bash
matlab -batch "addpath('tests'); run_tests"
```

The runner restores the MATLAB path, opens no figures, and writes no files. Expected completion is `All information-based tracking checks passed.` Independent analytical checks are described in [verification](../docs/verification.md).
