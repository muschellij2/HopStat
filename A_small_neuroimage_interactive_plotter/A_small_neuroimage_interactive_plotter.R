## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
library(knitr)
opts_chunk$set(echo=TRUE, prompt=FALSE, message=FALSE, warning=FALSE, comment="", results='hide')

## ------------------------------------------------------------------------
library(manipulate)

## ------------------------------------------------------------------------
library(fslr)
options(fsl.path='/usr/local/fsl')
template = file.path(fsldir(), "data/standard", 
                     "MNI152_T1_1mm_brain.nii.gz")
img = readNIfTI(template)

## ------------------------------------------------------------------------
iplot = function(img, plane = c("axial", 
                                "coronal", "sagittal"), ...){
  ## pick the plane
  plane = match.arg(plane, c("axial", 
                             "coronal", "sagittal"))
  # Get the max number of slices in that plane for the slider
  ns=  switch(plane,
              "axial"=dim(img)[3],
              "coronal"=dim(img)[2],
              "sagittal"=dim(img)[1])
  ## run the manipulate command
  manipulate({
    image(img, z = z, plot.type= "single", plane = plane, ...)
    # this will return mouse clicks (future experimental work)
    pos <- manipulatorMouseClick()
    if (!is.null(pos)) {
      print(pos)
    }
  },
  ## make the slider
  z = slider(1, ns, step=1, initial = ceiling(ns/2))
  )
}

## ----, eval=FALSE--------------------------------------------------------
## iplot(img)
## iplot(img, plane = "coronal")
## iplot(img, plane = "sagittal")

