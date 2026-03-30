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
#'   \item{f}{Radial spatial frequency (bin center), in reciprocal pixels if no scaling is applied.}
#'   \item{psd}{Median power within each radial bin.}
#' }
#'
#' @export
radial_stats_median <- function(P, nbins = 72) {
  if (!is.matrix(P)) {
    stop("`P` must be a matrix.", call. = FALSE)
  }

  if (!is.numeric(nbins) || length(nbins) != 1 || is.na(nbins) || nbins < 1) {
    stop("`nbins` must be a single integer greater than or equal to 1.", call. = FALSE)
  }

  h <- nrow(P)
  w <- ncol(P)
  p_shifted <- fftshift_matrix(P)
  cy <- floor(h / 2)
  cx <- floor(w / 2)
  yy <- row(p_shifted) - 1
  xx <- col(p_shifted) - 1
  r <- as.vector(sqrt((yy - cy)^2 + (xx - cx)^2))
  rmax <- max(r)
  brk <- seq(0, rmax, length.out = as.integer(nbins) + 1)
  bin <- cut(r, brk, labels = FALSE, include.lowest = TRUE)
  v <- tapply(as.vector(p_shifted), bin, stats::median, na.rm = TRUE)
  f <- (utils::head(brk, -1) + utils::tail(brk, -1)) / 2

  tibble::tibble(f = f[!is.na(v)], psd = v[!is.na(v)])
}
