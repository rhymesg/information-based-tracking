# Information cycle integration

`test_information_cycle` connects camera geometry, information prediction, independent measurement addition, and CRB inversion.

Two cameras use different angle covariances and a six-state target prior. Summed information must match stacked measurements within 1e-10; posterior information and its inverse must agree with a Joseph-form Gaussian covariance update within 1e-10.

An additional two-parameter linear observation fixture transforms Gaussian/Laplace location scores through `H'` and checks their non-diagonal information matrices within 1e-12. Balanced residuals give exact second moments for this deterministic algebra check; they are not presented as random distribution samples.

The normal test runner includes both cases. They verify information identities, not nonlinear filter performance.
