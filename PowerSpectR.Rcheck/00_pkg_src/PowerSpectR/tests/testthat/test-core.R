test_that("hann2d supports documented window types", {
  hann_window <- hann2d(8, 6, window = "hann")
  blackman_window <- hann2d(8, 6, window = "blackman")
  none_window <- hann2d(8, 6, window = "none")

  expect_equal(dim(hann_window), c(8, 6))
  expect_equal(dim(blackman_window), c(8, 6))
  expect_equal(none_window, matrix(1, nrow = 8, ncol = 6))
  expect_true(all(hann_window >= 0))
  expect_true(all(blackman_window >= 0))
})

test_that("global_psd analyzes a generated PNG image", {
  skip_if_not_installed("imager")

  tmp_png <- tempfile(fileext = ".png")
  x <- seq(-1, 1, length.out = 96)
  y <- seq(-1, 1, length.out = 96)
  img <- outer(
    y,
    x,
    function(yy, xx) {
      exp(-4 * (xx^2 + yy^2)) + 0.20 * sin(10 * xx) * cos(6 * yy)
    }
  )

  grDevices::png(tmp_png, width = 480, height = 480)
  graphics::par(mar = c(0, 0, 0, 0))
  graphics::image(
    x,
    y,
    img[nrow(img):1, ],
    col = grDevices::gray.colors(160, start = 0, end = 1),
    axes = FALSE,
    xlab = "",
    ylab = "",
    useRaster = TRUE
  )
  grDevices::dev.off()

  res <- global_psd(tmp_png, nbins = 40, drop_bins = 2, window = "hann", quiet = TRUE)
  plt <- plot_power_spectrum(res, show_fit = TRUE)

  expect_true(all(c("data", "alpha", "slope", "file", "window") %in% names(res)))
  expect_s3_class(res$data, "tbl_df")
  expect_true(is.numeric(res$slope))
  expect_s3_class(plt, "ggplot")
})
