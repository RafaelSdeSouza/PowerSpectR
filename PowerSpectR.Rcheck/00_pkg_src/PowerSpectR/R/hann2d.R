#' 2-D window generator (Hann/Blackman/none)
#' @param h Height (rows)
#' @param w Width (cols)
#' @param window One of "hann","blackman","none"
#' @return numeric matrix window of size h x w
#' @export
hann2d <- function(h, w, window = c("hann", "blackman", "none")) {
  if (!is.numeric(h) || !is.numeric(w) || length(h) != 1 || length(w) != 1 || h < 1 || w < 1) {
    stop("`h` and `w` must be positive integers.", call. = FALSE)
  }

  window <- match.arg(window)

  make_window_1d <- function(n, type) {
    if (n <= 1) {
      return(1)
    }

    idx <- 0:(n - 1)
    denom <- n - 1

    switch(
      type,
      hann = 0.5 - 0.5 * cos(2 * pi * idx / denom),
      blackman = 0.42 - 0.5 * cos(2 * pi * idx / denom) + 0.08 * cos(4 * pi * idx / denom),
      none = rep(1, n)
    ) |>
      pmax(0)
  }

  hx <- make_window_1d(as.integer(w), window)
  hy <- make_window_1d(as.integer(h), window)

  outer(hy, hx)
}
