#' Compute a global medianized radial power spectrum from an image
#'
#' Reads an image, converts it to grayscale, applies a 2-D Hann window,
#' performs a Fourier transform, and computes the azimuthal median
#' of the power spectrum. A simple power-law fit
#' \eqn{\log P = \alpha + \beta \log k} is then estimated.
#'
#' @param img_path Character. Path to the image file readable by \pkg{imager}.
#' @param nbins Integer. Number of radial bins (passed to \code{radial_stats_median()}).
#' @param drop_bins Integer. Number of lowest-frequency bins to drop before fitting.
#'
#' @return A list containing:
#' \describe{
#'   \item{data}{Tibble of radial frequencies and median power values.}
#'   \item{alpha}{Intercept of the fitted power law in natural log space.}
#'   \item{slope}{Slope (\eqn{\beta}) of the power-law fit.}
#'   \item{file}{Basename of the input image.}
#' }
#'
#' @examples
#' \dontrun{
#' img_path <- system.file("extdata", "example.png", package = "yourpkg")
#' res <- global_psd(img_path)
#' str(res)
#' }
#' @export
global_psd <- function(img_path, nbins = 72, drop_bins = 1) {
  X  <- read_gray_matrix(img_path)
  X0 <- X - mean(X, na.rm = TRUE)   # DC removal
  W  <- hann2d(nrow(X), ncol(X))
  Xw <- X0 * W

  P  <- Mod(fft(Xw))^2
  rs <- radial_stats_median(P, nbins) %>%
    filter(psd > 0, row_number() > drop_bins)

  fit   <- lm(log(psd) ~ log(f), data = rs)
  alpha <- unname(coef(fit)[1])
  slope <- unname(coef(fit)[2])

  cat(sprintf("\nEstimated slope β = %.2f (log P ~ α + β log k)\n", slope))

  list(
    data = rs,
    alpha = alpha,
    slope = slope,
    file = basename(img_path)
  )
}
