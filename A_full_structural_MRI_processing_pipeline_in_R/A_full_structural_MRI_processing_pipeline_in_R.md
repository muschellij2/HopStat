

The data for this post is located at [https://github.com/muschellij2/FSLR_data](https://github.com/muschellij2/FSLR_data), and was graciously allowed by our colleagues who collected it at the NIH.  

# Goal of the post
The overall goal of this post is to present a complete preprocessing pipeline for structural magnetic resonance imaging (sMRI) data "completely" within `R`.  

## Required packages
This package will rely mainly on 4 packages:

- oro.nifti: read/write data, the nifti object
- fslr: process data (need FSL for most of the functionality)
- ANTsR: process data (need cmake to install)
- extrantsr: extends and wraps ANTsR functions (need ANTsR)

## Install these packages


```r
install.packages("oro.nifti")
install.packages("devtools")
devtools::install_github("stnava/ANTsR") # takes a long time
devtools::install_github("muschellij2/extrantsr")
devtools::install_github("muschellij2/fslr")
```


### fslr setup
For interactive sessions, you must set the `fsl.path` to the path to FSL.  This allows fslr to execute FSL commands.  You can also set `fsl.outputtype`, which specifies the output type for images.


```r
library(fslr)
options(fsl.path="/usr/local/fsl")
options(fsl.outputtype = "NIFTI_GZ")
```


## Files

The dataset is multi-sequence MRI data where the sequences are:  

- 4 sequences: T1, T2, PD, FLAIR
- 2 time points Baseline and Follow-up




```r
files
```

```
                   base_t1                    base_t2 
   "01-Baseline_T1.nii.gz"    "01-Baseline_T2.nii.gz" 
                   base_pd                 base_flair 
   "01-Baseline_PD.nii.gz" "01-Baseline_FLAIR.nii.gz" 
                      f_t1                       f_t2 
   "01-Followup_T1.nii.gz"    "01-Followup_T2.nii.gz" 
                      f_pd                    f_flair 
   "01-Followup_PD.nii.gz" "01-Followup_FLAIR.nii.gz" 
```



## Read in the Files!

Let's read in the baseline T1.  The `readNIfTI` function from the `oro.nifti` package is the workhorse:

```r
library(oro.nifti)
base_t1 = readNIfTI(files["base_t1"])
```

```
Error in readNIfTI(files["base_t1"]): File(s) not found!
```

## Bias Field Correction

We can do bias field correction from the `ANTsR` package.  The `bias_correct` function can perform the correction on either `nifti` objects or filenames and the user can pass in either `"N3"` or `"N4"` as an argument.  Here we will do N4 bias field correction.


```r
library(ANTsR)
library(extrantsr)
n4_t1 = bias_correct(file = base_t1, correction = "N4", retimg=TRUE)
```

## Skull Stripping
We will use FSL's BET for the corrected T1 image to skull strip the image:


```
FSLDIR=/usr/local/fsl; export FSLDIR; sh ${FSLDIR}/etc/fslconf/fsl.sh; FSLOUTPUTTYPE=NIFTI_GZ; export FSLOUTPUTTYPE; $FSLDIR/bin/bet2 "/var/folders/1s/wrtqcpxn685_zk570bnx9_rr0000gr/T//RtmpQKUjqY/file63b21d6bb8e1.nii.gz" "/Users/johnmuschelli/Dropbox/Presentations/structural_talk//SS_Image" -f 0.1 -v 
```

```
FSLDIR=/usr/local/fsl; export FSLDIR; sh ${FSLDIR}/etc/fslconf/fsl.sh; FSLOUTPUTTYPE=NIFTI_GZ; export FSLOUTPUTTYPE; $FSLDIR/bin/fslmaths "/Users/johnmuschelli/Dropbox/Presentations/structural_talk//SS_Image"  -bin   "/Users/johnmuschelli/Dropbox/Presentations/structural_talk//Brain_Mask"; 
```

```
character(0)
```


```r
ss_t1 = fslbet(n4_t1, retimg = TRUE, opts = "-f 0.1 -v", 
               betcmd = "bet2", outfile = "SS_Image")
fslbin(file = "SS_Image", outfile = "Brain_Mask")
```

- `fslbet` - the command
- `retimg` - Return an image
- `opts` - options of bash `bet` command
- `betcmd` - can use `bet2` or `bet` (wrapper for `bet2`)

## Image processing

`extrantsr::preprocess_mri_within` will do N3/N4 Correction, skull strip (or mask), and register to the first scan.


```r
outfiles = gsub("[.]nii", "_N3_reg.nii", files)
proc_images = preprocess_mri_within(
  files = files[c("base_t1", "base_t2", "base_pd", "base_flair")],
  outfiles = outfiles[c("base_t1", "base_t2", "base_pd", "base_flair")],
  correct = TRUE,
  correction = "N4",
  retimg = TRUE, maskfile = file.path(homedir, "Brain_Mask.nii.gz"))
```


```r
outfiles = gsub("[.]nii", "_N3_reg.nii", files)
proc_images = preprocess_mri_within(
  files = files[c("base_t1", "base_t2", "base_pd", "base_flair")],
  outfiles = outfiles[c("base_t1", "base_t2", "base_pd", "base_flair")],
  correct = TRUE,
  correction = "N4",
  retimg = TRUE, maskfile = "Brain_Mask.nii.gz")
```

## Intensity Normalization


```
Error in reg_whitestripe(t1 = outfiles["base_t1"], register = TRUE, native = TRUE, : object 'outfiles' not found
```


```r
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
```



## Other useful functions from fslr

- `window_img` - set min and max values of image (good for plotting)
- `drop_img_dim` - drop dimension if is dimension is 1
- `mask_img` - mask image with an array/nifti object
- `robust_window` - quantile the image then use `window_img` (take out large values)
- `fslhd` and `fslval` can get information from an image without having to read it in
- `checkimg` - checks if an image is character, writes `nifti` to tempfile, returns character
- `check_nifti` - checks if an image is `nifti`, reads filename, returns `nifti`

## Overview

1. `oro.nifti` - reading/writing nifti objects 
2. `ANTsR`
    + bias field corrrection
    + registration: linear, non-linear (symmetric)
3. `fslr`
    + can perform image operations from FSL
    + has helper functions for `nifti` objects
4. extrantsr - helper functions for ANTsR
    + wrapper functions for preprocessing


