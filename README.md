# PowerSpectR <img src="man/figures/logo.png" align="right" width="120"/>

**Author:** Rafael S. de Souza  
**Email:** [rd23aag@herts.ac.uk](mailto:rd23aag@herts.ac.uk)  
**Affiliation:** University of Hertfordshire — Cosmostatistics Initiative (COIN)

---

## Overview

**PowerSpectR** is an R package for computing and visualizing **robust, median-based Fourier power spectra** from 2-D images.

It provides a simple, reproducible workflow for estimating power-law slopes of spatial structures (e.g. turbulence, galactic morphology, or agricultural texture patterns) using **azimuthally medianized spectra** rather than simple means — improving robustness to outliers, masking artifacts, and bright point sources.

The package is inspired by techniques used in modern astronomical image analysis, including *TurbuStat*, but written natively in R with a clean and modular API.

---

## Key Features

- 🔹 2-D FFT → 1-D **azimuthal median** or quantile power spectrum  
- 🔹 **Log- or linear-spaced** radial bins in k-space  
- 🔹 Multiple **window functions** (Hann, Blackman, none)  
- 🔹 **Power-law slope fitting** on log–log scales with robust regression  
- 🔹 Optional **image inset** and publication-ready `ggplot2` output  
- 🔹 Seamless integration with FITS, TIFF, PNG, or matrix input

---

## Installation

```r
# install directly from GitHub
if (!requireNamespace("remotes")) install.packages("remotes")
remotes::install_github("RafaelSdeSouza/PowerSpectR")


