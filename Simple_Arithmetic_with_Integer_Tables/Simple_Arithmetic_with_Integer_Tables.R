## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
# rm(list=ls())
library(knitr)
opts_chunk$set(echo=TRUE, prompt=FALSE, message=TRUE, warning=TRUE, comment="")

## ----createvec, cache=TRUE-----------------------------------------------
set.seed(20150301)
vec = sample(-10:100, size= 1e7, replace = TRUE)

## ------------------------------------------------------------------------
quantile.table = function(tab, probs = c(0, 0.25, 0.5, 0.75, 1)){
  n = sum(tab)
  #### get CDF
  cs = cumsum(tab)
  ### get values (x)
  uvals = unique(as.numeric(names(tab)))
  
  #  can add different types of quantile, but using default
  m = 0
  qs = sapply(probs, function(prob){
    np = n * prob
    j = floor(np) + m
    g = np + m - j
    # type == 1
    gamma = as.numeric(g != 0)
    cs <= j
    quant = uvals[min(which(cs >= j))]
    return(quant)
  })
  dig <- max(2L, getOption("digits"))
  names(qs) <- paste0(if (length(probs) < 100) 
    formatC(100 * probs, format = "fg", width = 1, digits = dig)
    else format(100 * probs, trim = TRUE, digits = dig), 
    "%")
  return(qs) 
}

## ----benchmark, cache = TRUE---------------------------------------------
library(microbenchmark)
options(microbenchmark.unit='relative')
qtab = function(vec){
  tab = table(vec)
  quantile.table(tab)
}
qcdf = function(vec){
  cdf = ecdf(vec)
  quantile(cdf, type=1)
}
# quantile(vec, type = 1)
microbenchmark(qtab(vec), qcdf(vec), quantile(vec, type = 1), times = 10L)

## ----benchmark_tab, cache = TRUE-----------------------------------------
options(microbenchmark.unit="relative")
tab = table(vec)
cdf = ecdf(vec)
all.equal(quantile.table(tab), quantile(cdf, type=1))
all.equal(quantile.table(tab), quantile(vec, type=1))
microbenchmark(quantile.table(tab), quantile(cdf, type=1), quantile(vec, type = 1), times = 10L)

## ----show_qcdf-----------------------------------------------------------
stats:::quantile.ecdf

## ------------------------------------------------------------------------
median.table = function(tab){
  quantile.table(tab, probs = 0.5)
}

## ----mean, cache=TRUE----------------------------------------------------
mean.table = function(tab){
  uvals = unique(as.numeric(names(tab)))
  sum(uvals * tab)/sum(tab)
}
mean.table(tab)
mean(tab)
mean(cdf)

## ----meanvec, cache=TRUE-------------------------------------------------
mean(vec)
all.equal(mean(tab), mean(vec))

## ----over0, cache=TRUE---------------------------------------------------
mean(vec[vec > 0])
over0 = tab[as.numeric(names(tab)) > 0]
mean(over0)
mean.table(over0)
class(over0)

## ----over0_reassign, cache=TRUE------------------------------------------
class(over0) = "table"
mean(over0)

## ----natab1, cache=TRUE--------------------------------------------------
navec = vec
navec[sample(length(navec), 20)] = NA
natab = table(navec, useNA="ifany")
nacdf = ecdf(navec)
mean(navec)
mean(natab)
# mean(nacdf)

## ----natab, cache=TRUE---------------------------------------------------
tab2 = table(vec, useNA="always")
mean(tab2)
nonatab = table(navec, useNA="no")
mean(nonatab)
mean(navec, na.rm=TRUE)

## ----benchmark_mean, cache = TRUE, warning=FALSE-------------------------
options(microbenchmark.unit="relative")
microbenchmark(mean(tab), mean(vec), times = 10L)

## ----sdtab---------------------------------------------------------------
sd(vec)
sd(tab)

## ----sdcdf, error=TRUE---------------------------------------------------
sd(cdf)

## ----sdtable-------------------------------------------------------------
var.table = function(tab){
  m = mean(tab)
  uvals = unique(as.numeric(names(tab)))
  n = sum(tab)
  sq = (uvals - m)^2
  ## sum of squared terms
  var = sum(sq * tab) / (n-1)
  return(var)
}
sd.table = function(tab){
  sqrt(var.table(tab))
}
sd.table(tab)

## ----benchmark_sd, cache = TRUE------------------------------------------
options(microbenchmark.unit="relative")
microbenchmark(sd.table(tab), sd(vec), times = 10L)

## ----table_mode----------------------------------------------------------
mode.table = function(tab, multiple = TRUE){
  uvals = unique(as.numeric(names(tab)))
  ind = which.max(tab)
  if (multiple){
    ind = which(tab == max(tab))
  }
  uvals[ind]
}
mode.table(tab)

## ----objsize-------------------------------------------------------------
format(object.size(vec), "Kb")
format(object.size(tab), "Kb")
round(as.numeric(object.size(vec) / object.size(tab)))

