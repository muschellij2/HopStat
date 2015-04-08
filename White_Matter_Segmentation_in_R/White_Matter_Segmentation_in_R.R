## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
library(knitr)
opts_chunk$set(echo=TRUE, prompt=FALSE, message=FALSE, warning=FALSE, comment="", results='hide', cache= TRUE)
setwd("~/Dropbox/Public/WordPress_Hopstat/White_Matter_Segmentation_in_R")

## ----, eval=FALSE--------------------------------------------------------
## devtools::install_github("muschellij2/oro.nifti")
## devtools::install_github("muschellij2/fslr")
## devtools::install_github("stnava/cmaker")
## devtools::install_github("stnava/ITKR")
## devtools::install_github("stnava/ANTsR")
## devtools::install_github("muschellij2/extrantsr")
## install.packages("scales")

## ------------------------------------------------------------------------
rm(list=ls())
library(fslr)
library(extrantsr)
library(scales)

## ----, cache=TRUE--------------------------------------------------------
options(fsl.path="/usr/local/fsl/")

## ----img-----------------------------------------------------------------
img.name = "SUBJ0001-01-MPRAGE.nii.gz"
img.stub = nii.stub(img.name)

## ----biascorrection, cache=TRUE------------------------------------------
n4img = bias_correct( img.name, correction = "N4", 
                      outfile = paste0(img.stub, "_N4.nii.gz") )

## ----biascorrection_plot, cache=FALSE------------------------------------
ortho2(n4img)

## ----bet, dependson="biascorrection"-------------------------------------
bet = fslbet_robust(img = n4img, 
                    retimg = TRUE,
                    remove.neck = TRUE,
                    robust.mask = FALSE,
                    template.file = file.path( fsldir(), 
                                               "data/standard", 
                                               "MNI152_T1_1mm_brain.nii.gz"),
                    template.mask = file.path( fsldir(), 
                                               "data/standard", 
                                               "MNI152_T1_1mm_brain_mask.nii.gz"), 
                    outfile = "SUBJ0001-01-MPRAGE_N4_BET", 
                    correct = FALSE)

## ----bet_plot, dependson="bet", cache=FALSE------------------------------
ortho2(n4img, bet > 0, 
       col.y=alpha("red", 0.5))

## ----fast, dependson="bet"-----------------------------------------------
fast = fast(file = bet, 
            outfile = paste0(img.stub, "_BET_FAST"), 
            opts = '-N')

## ----fast_plot, dependson="fast", cache=FALSE----------------------------
ortho2(bet, fast == 3, 
       col.y=alpha("red", 0.5))

## ----fast_plot_csf_gm, dependson="fast", cache=FALSE---------------------
ortho2(bet, fast == 1, col.y=alpha("red", 0.5), text="CSF Results")
ortho2(bet, fast == 2, col.y=alpha("red", 0.5), text="Gray Matter\nResults")

## ----outfiles, results='markup'------------------------------------------
list.files(pattern=paste0(img.stub, "_BET_FAST"))

