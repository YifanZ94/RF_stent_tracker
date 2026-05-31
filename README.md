# RF Stent Tracker

Code and data companion for the peer-reviewed publications on RF-based stent localization using neural network classifiers.


## Overview

This repository contains the signal processing pipelines, neural network training scripts, and hardware documentation for a system that localizes an implanted stent using radio-frequency (RF) measurements. Received RF signals are preprocessed and fed to a pattern recognition classifier to infer stent position or orientation category from a 41-feature signal vector.

The codebase covers:
- MATLAB-based pattern recognition with a feedforward neural network (`patternnet`)
- PyTorch deep learning pipeline with a Mask Denoiser (Noise2Self) + stacked LSTM classifier
- Noise robustness experiments under Gaussian and sinusoidal disturbance
- Hardware documentation for the RF measurement setup

---


## Data

The scripts expect the following data files (not included in this repository due to size):

| File | Used by | Contents |
|---|---|---|
| `RF_data_for_NN_oneLoop.mat` | MATLAB scripts | Feature matrix `x` (41×750) and one-hot labels `t` |
| `data_for_pytorch.npz` | Python notebook | Arrays `features` (41×750) and `labels` (750,) |

---

## Hardware

The `Hardware/` folder contains schematics, antenna layout diagrams, and setup notes for the benchtop RF measurement system used to collect the localization dataset.

---

## Citation

If you use this code or data in your work, please cite:

```bibtex
@article{zhang2026location,
  title={Location Tracking of a Radio-Wave Antenna Utilizing the Radiation Pattern Recognized by Deep Network},
  author={Zhang, Yifan and Clark, William W and Tillman, Bryan and Chun, Young Jae and Cho, Sung Kwon},
  journal={Sensors},
  volume={26},
  number={9},
  pages={2867},
  year={2026},
  publisher={MDPI}
}


```

---

## License

This project is licensed under the MIT License. See [`LICENSE`](LICENSE) for details.
