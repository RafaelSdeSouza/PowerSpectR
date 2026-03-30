#' Compute a global radial power spectrum from an image
#'
#' Reads an image, converts it to grayscale, applies a 2-D window,
#' performs a Fourier transform, computes the azimuthal median of the
#' power spectrum, and fits a power law of the form
#' \eqn{\log P = \alpha + \beta \log k}.
#'
#' @param img_path Character. Path to an image file readable by \pkg{imager}.
#' @param nbins Integer. Number of radial bins passed to
#'   [radial_stats_median()].
#' @param drop_bins Integer. Number of lowest-frequency bins to drop before
#'   fitting.
#' @param window Character. One of `"hann"`, `"blackman"`, or `"none"`.
#' @param quiet Logical. If `FALSE`, report the fitted slope.
#'
#' @return A list containing:
#' \describe{
#'   \item{data}{A tibble of radial frequencies and median power values.}
#'   \item{alpha}{Intercept of the fitted power law in natural log space.}
#'   \item{slope}{Slope (\eqn{\beta}) of the fitted power law.}
#'   \item{file}{Basename of the input image.}
#'   \item{window}{The window that was applied before the FFT.}
#' }
#'
#' @examples
#' img_path <- system.file("extdata", "example_galaxy.png", package = "PowerSpectR")
#' res <- global_psd(img_path, nbins = 24, drop_bins = 1, window = "hann", quiet = TRUE)
#' str(res)
#' @export
global_psd <- function(
  img_path,
  nbins = 72,
  drop_bins = 1,
  window = c("hann", "blackman", "none"),
  quiet = FALSE
) {
  if (!file.exists(img_path)) {
    stop("`img_path` does not exist.", call. = FALSE)
  }

  if (!is.numeric(nbins) || length(nbins) != 1 || is.na(nbins) || nbins < 2) {
    stop("`nbins` must be a single integer greater than or equal to 2.", call. = FALSE)
  }

  if (!is.numeric(drop_bins) || length(drop_bins) != 1 || is.na(drop_bins) || drop_bins < 0) {
    stop("`drop_bins` must be a single non-negative integer.", call. = FALSE)
  }

  window <- match.arg(window)

  x <- read_gray_matrix(img_path)
  x_centered <- x - mean(x, na.rm = TRUE)
  taper <- hann2d(nrow(x), ncol(x), window = window)
  power <- Mod(stats::fft(x_centered * taper))^2
  rs <- radial_stats_median(power, nbins = as.integer(nbins))
  rs <- rs[rs$f > 0 & rs$psd > 0, , drop = FALSE]

  keep <- seq_len(nrow(rs)) > as.integer(drop_bins)
  rs <- rs[keep, , drop = FALSE]

  if (nrow(rs) < 2) {
    stop("Not enough positive radial bins remain after filtering to fit a slope.", call. = FALSE)
  }

  fit <- stats::lm(log(psd) ~ log(f), data = rs)
  alpha <- unname(stats::coef(fit)[1])
  slope <- unname(stats::coef(fit)[2])

  if (!isTRUE(quiet)) {
    message(sprintf("Estimated slope beta = %.2f (log P ~ alpha + beta log k)", slope))
  }

  list(
    data = rs,
    alpha = alpha,
    slope = slope,
    file = basename(img_path),
    window = window
  )
}
