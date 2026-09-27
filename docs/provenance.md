# Source provenance

The toolkit consolidates corrected mathematical modules from the local `decentralized-target-tracking` and `multisensor-management` projects. Their MIT notices are preserved in [LICENSE](../LICENSE); public API names now describe the calculations.

The supplied historical sources and papers supported mathematical inspection. The toolkit exposes revised modules with explicit inputs, tests, and the documented [equation corrections](papers.md); it is not an unmodified archival release.

## Reference material

| Application | Supplied PDF | Fingerprints |
|---|---|---|
| Decentralized tracking | `0048.pdf` | [Paper and nine archived source files](decentralized-source-snapshot.json) |
| Airborne multisensor management | `AirborneMultisensorManagementforMultitargetTrackingICUAS201520150611.pdf` | [Paper and 25 archived files](multisensor-source-snapshot.json) |

The manifests describe the original input snapshots, not the new toolkit's file contents. Extracted reference copies matched their archives during inspection; archive timestamps do not establish revision order.

Reference PDFs and original archives remain in the source projects' local `ref/` directories and are not bundled or relicensed. All examples and tests run from synthetic inputs included here. Bibliographic references are in [CITATION.cff](../CITATION.cff).

## Additional public research repositories

- [mobile-sensor at 78c6d4a](https://github.com/rhymesg/mobile-sensor/tree/78c6d4ad8f61bdff6597c4fe9d0a26e4b35349dd) supplies the application context for the Information Fusion paper. The log-determinant cost and derivative are independently implemented from its equations (7) and (15); no unlicensed source routine is copied.
- [MC_CRB_nonGaussian at fd7df2f](https://github.com/rhymesg/MC_CRB_nonGaussian/tree/fd7df2f1899965aee68adc1c58ce78a3d5e8d77e) supplies the Gaussian/Laplace likelihood model. `noise_log_likelihood` adapts [loglikelihood_TRN.m](https://github.com/rhymesg/MC_CRB_nonGaussian/blob/fd7df2f1899965aee68adc1c58ce78a3d5e8d77e/loglikelihood_TRN.m) with stable log formulas and scores; its 2020 Youngjoo Kim MIT notice is retained in LICENSE.

The upstream Monte Carlo repository credits Sonjoy Das for `estimateFIM.html` and Elvis Chen in `laprnd.m`. Neither file is copied; this toolkit's empirical score-moment calculation and example sampler are independent implementations. The upstream simultaneous perturbation Hessian algorithm and recursive demonstration remain in the dedicated repository.
