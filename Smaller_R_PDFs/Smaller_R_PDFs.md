## Making plots with many points
Whenever I make a lot of plots in `R`, I tend to make a multi-page PDF document.  PDF is usually great: it's [vectorized](http://en.wikipedia.org/wiki/Vector_graphics), which means it will scale no matter how much I zoom in or out.  The problem with it is that for ``large'' plots, which have a lot of points or lines, or just generally have a lot going on, the size of the PDF can become very big.  I recently got a new laptop this year and Preview still pinwheels (for Windows people, hour-glasses) and freezes for some PDFs that are 16Mb in size.  





Alternatively, for one-off plots, I use PNGs.  What if I want multiple PNGs but in one file? I have found that for most purposes, creating a bunch of PNG files, then concatenating them into a PDF gives smaller-size PDFs that do not cause Preview or Adobe Reader to choke, while still giving good-enough quality plots.

## Quick scatterplot example: using `pdf`

For example, let's say you wanted to make 5 different scatterplots of 1000000 bi-variate normals.  You can do something like:


```r
print(nplots)
```

```
[1] 5
```

```r

x = matrix(rnorm(1e+06 * nplots), ncol = nplots)
y = matrix(rnorm(1e+06 * nplots), ncol = nplots)

tm1 <- benchmark({
    pdfname = "mypdf.pdf"
    
    pdf(file = pdfname)
    for (idev in seq(nplots)) {
        plot(x[, idev], y[, idev])
    }
    dev.off()
}, replications = 1)
```


The syntax is easy: open a PDF device with `pdf()`, run your plotting commands, and then close your pdf device using `dev.off()`.  If you've ever forgotten to close your device, you know that you cannot open the PDF and you will be told it is corrupted.  

The plot is relatively simple, and there are other packages that can do better visualization, based on the number of pixels plotted and overplotting, such as `bigvis`, but let's say this is my plot to make.

Let's look at the size of the PDF.


```r
fsize = file.info(pdfname)$size/(1024 * 1024)
cat(fsize, "Mb\n")
```

```
32.56 Mb
```


As, we see the file is about 33 Mb. I probably don't need a file that large and that level of granularity for zooming and vectorization. 

## Quick scatterplot example: using multiple `png` devices

I could also make a series of 5 PNG files and put them into a folder.  I could then open Preview, drag and drop them into a PDF and then save them or scroll through them using a quick preview.  This is not a terrible solution, but it's not too reproducible, especially in a larger framework of creating multi-page PDFs.  

One alternative is to give `R` a temporary filename to give to the set of PNGs, create them in a temporary directory, and then concatenate the PNGs using [ImageMagick](http://www.imagemagick.org/).  



```r
tm2 <- benchmark({
    pdfname2 = "mypdf2.pdf"
    tdir = tempdir()
    mypattern = "MYTEMPPNG"
    fname = paste0(mypattern, "%05d.png")
    gpat = paste0(mypattern, ".*\\.png")
    takeout = list.files(path = tdir, pattern = gpat, full.names = TRUE)
    if (length(takeout) > 0) 
        file.remove(takeout)
    pngname = file.path(tdir, fname)
    # png(pngname)
    png(pngname, res = 600, height = 7, width = 7, units = "in")
    for (idev in seq(nplots)) {
        plot(x[, idev], y[, idev])
    }
    dev.off()
    
    pngs = list.files(path = tdir, pattern = gpat, full.names = TRUE)
    mystr = paste(pngs, collapse = " ", sep = "")
    system(sprintf("convert %s -quality 100 %s", mystr, pdfname2))
}, replications = 1)
```


One thing of note is that I visited the `png` help page many times, but never stopped to see:
>The page number is substituted if a C integer format is included in the character string, as in the default.

which tells me that I don't need to change around the filename for each plot - `R` will do that automatically.

Let's look at how big this file is:

```r
fsize = file.info(pdfname2)$size/(1024 * 1024)
cat(fsize, "Mb\n")
```

```
5.17 Mb
```


We see that there is a significant reduction in size.  The quality of the png is `600`ppi, which has sufficient (actually good) resolution for most applications and a lot of journal requirements.  

So what are the downsides?

1.  You have to run more code.
2.  You can't simply replace the `pdf` and `dev.off` syntax


To combat these two downsides, I wrapped these into functions `mypdf` and `mydev.off`.  


```r
mypdf = function(pdfname, mypattern = "MYTEMPPNG", ...) {
    fname = paste0(mypattern, "%05d.png")
    gpat = paste0(mypattern, ".*\\.png")
    takeout = list.files(path = tempdir(), pattern = gpat, full.names = TRUE)
    if (length(takeout) > 0) 
        file.remove(takeout)
    pngname = file.path(tempdir(), fname)
    png(pngname, ...)
    return(list(pdfname = pdfname, mypattern = mypattern))
}
# copts are options to sent to convert
mydev.off = function(pdfname, mypattern, copts = "") {
    dev.off()
    gpat = paste0(mypattern, ".*\\.png")
    pngs = list.files(path = tempdir(), pattern = gpat, full.names = TRUE)
    mystr = paste(pngs, collapse = " ", sep = "")
    system(sprintf("convert %s -quality 100 %s %s", mystr, pdfname, copts))
}
```


`mypdf` opens the device and sets up the format for the PNGs (allowing options to be passed to `png`).  It returns the pdfname and the regular expression pattern for the PNG files.  The `mydev.off` function takes in these two arguments, and any options to the `convert` function from ImageMagick, closes the device and concatenates the PNGs into a multi-page PDF. 

Let's see how we could implement this.


```r
tm3 <- benchmark({
    res = mypdf("mypdf3.pdf", res = 600, height = 7, width = 7, units = "in")
    for (idev in seq(nplots)) {
        plot(x[, idev], y[, idev])
    }
    mydev.off(pdfname = res$pdfname, mypattern = res$mypattern)
}, replications = 1)
```


And just for good measure, show that this PDF is the same size as before:

```r
fsize = file.info("mypdf3.pdf")$size/(1024 * 1024)
cat(fsize, "Mb\n")
```

```
5.17 Mb
```


Of note, the main difference between using this and `pdf` with respect to syntax is that `dev.off()` usually doesn't take an argument (it defaults to the current device).

## This process is slow 
Let's look at how long it takes to create the PDF for each scenario, using `benchmark` from the `rbenchmark` package.

```r
print(tm1$elapsed)
```

```
[1] 16.74
```

```r
print(tm2$elapsed)
```

```
[1] 294.7
```

```r
print(tm3$elapsed)
```

```
[1] 276.3
```


We see that it takes longer (by a factor of around 17) to make the PDF with PNGs and then concatenate them.  This is likely because 1) there may be some overhead with creating multiple PNGs versus one device and 2) there is the added PNG concatenation into a PDF step.  

