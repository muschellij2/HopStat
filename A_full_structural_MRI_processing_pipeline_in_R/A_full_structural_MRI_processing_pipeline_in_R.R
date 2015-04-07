## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
gd = getwd()
library(knitr)
opts_chunk$set(echo=TRUE, prompt=FALSE, message=TRUE, warning=TRUE, comment="", cache = TRUE)

## ----, eval=FALSE--------------------------------------------------------
install.packages("oro.nifti")
install.packages("devtools")
devtools::install_github("stnava/ANTsR") # takes a long time
devtools::install_github("muschellij2/extrantsr")
devtools::install_github("muschellij2/fslr")

## ----fslr_setup, cache=FALSE---------------------------------------------
library(fslr)
options(fsl.path="/usr/local/fsl")
options(fsl.outputtype = "NIFTI_GZ")

## ----, echo=FALSE--------------------------------------------------------
files = c(base_t1="01-Baseline_T1.nii.gz", 
          base_t2="01-Baseline_T2.nii.gz",
          base_pd="01-Baseline_PD.nii.gz", 
          base_flair="01-Baseline_FLAIR.nii.gz", 
          f_t1= "01-Followup_T1.nii.gz", 
          f_t2= "01-Followup_T2.nii.gz", 
          f_pd = "01-Followup_PD.nii.gz", 
          f_flair="01-Followup_FLAIR.nii.gz")

## ------------------------------------------------------------------------
files

## ----data_setup, echo=FALSE, cache=FALSE---------------------------------
fn = names(files)
homedir = path.expand("~/Dropbox/Presentations/structural_talk/")
files = file.path(homedir, files)
names(files) = fn
# setwd(homedir)

## ----read_t1, message=FALSE----------------------------------------------
library(oro.nifti)
base_t1 = readNIfTI(files["base_t1"])

## ----bias_correct, cache=TRUE--------------------------------------------
library(ANTsR)
library(extrantsr)
n4_t1 = bias_correct(file = base_t1, correction = "N4", retimg=TRUE)

## ----bet_eval, cache=TRUE, echo = FALSE----------------------------------
ss_t1 = fslbet(n4_t1, retimg = TRUE, opts = "-v", 
               betcmd = "bet2", outfile = file.path(homedir, "SS_Image"))
fslbin(file = file.path(homedir, "SS_Image"), outfile = file.path(homedir, "Brain_Mask"))

## ----bet, eval=FALSE-----------------------------------------------------
ss_t1 = fslbet(n4_t1, retimg = TRUE, opts = "-v", 
               betcmd = "bet2", outfile = "SS_Image")
fslbin(file = "SS_Image", outfile = "Brain_Mask")

## ----, echo=TRUE, eval=TRUE----------------------------------------------
outfiles = gsub("[.]nii", "_N3_reg.nii", files)
proc_images = preprocess_mri_within(
  files = files[c("base_t1", "base_t2", "base_pd", "base_flair")],
  outfiles = outfiles[c("base_t1", "base_t2", "base_pd", "base_flair")],
  correct = TRUE,
  correction = "N4",
  retimg = TRUE, maskfile = file.path(homedir, "Brain_Mask.nii.gz"))

## ----, eval=FALSE--------------------------------------------------------
outfiles = gsub("[.]nii", "_N3_reg.nii", files)
proc_images = preprocess_mri_within(
  files = files[c("base_t1", "base_t2", "base_pd", "base_flair")],
  outfiles = outfiles[c("base_t1", "base_t2", "base_pd", "base_flair")],
  correct = TRUE,
  correction = "N4",
  retimg = TRUE, maskfile = "Brain_Mask.nii.gz")

## ----, eval=TRUE, echo=FALSE---------------------------------------------
wsfiles = gsub("[.]nii", "_N3_reg_whitestripe.nii", files)

results = reg_whitestripe(t1 = outfiles["base_t1"], 
                register = TRUE, 
                native = TRUE,
                t1.outfile = wsfiles["base_t1"],
                other.files = outfiles[c("base_t2", 
                                         "base_pd", "base_flair")],
                other.outfiles = wsfiles[c("base_t2", 
                                            "base_pd", "base_flair")],
                ws.outfile = file.path(homedir, "WS_Mask.nii.gz"),
                mask = file.path(homedir, "Brain_Mask.nii.gz"))

## ----, eval=FALSE--------------------------------------------------------
wsfiles = gsub("[.]nii", "_N3_reg_whitestripe.nii", files)

results = reg_whitestripe(t1 = outfiles["base_t1"], 
                register = TRUE, 
                native = TRUE,
                t1.outfile = wsfiles["base_t1"],
                other.files = outfiles[c("base_t2", 
                                         "base_pd", "base_flair")],
                other.outfiles = wsfiles[c("base_t2", 
                                            "base_pd", "base_flair")],
                ws.outfile = "WS_Mask.nii.gz",
                mask = "Brain_Mask.nii.gz")

## ----, echo=FALSE--------------------------------------------------------
setwd(gd)

