## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
library(knitr)
opts_chunk$set(echo = TRUE, prompt = FALSE, message = FALSE, warning = FALSE, comment = "", results = "hide")

## ---- eval = FALSE-------------------------------------------------------
## x = list.files(
##   pattern = "[.]Rproj[.]user",
##   all.files = TRUE,
##   include.dirs = TRUE,
##   recursive = TRUE,
##   no.. = TRUE)
## dir.size = function(path) {
##   res = system(paste0("du ", shQuote(path)), intern = TRUE)
##   ss = strsplit(res, "\t")
##   ss = sapply(ss, function(x) as.numeric(x[1]))
##   sum(ss)
## }
## sizes = sapply(x, dir.size)

