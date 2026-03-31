args_file <- grep("^--file=", commandArgs(), value = TRUE)
script_dir <- if (length(args_file) > 0) {
  normalizePath(dirname(sub("^--file=", "", args_file[1])), mustWork = TRUE)
} else {
  normalizePath(getwd(), mustWork = TRUE)
}

repo_dir <- normalizePath(file.path(script_dir, ".."), mustWork = TRUE)
fig_dir <- file.path(script_dir, "figures")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)

if (requireNamespace("PowerSpectR", quietly = TRUE)) {
  global_psd_fn <- PowerSpectR::global_psd
} else if (file.exists(file.path(repo_dir, "DESCRIPTION"))) {
  source(file.path(repo_dir, "R", "read_gray_matrix.R"))
  source(file.path(repo_dir, "R", "hann2d.R"))
  source(file.path(repo_dir, "R", "fftshift_matrix.R"))
  source(file.path(repo_dir, "R", "radial_stats_median.R"))
  source(file.path(repo_dir, "R", "global_psd.R"))
  global_psd_fn <- global_psd
} else {
  stop(
    paste(
      "PowerSpectR is not installed and no local package source was found.",
      "From the repository root, run:",
      "remotes::install_local('.')",
      sep = "\n"
    ),
    call. = FALSE
  )
}

source_m101 <- file.path(fig_dir, "hubble_m101_full.jpg")
if (!file.exists(source_m101)) {
  stop("Missing source image: ", source_m101, call. = FALSE)
}

source_m60 <- file.path(repo_dir, "images", "example_elliptical.jpg")
if (!file.exists(source_m60)) {
  stop("Missing source image: ", source_m60, call. = FALSE)
}

target_m60 <- file.path(fig_dir, "hubble_m60_crop.jpg")
invisible(file.copy(source_m60, target_m60, overwrite = TRUE))

m101_ps <- global_psd_fn(source_m101, nbins = 60, drop_bins = 2, window = "hann", quiet = TRUE)
m60_ps <- global_psd_fn(target_m60, nbins = 60, drop_bins = 2, window = "hann", quiet = TRUE)

read_panel_image <- function(path) {
  ext <- tolower(tools::file_ext(path))
  if (ext %in% c("jpg", "jpeg")) {
    return(jpeg::readJPEG(path))
  }

  if (ext == "png") {
    return(png::readPNG(path))
  }

  stop("Unsupported image extension: ", ext, call. = FALSE)
}

image_panel <- function(path, title) {
  img <- read_panel_image(path)
  grob <- grid::rasterGrob(img, interpolate = TRUE)

  cowplot::ggdraw() +
    cowplot::draw_grob(grob, 0.04, 0.05, 0.92, 0.90) +
    cowplot::draw_label(
      title,
      x = 0.12,
      y = 0.90,
      hjust = 0,
      vjust = 1,
      fontface = "bold",
      size = 13,
      color = "white"
    ) +
    ggplot2::theme(plot.margin = ggplot2::margin(8, 8, 8, 8))
}

spectrum_panel <- function(ps_obj, title) {
  rs <- ps_obj$data
  alpha10 <- ps_obj$alpha / log(10)
  rs_log <- transform(rs, lx = log10(f), ly = log10(psd))
  rs_log <- rs_log[order(rs_log$lx), , drop = FALSE]

  x_rng <- range(rs_log$lx)
  y_rng <- range(rs_log$ly)
  beta_label <- sprintf("beta = %.2f", ps_obj$slope)

  ggplot2::ggplot(rs_log, ggplot2::aes(lx, ly)) +
    ggplot2::geom_line(color = "#444444", linewidth = 0.45, alpha = 0.9) +
    ggplot2::geom_point(shape = 21, size = 1.9, stroke = 0.15, fill = "#d89b2d", color = "#8b641e") +
    ggplot2::geom_smooth(
      method = "loess",
      formula = y ~ x,
      fill = "#d8d1c4",
      alpha = 0.55,
      color = "black",
      se = TRUE,
      linewidth = 0.55
    ) +
    ggplot2::geom_abline(
      intercept = alpha10,
      slope = ps_obj$slope,
      color = "#cc554c",
      linewidth = 0.8,
      linetype = 2
    ) +
    ggplot2::annotate(
      "label",
      x = x_rng[2] - 0.04 * diff(x_rng),
      y = y_rng[2] - 0.07 * diff(y_rng),
      label = beta_label,
      hjust = 1,
      vjust = 1,
      linewidth = 0,
      fill = "#ffffff",
      color = "#4a3831",
      size = 3.4
    ) +
    ggplot2::labs(
      x = expression(log[10]~k~(pix^{-1})),
      y = expression(log[10]~P(k))
    ) +
    ggplot2::theme_minimal(base_size = 11.5) +
    ggplot2::theme(
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_line(color = "#e3e3e3", linewidth = 0.35),
      panel.border = ggplot2::element_rect(color = "#d6d6d6", fill = NA, linewidth = 0.6),
      axis.title = ggplot2::element_text(color = "#2b2b2b"),
      axis.text = ggplot2::element_text(color = "#3a3a3a"),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      plot.margin = ggplot2::margin(8, 8, 8, 8)
    )
}

body_grid <- cowplot::plot_grid(
  image_panel(source_m101, "M101"),
  spectrum_panel(m101_ps, "M101"),
  image_panel(target_m60, "M60"),
  spectrum_panel(m60_ps, "M60"),
  ncol = 2,
  align = "hv"
)

figure_plot <- body_grid

png_path <- file.path(fig_dir, "hubble_morphology_mosaic.png")
pdf_path <- file.path(fig_dir, "hubble_morphology_mosaic.pdf")

ggplot2::ggsave(png_path, figure_plot, width = 8.2, height = 7.2, dpi = 400, bg = "white")
ggplot2::ggsave(pdf_path, figure_plot, width = 8.2, height = 7.2, device = grDevices::pdf, bg = "white")

cat(sprintf("M101 slope: %.2f\n", m101_ps$slope))
cat(sprintf("M60 slope: %.2f\n", m60_ps$slope))
cat("Saved:\n")
cat(" - ", png_path, "\n", sep = "")
cat(" - ", pdf_path, "\n", sep = "")
