rm(list=ls())
library(oro.nifti)
options(error = quote(print("Error Ocurred")))
URL <- "http://imaging.mrc-cbu.cam.ac.uk/downloads/Colin/colin_1mm.tgz"
urlfile <- file.path("~/Desktop/scratch/", "colin_1mm.tgz")
if (!file.exists(urlfile)){
  download.file(URL, dest=urlfile, quiet=TRUE)
  untar(urlfile, exdir=path.expand("~/Desktop/scratch/"))
}
img <- readNIfTI(file.path("~/Desktop/scratch/", "colin_1mm"), verbose=TRUE)
img_corr <- readNIfTI(file.path("~/Desktop/scratch/", "ncolin_1mm"), 
                      verbose=TRUE)

tfile = tempfile()
### error about dimensions and cal_max/min
writeNIfTI(img, filename = tfile, verbose=TRUE)
library(fslr)
## set cal_max/min
img = cal_img(img)
writeNIfTI(img, filename = tfile, verbose=TRUE)
### drop empty dimension
img = drop_img_dim(img)
writeNIfTI(img, filename = tfile, verbose=TRUE)

### try to read it back in - nope
img2 = readNIfTI(tfile, verbose=TRUE)
file.remove(paste0(tfile, ".nii.gz"))
writeNIfTI(img, filename = tfile, onefile = FALSE, verbose=TRUE)

file.exists(paste0(tfile, ".nii"))
file.exists(paste0(tfile, ".nii.gz"))
file.exists(paste0(tfile, ".hdr"))
file.exists(paste0(tfile, ".img"))

### try to read it back in - nope
img2 = readNIfTI(tfile, verbose=TRUE)
file.remove(paste0(tfile, ".nii.gz"))

writeNIfTI(img, filename = tfile, onefile = FALSE, gzipped = FALSE,
           verbose=TRUE)

file.exists(paste0(tfile, ".nii"))
file.exists(paste0(tfile, ".nii.gz"))
file.exists(paste0(tfile, ".hdr"))
file.exists(paste0(tfile, ".img"))

### try to read it back in - nope
img2 = readNIfTI(tfile, verbose=TRUE)
file.remove(paste0(tfile, ".nii"))

img@magic

img@magic = "n+1"
img@vox_offset = 352

# img = newnii(img, trybyte = FALSE)
img = newnii(img, trybyte = TRUE, 
             datatype = convert.datatype()$FLOAT32,
             bitpix = convert.bitpix()$FLOAT32)

writeNIfTI(img, filename = tfile, verbose=TRUE)
