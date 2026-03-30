#' Read a grayscale matrix from an image file
#' @param path Path to an image file readable by \pkg{imager}
#' @return numeric matrix
#' @export
read_gray_matrix <- function(path) {
  as.matrix(imager::grayscale(imager::load.image(path)))
}
