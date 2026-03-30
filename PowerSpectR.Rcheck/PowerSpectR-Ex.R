pkgname <- "PowerSpectR"
source(file.path(R.home("share"), "R", "examples-header.R"))
options(warn = 1)
library('PowerSpectR')

base::assign(".oldSearch", base::search(), pos = 'CheckExEnv')
base::assign(".old_wd", base::getwd(), pos = 'CheckExEnv')
cleanEx()
nameEx("global_psd")
### * global_psd

flush(stderr()); flush(stdout())

### Name: global_psd
### Title: Compute a global radial power spectrum from an image
### Aliases: global_psd

### ** Examples

img_path <- system.file("extdata", "example_texture.png", package = "PowerSpectR")
res <- global_psd(img_path, nbins = 48, drop_bins = 2, window = "hann", quiet = TRUE)
str(res)



### * <FOOTER>
###
cleanEx()
options(digits = 7L)
base::cat("Time elapsed: ", proc.time() - base::get("ptime", pos = 'CheckExEnv'),"\n")
grDevices::dev.off()
###
### Local variables: ***
### mode: outline-minor ***
### outline-regexp: "\\(> \\)?### [*]+" ***
### End: ***
quit('no')
