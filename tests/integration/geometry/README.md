# Sensor geometry integration

`test_geometry_cycle` connects the azimuth/range model, sensor information, and D-optimality gradient.

- An eight-sensor ring checks analytical inverse covariance weighting and determinant values.
- Three sensors with heterogeneous noise check additive neighborhood information and translation invariance.
- Central differences at 1e-5 m check sensor gradients within 1e-6 and information derivatives within 1e-7.

The normal test runner includes these deterministic cases; no external data is required.
