rm(list=ls())
library(oro.nifti)
# options(error = quote(print("Error Ocurred")))
URL <- "http://imaging.mrc-cbu.cam.ac.uk/downloads/Colin/colin_1mm.tgz"
urlfile <- file.path("~/Desktop/scratch/", "colin_1mm.tgz")
# if (!file.exists(urlfile)){
  download.file(URL, dest=urlfile, quiet=TRUE)
  untar(urlfile, exdir=path.expand("~/Desktop/scratch/"))
# }
img <- readNIfTI(file.path("~/Desktop/scratch/", "colin_1mm"), verbose=TRUE)
# img_corr <- readNIfTI(file.path("~/Desktop/scratch/", "ncolin_1mm"), 
#                       verbose=TRUE)

tfile = tempfile()
### error about dimensions and cal_max/min - readNIfTI does not correct
## Cal_ax cal_min
writeNIfTI(img, filename = tfile, verbose=TRUE)
library(fslr)
## set cal_max/min to be correct (range of the data)
img = cal_img(img)
writeNIfTI(img, filename = tfile, verbose=TRUE)
dim(img)
img@dim_
pixdim(img)
### drop empty dimension - setting the extra dim to 0 and pixdim of those to 0
img = drop_img_dim(img)
dim(img)
img@dim_
pixdim(img)
### data writes out fine
writeNIfTI(img, filename = tfile, verbose=TRUE)
# ni1 magic
img@magic

### try to read it back in - nope
img2 = readNIfTI(tfile, verbose=TRUE)
file.remove(paste0(tfile, ".nii.gz"))
writeNIfTI(img, filename = tfile, onefile = FALSE, verbose=TRUE)

file.exists(paste0(tfile, ".nii"))
file.exists(paste0(tfile, ".nii.gz"))
file.exists(paste0(tfile, ".hdr"))
file.exists(paste0(tfile, ".img"))

### trying without onefile specification - magic is n1
img2 = readNIfTI(tfile, verbose=TRUE)
file.remove(paste0(tfile, ".nii.gz"))

writeNIfTI(img, filename = tfile, onefile = FALSE, gzipped = FALSE,
           verbose=TRUE)

img@magic = "n+1"
img@vox_offset = 352

# Creating a new nifti object with the FLOAT32 datatype, 
# this also puts scl_slope = 1, scl_inter = 0, and runs cal_img
# trybyte is passed to fslr::datatype
img = datatyper(img, trybyte = TRUE, 
             datatype = convert.datatype()$FLOAT32,
             bitpix = convert.bitpix()$FLOAT32)

writeNIfTI(img, filename = tfile, verbose=TRUE)

# File can be read in!
img2 = readNIfTI(tfile, verbose=TRUE)
# They are the same!
all(img == img)