## But the files are smaller and quicker to render


```r
######### Ratio of file sizes
ratio = file.info("mypdf.pdf")$size/file.info("mypdf2.pdf")$size
print(ratio)
```

```
[1] 6.299
```


Here we see the gain in file size (and quickness of rendering) is about 6, but again that gain is traded off by speed of code.   You can see the result of [using `pdf()`](https://github.com/muschellij2/HopStat/raw/master/Smaller_R_PDFs/mypdf.pdf) and [using `mypdf`](https://github.com/muschellij2/HopStat/raw/master/Smaller_R_PDFs/mypdf3.pdf).  

## Post-hoc compression

Obviously I'm not the only one who has had this problem; others have created some things to make smaller PDFs.  For example, `tools::compactPDF`, which uses `qpdf` or GhostScript, compresses <strong> already-made</strong> PDFs.  Also, there are other reasons to use other formats, such as TIFF (which many journals prefer), but I'm just using PNG as my preference.  JPEG, BMP, TIFF, etc should work equally as well as above.

## BONUS! 
Here are some helper functions that I made to make things easier for viewing PDFs directly from `R` (calling `bash`).  Other functions exist in packages such as `openPDF` from [`BioBase`](http://svitsrv25.epfl.ch/R-doc/library/Biobase/html/openPDF.html), but these are simple to implement.  (Note, I use `xpdf` for my pdfviewer, but `getOption("pdfviewer")` is a different viewer that failed on our cluster).  The first 3 are viewers for PDFs, PNGs, and the third tries to guess given the filename.  The 4th: `open.dev` uses the `fname` given to open the device.  This allows you to switch the filename to `.png` from `.pdf` and run the same code.  


```r
view.pdf = function(fname, viewer = getOption("pdfviewer")) {
    stopifnot(length(fname) == 1)
    if (is.null(viewer)) {
        viewer = getOption("pdfviewer")
    }
    system(sprintf("%s %s&", viewer, fname))
}

view.png = function(fname, viewer = "display") {
    stopifnot(length(fname) == 1)
    system(sprintf("%s %s&", viewer, fname))
}

view = function(fname, viewer = NULL) {
    stopifnot(length(fname) == 1)
    get.ext = gsub("(.*)\\.(.*)$", "\\2", file)
    stopifnot(get.ext %in% c("pdf", "bmp", "svg", "png", "jpg", "jpeg", "tiff"))
    if (get.ext == "pdf") {
        if (is.null(viewer)) {
            viewer = getOption("pdfviewer")
        }
    }
    if (is.null(viewer)) {
        warning("No viewer given, trying open")
        viewer = "open"
    }
    system(sprintf("%s %s&", viewer, fname))
}

#### open a device from the filename extension
open.dev = function(file, type = "cairo", ...) {
    get.ext = gsub("(.*)\\.(.*)$", "\\2", file)
    stopifnot(get.ext %in% c("pdf", "bmp", "svg", "png", "jpg", "jpeg", "tiff"))
    
    ## device is jpeg
    if (get.ext == "jpg") 
        get.ext = "jpeg"
    ### difff arguments for diff devices
    if (get.ext %in% c("pdf")) {
        do.call(get.ext, list(file = file, ...))
    } else if (get.ext %in% c("bmp", "jpeg", "png", "tiff", "svg")) {
        do.call(get.ext, list(filename = file, type = type, ...))
    }
}
```

