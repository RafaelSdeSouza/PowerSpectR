#' Azimuthal median of a 2-D power spectrum in radial (k) bins
#'
#' Computes a **1-D radial power spectrum** by taking the **median power** in
#' concentric annuli of the 2-D power image. The 2-D array is FFT-shifted
#' internally so that the zero-frequency component lies at the center before
#' binning. **Bins are linearly spaced in radius**.
#'
#' @param P A numeric matrix giving the 2-D power image (e.g. \code{Mod(fft(img))^2}).
#' @param nbins Integer. Number of radial bins (linearly spaced). Default: \code{72}.
#'
#' @return A tibble with two columns:
#' \describe{
#'   \item{f}{Radial spatial frequency (bin center), in pixel\(^{-1}\) if no scaling is applied.}
#'   \item{psd}{Median power within each radial bin.}
#' }
#'
#' @export
radial_stats_median <- function(P, nbins = 72){
  h <- nrow(P); w <- ncol(P)
  Psh <- fftshift_matrix(P)
  cy <- floor(h/2); cx <- floor(w/2)
  yy <- matrix(rep(0:(h-1), w), nrow = h)
  xx <- matrix(rep(0:(w-1), each = h), nrow = h)
  r  <- as.vector(sqrt((yy - cy)^2 + (xx - cx)^2))
  rmax <- max(r)
  brk <- seq(0, rmax, length.out = nbins + 1)
  bin <- cut(r, brk, labels = FALSE, include.lowest = TRUE)
  v   <- tapply(as.vector(Psh), bin, median, na.rm = TRUE)
  f   <- (head(brk, -1) + tail(brk, -1))/2
  tibble(f = f[!is.na(v)], psd = v[!is.na(v)])
}
