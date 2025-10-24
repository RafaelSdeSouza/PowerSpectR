#' FFT-shift a matrix (move zero-frequency to center)
#' @param M numeric matrix
#' @return matrix with quadrants swapped
#' @export
fftshift_matrix <- function(M){
  h <- nrow(M); w <- ncol(M)
  M[c((h%/%2+1):h, 1:(h%/%2)),
    c((w%/%2+1):w, 1:(w%/%2))]
}
