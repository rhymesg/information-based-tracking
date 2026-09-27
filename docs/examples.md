# Worked calculations

These examples demonstrate module composition without datasets or paper-specific experimental policies. Geometry examples are deterministic; the Monte Carlo example uses an explicit seed and restores the caller's random-generator state.

## Sensor geometry

Run [example_sensor_geometry](../example_sensor_geometry.m) from the repository root:

```bash
matlab -batch "example_sensor_geometry"
```

Eight 2-D azimuth/range sensors surround a target at radius 20 m, with azimuth standard deviation 0.07 rad and range standard deviation 0.5 m. The example computes total information, its inverse, the D-optimality sensor gradient, and information from neighbors `[1,2,8]`.

Expected quantities:

```text
J = 18.0408163265306 * I
B = (1/18.0408163265306) * I m^2
-det(J) = -325.4710537276135
Sensor 1 radial cost derivative = 0.920449812578092
Three-neighbor information trace = 13.53061224489796
```

This is a geometry evaluation, not a controller or a decentralized communication simulation.

The example also evaluates the natural-log information cost and sensor 1's position derivatives through `logdet_information_cost`. This uses the mobile-sensor paper's objective with the toolkit's 2-D sensor model, rather than reproducing that paper's trajectory.

## Assigned-target information cycle

Run [example_multitarget_information](../example_multitarget_information.m):

```bash
matlab -batch "example_multitarget_information"
```

First, a camera at the origin observes `[6;8;10]` with angle covariance `0.01*eye(2)` rad². Azimuth is `0.643501109` rad, elevation is `0.785398163` rad, and information trace is `1.5`.

Then two cameras observe two independent targets according to a supplied assignment matrix. Each target has a six-state prior, a 0.1 s constant-velocity transition, and an illustrative velocity process covariance; the code supplies all parameters explicitly.

After prediction and information addition, the inverse-information position diagonals are approximately:

```text
Target 1: [0.02072274, 0.00976091, 0.30178805] m^2
Target 2: [0.42795907, 0.42795907, 0.55357942] m^2
```

These are local linearized covariance values. The example does not run an estimator or claim achieved tracking accuracy.

## Non-Gaussian location information

Run [example_nongaussian_information](../example_nongaussian_information.m):

```bash
matlab -batch "example_nongaussian_information"
```

The example draws 100,000 scalar residuals for each noise distribution using seed 17 and the Twister generator. Both distributions have standard deviation 2; the location parameter has analytical information `0.25` for Gaussian noise and `0.5` for Laplace noise.

The empirical Gaussian result should be within `0.01` of `0.25`. Every nonzero Laplace residual has squared location score `0.5`, so its empirical result agrees to floating-point precision.

Corresponding plug-in inverse-information estimates are approximately `4` and `2`. This checks observation information under different likelihoods, not a recursive terrain-navigation bound or particle-filter accuracy.
