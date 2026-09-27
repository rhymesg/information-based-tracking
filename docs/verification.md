# Verification status

This report separates mathematical checks from native execution of the MATLAB modules.

| Evidence | Result |
|---|---|
| Static analysis | MISS_HIT lint passes all 22 maintained MATLAB files |
| Citation metadata | CITATION.cff validates against the official CFF 1.2.0 schema |
| 2-D information and geometry derivatives | Independent NumPy calculations confirm the ring and single-sensor fixtures and finite-difference gradients |
| 3-D measurement derivatives | Independent AER finite differences agree within 6e-11 at the test geometry |
| Prediction and independent sensor fusion | Independent calculations match the analytical prediction fixture and Gaussian covariance conditioning |
| CRB fixtures | Independent matrix solves confirm the correlated-state inverse and README position bound |
| Log-determinant and non-Gaussian fixtures | Independent calculations check matrix directional derivatives, likelihood scores, and Gaussian/Laplace information |
| Native MATLAB tests and examples | Not executed: MATLAB is unavailable in the preparation environment |
| GNU Octave compatibility | Not executed or certified |

The mathematical checks use independent formula transcriptions; they do not execute the MATLAB implementation. Paper and repository mappings distinguish extracted models, independent equation implementations, and the alternative score-based estimator.

The [test suite](../tests/README.md) exercises the public functions, including singular-information rejection and comparison of inverse posterior information with a Joseph-form covariance update. Run it in MATLAB and record the version and result before claiming runtime compatibility.

The values in [examples](examples.md) are calculation fixtures, not reproduced paper simulations or measured estimator performance. No datasets are required; the Monte Carlo example uses a fixed seed and restores the caller's random-generator state.
