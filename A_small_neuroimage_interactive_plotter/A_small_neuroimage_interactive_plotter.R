## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
library(knitr)
opts_chunk$set(echo=TRUE, prompt=FALSE, message=FALSE, warning=FALSE, comment="", results='hide')
rm(list=ls())

## ------------------------------------------------------------------------
library(manipulate)

## ------------------------------------------------------------------------
library(fslr)
options(fsl.path='/usr/local/fsl')
template = file.path(fsldir(), "data/standard", 
                     "MNI152_T1_1mm_brain.nii.gz")
img = readNIfTI("~/Desktop/scratch/100-318_20070723_0957_CT_3_CT_Head-.nii.gz")

## ------------------------------------------------------------------------
iplot = function(img, plane = c("axial", 
                                "coronal", "sagittal"), ...){
  plane = match.arg(plane, c("axial", 
                             "coronal", "sagittal"))
  ns=  switch(plane,
              "axial"=dim(img)[3],
              "coronal"=dim(img)[2],
              "sagittal"=dim(img)[1])
  manipulate({
    image(img, z = z, plot.type= "single", plane = plane, ...)
    pos <- manipulatorMouseClick()
    if (!is.null(pos)) {
      print(pos)
    }
  },
  z = slider(1, ns, step=1, initial = ceiling(ns/2))
  )
}

## ------------------------------------------------------------------------
iplot(img)
iplot(img, plane = "coronal")
iplot(img, plane = "sagittal")

