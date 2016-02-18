## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
library(knitr)
opts_chunk$set(echo=TRUE, prompt=FALSE, message=FALSE, warning=FALSE, comment="")

## ---- eval = FALSE-------------------------------------------------------
## require(devtools)
## devtools::install_github("muschellij2/papayar")

## ------------------------------------------------------------------------
library(papayar)
formalArgs(papaya)

## ---- eval=FALSE---------------------------------------------------------
## library(oro.nifti)
## x = nifti(img = array(rnorm(100^3), dim= rep(100, 3)), dim=rep(100, 3), datatype=16)
## y = nifti(img = array(rbinom(100^3, prob = 0.5, size = 10), dim= rep(100, 3)), dim=rep(100, 3), datatype=16)
## index.file = papaya(list(x, y))

## ---- eval=FALSE, echo = FALSE-------------------------------------------
## library(fslr)
## x = readNIfTI("MNI152_T1_1mm_brain.nii.gz", reorient = FALSE)
## brain = x > 0
## vals = x[x > 0]
## z = mask_img( (x- mean(vals))/ sd(vals), brain)
## y = mask_img(z^2, z > 0)
## index.file = papaya(list(x, y))

## ---- eval = FALSE-------------------------------------------------------
## require(devtools)
## devtools::install_github("muschellij2/itsnapr")

## ---- eval=FALSE---------------------------------------------------------
## library(itksnapr)
## itksnap(grayscale = x, overlay = y)

