#' Read a grayscale matrix from an image file
#' @param path Path to an image file readable by \pkg{imager}
#' @return numeric matrix
#' @export
read_gray_matrix <- function(path) {
  img <- imager::load.image(path)
  arr <- as.array(img)

  if (length(dim(arr)) == 2) {
    return(arr)
  }

  if (length(dim(arr)) >= 4 && dim(arr)[4] >= 3) {
    img <- tryCatch(
      imager::grayscale(img),
      error = function(...) img
    )
    arr <- as.array(img)
  }

  as.matrix(arr[, , 1, 1])
}
