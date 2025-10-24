#' @export
plot_power_spectrum <- function(ps_obj, inset_path = NULL, show_fit = TRUE) {
  stopifnot(is.list(ps_obj))
  rs     <- ps_obj$data
  alpha  <- ps_obj$alpha
  slope  <- ps_obj$slope
  fname  <- ps_obj$file

  # Prepare log10 data
  alpha10 <- alpha / log(10)
  rs_log  <- dplyr::mutate(rs, lx = log10(f), ly = log10(psd))

  # Main plot
  p <- ggplot2::ggplot(rs_log, ggplot2::aes(lx, ly)) +
    ggplot2::geom_point(size = 2, shape = 21, fill = "orange") +
    ggplot2::geom_smooth(fill = "red3", alpha = 0.5, color = "black", se = TRUE) +
    ggplot2::labs(
      x = expression(log[10]~k~(pix^{-1})),
      y = expression(log[10]~P(k)),
      title = "Radial power spectrum (log–log)",
      subtitle = sprintf("%s slope β = %.2f", "", slope)) +
    ggplot2::theme_minimal(base_size = 13)

  # Add straight power-law line if desired
  if (isTRUE(show_fit)) {
    p <- p +
      ggplot2::geom_abline(intercept = alpha10, slope = slope,
                           color = "red", linewidth = 1, linetype = 2)
  }

  # Optional inset image
  if (!is.null(inset_path) && requireNamespace("cowplot", quietly = TRUE)) {
    p_final <- cowplot::ggdraw() +
      cowplot::draw_plot(p) +
      cowplot::draw_image(inset_path,
                          x = 0.10, y = 0.10, width = 0.40, height = 0.40,
                          hjust = 0, vjust = 0)
    print(p_final)
    invisible(p_final)
  } else {
    print(p)
    invisible(p)
  }
}
