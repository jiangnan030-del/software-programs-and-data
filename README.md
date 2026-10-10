# MMCHB Criterion MATLAB App

MATLAB App for fitting and visualizing the MMCHB rock-strength criterion, with Dunham dolomite triaxial-test data and reproducible run results.

## Contents

- `MMCHB_criterion.m` — original MATLAB App source.
- `Dunham dolomite.xlsx` / `Dunham dolomite.txt` — 53 three-dimensional stress data points in MPa (`sigma1`, `sigma2`, `sigma3`).
- `结果/` — fitting outputs, convergence curves, diagnostic tables, figures, logs, and the standalone reproducibility script.

## Environment

- MATLAB R2023a tested (`9.14.0.2206163`)
- Uses MATLAB App/UI, numerical, plotting, and file I/O functions; additional environment compatibility has not been tested.

## Run the app

1. Open MATLAB.
2. Set the current folder to the repository root.
3. Run:

```matlab
MMCHB_criterion
```

The app can load the TXT or Excel data file, optimize the model parameters, display the three-dimensional envelope and stress-plane plots, and export figures/results.

## Reproduce the included results

The standalone script is:

```matlab
addpath('结果');
run_mmchb_results
```

The script was tested with the Dunham Excel/TXT files, `UCS = 257 MPa`, `mi = 33.28`, fixed seed `20261010`, population size `30`, and `100` iterations. It writes result files into the `结果/` directory. Review the script's `projectDir` if the repository is located elsewhere.

The included main POA run reports:

- alpha = 1
- gamma = 0.9903714406103078
- u = 1.077875475770729
- v = 1.6590229470310487
- normalized sqrt(J2) RMSE = 4.027058988119201%

The score is the normalized RMSE of the model residual in `sqrt(J2)` space. It is not a sigma1 prediction error and is not an independent test-set score.

## Important limitations

This repository preserves the original program and its original optimization implementations. The results directory documents known limitations, including simplified or renamed metaheuristic implementations, numerical edge cases, and the fact that `mi` was not independently recalibrated for the Dunham data. The included results are reproducible exploratory results, not a claim that one optimizer is universally superior.

The repository is public. The stress data and generated results are intentionally visible to anyone who can access the repository. Do not commit access tokens, passwords, private keys, or other credentials.

## License

No license has been selected yet. Until a license is added, normal copyright restrictions apply.
