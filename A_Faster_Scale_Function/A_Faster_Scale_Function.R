## ----label=opts, results="hide", echo=FALSE, message = FALSE, warning=FALSE----
library(knitr)
library(matrixStats)
opts_chunk$set(echo = TRUE, prompt = FALSE, message = FALSE, warning = FALSE, comment = "", results = "hide", cache = TRUE)

## ----data, cache=FALSE---------------------------------------------------
set.seed(1)
mat = matrix(rnorm(1e7, mean = 14, sd = 5), 
    nrow = 1e5)
dim(mat)

## ----scale, cache = FALSE, results = "markup"----------------------------
system.time({
    sx = scale(mat)
    })

## ----colScale------------------------------------------------------------
library(matrixStats)

colScale = function(x, 
    center = TRUE, 
    scale = TRUE,
    add_attr = TRUE, 
    rows = NULL, 
    cols = NULL) {
    
    if (!is.null(rows) && !is.null(cols)) {
        x <- x[rows, cols, drop = FALSE]
    } else if (!is.null(rows)) {
        x <- x[rows, , drop = FALSE]
    } else if (!is.null(cols)) {
        x <- x[, cols, drop = FALSE]
    }
    
  ################
  # Get the column means
  ################  
    cm = colMeans(x, na.rm = TRUE)
  ################
  # Get the column sd
  ################      
    if (scale) {
        csd = colSds(x, center = cm)
    } else {
        # just divide by 1 if not
        csd = rep(1, length = length(cm))
    }
    if (!center) {
        # just subtract 0
        cm = rep(0, length = length(cm))
    }
    x = t( (t(x) - cm) / csd )
    if (add_attr) {
        if (center) {
            attr(x, "scaled:center") <- cm
        }
        if (scale) {
            attr(x, "scaled:scale") <- csd
        } 
    }   
    return(x)
}

## ----colscaler, cache = FALSE, results = "markup"------------------------
system.time({
    csx = colScale(mat)
})

## ----compare, results = "markup"-----------------------------------------
all.equal(sx, csx)

## ----bench, results = "markup"-------------------------------------------
library(microbenchmark)
mb = microbenchmark(colScale(mat), scale(mat), times = 20, unit = "s")
print(mb)

## ----gg------------------------------------------------------------------
library(ggplot2)
g = ggplot(data = mb, aes(y = time / 1e9, x = expr)) + geom_violin() + theme_grey(base_size = 20) + xlab("Method") + ylab("Time (seconds)")
print(g)

## ----scaled_row, results = "markup"--------------------------------------
system.time({
  scaled_row = t( scale(t(mat)) )
})
all(abs(rowMeans(scaled_row)) < 1e-15)

## ----colscaled_row, results = "markup"-----------------------------------
system.time({
  colscaled_row = t( colScale(t(mat)) )
})
all(abs(rowMeans(colscaled_row)) < 1e-15)
all.equal(colscaled_row, scaled_row)

## ----rowScale------------------------------------------------------------
rowScale = function(x, 
    center = TRUE, 
    scale = TRUE,
    add_attr = TRUE, 
    rows = NULL, 
    cols = NULL) {
    
    if (!is.null(rows) && !is.null(cols)) {
        x <- x[rows, cols, drop = FALSE]
    } else if (!is.null(rows)) {
        x <- x[rows, , drop = FALSE]
    } else if (!is.null(cols)) {
        x <- x[, cols, drop = FALSE]
    }
    
  ################
  # Get the column means
  ################  
    cm = rowMeans(x, na.rm = TRUE)
  ################
  # Get the column sd
  ################      
    if (scale) {
        csd = rowSds(x, center = cm)
    } else {
        # just divide by 1 if not
        csd = rep(1, length = length(cm))
    }
    if (!center) {
        # just subtract 0
        cm = rep(0, length = length(cm))
    }
    x = (x - cm) / csd 
    if (add_attr) {
        if (center) {
            attr(x, "scaled:center") <- cm
        }
        if (scale) {
            attr(x, "scaled:scale") <- csd
        } 
    }   
    return(x)
}

## ----rowscaled_row, results = "markup"-----------------------------------
system.time({
  rowscaled_row = rowScale(mat)
})
all(abs(rowMeans(rowscaled_row)) < 1e-15)
all.equal(rowscaled_row, scaled_row)

## ----mb_row, results = "markup"------------------------------------------
mb_row = microbenchmark(t( colScale(t(mat)) ),
                        t( scale(t(mat)) ),
                        rowScale(mat),
                        times = 20, unit = "s")
print(mb_row)

## ----gg_row--------------------------------------------------------------
g %+% mb_row

## ----code, eval = FALSE--------------------------------------------------
f <- function(v) {
  v <- v[!is.na(v)]
  sqrt(sum(v^2)/max(1, length(v) - 1L))
}
scale <- apply(x, 2L, f)

