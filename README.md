# PowerSpectR <img src="man/figures/logo_ps.png" align="right" width="140" alt="PowerSpectR logo"/>

Robust, median-based Fourier power-spectrum analysis for 2-D images in R.

## Website

The repository now includes a Quarto website in the same visual family as
`sagui`. Render it locally with:

```r
quarto::quarto_render()
```

or from the shell with `quarto render`.

## Overview

**PowerSpectR** computes azimuthally medianized 1-D power spectra from 2-D
images, then fits a power-law slope on log-log axes. The focus is a clean,
reproducible workflow that is more robust to bright outliers, masking
artifacts, and localized structure than a simple azimuthal mean.

Current package capabilities include:

- grayscale image loading through `imager`
- optional 2-D windowing with `"hann"`, `"blackman"`, or `"none"`
- FFT shifting and radial median statistics
- power-law fitting in log space
- publication-friendly plotting with an optional inset image

## Installation

```r
if (!requireNamespace("remotes", quietly = TRUE)) {
  install.packages("remotes")
}

remotes::install_github("RafaelSdeSouza/PowerSpectR")
library(PowerSpectR)
```

## Minimal Example

```r
library(PowerSpectR)

img_path <- system.file(
  "extdata",
  "example_texture.png",
  package = "PowerSpectR"
)

res <- global_psd(
  img_path,
  nbins = 72,
  drop_bins = 2,
  window = "hann"
)

res$slope
head(res$data)

plot_power_spectrum(res, inset_path = img_path)
```

## Core Functions

- `read_gray_matrix()` reads a grayscale image into a numeric matrix.
- `hann2d()` generates a 2-D window for tapering image edges before the FFT.
- `fftshift_matrix()` centers the zero-frequency component.
- `radial_stats_median()` computes the azimuthal median in radial bins.
- `global_psd()` runs the full power-spectrum workflow and slope fit.
- `plot_power_spectrum()` visualizes the fitted profile.


