#' 2-D window generator (Hann/Blackman/none)
#' @param h Height (rows)
#' @param w Width (cols)
#' @param window One of "hann","blackman","none"
#' @return numeric matrix window of size h x w
#' @export
hann2d <-  function(h, w){
  hx <- 0.5 - 0.5*cos(2*pi*(0:(w-1))/(w-1))
  hy <- 0.5 - 0.5*cos(2*pi*(0:(h-1))/(h-1))
  outer(hy, hx)
}
