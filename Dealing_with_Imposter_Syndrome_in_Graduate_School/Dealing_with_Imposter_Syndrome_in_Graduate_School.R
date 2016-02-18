## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
library(knitr)
opts_chunk$set(echo = FALSE, prompt = FALSE, message = FALSE, 
               warning = FALSE, comment = "", results = 'hide')

## ------------------------------------------------------------------------
start = xstart = 2
xend = end = 5

xend = end
start = start + 1

mids = seq(start,end,0.01)
cord.x <- c(start,mids,end) 
cord.y <- c(0,dnorm(mids),0) 
plot(dnorm, from = xstart, to=xend, ylab = "", 
     xlab = "", 
     main = "Conditional Distribution of Knowledge\nin Your Field", 
     xaxt = "n", yaxt = "n", bty= "n" )
polygon(cord.x,cord.y,col='red')
text(x = start + 0.25, y = dnorm(start) + 0.0025, "Faculty", col= "red")
segments(x0 = xstart, x1 = xend, y0 = 0, y1 = 0)
eps = .025
segments( x0 = xstart + eps, x1 = xstart + eps, 
          y0 = 0,
          y1 = dnorm(xstart + eps), 
          lty ="solid")
text(x = xstart + eps, y = dnorm(xstart + eps) + 0.0025, "You")
eps = 0.1
segments( x0 = xstart + eps, x1 = xstart + eps, 
          y0 = 0,
          y1 = dnorm(xstart + eps),
          col = "blue")
text(x = xstart + eps + 0.3, 
     y = dnorm(xstart + eps) + 0.0025, 
     "Best First Year", col = "blue")
eps = 0.5
segments( x0 = xstart + eps, x1 = xstart + eps, 
          y0 = 0,
          y1 = dnorm(xstart + eps), 
          col ="deeppink2")
text(x = xstart + eps + 0.2, 
     y = dnorm(xstart + eps) + 0.0025, 
     "5th Year Student", col = "deeppink2")

## ----correct_distribution------------------------------------------------
start = xstart
end = xend
mids = seq(start,end,0.01)
cord.x <- c(start,mids,end) 
cord.y <- c(0,dnorm(mids),0) 

plot(dnorm, from = -xend, to = xend, ylab = "", 
     xlab = "", 
     main = "Full Distribution of Knowledge\nin Your Field", 
     xaxt = "n", yaxt = "n", bty= "n")
polygon(cord.x, cord.y, col = 'skyblue', border = NA)
segments(x0 = -xend, x1 = xend, y0 = 0, y1 = 0)
text(x = xstart + eps + 1.1, 
     y = dnorm(xstart + eps) + 0.1, 
     "Conditional\nDistribution", col = "skyblue")
eps = .025
segments( x0 = xstart + eps, x1 = xstart + eps, 
          y0 = 0,
          y1 = dnorm(xstart + eps), 
          lty = "solid")
text(x = xstart + eps, 
     y = dnorm(xstart + eps) + 0.025, 
     "You")
eps = .5
segments( x0 = xstart - eps, x1 = xstart - eps, 
          y0 = 0,
          y1 = dnorm(xstart - eps), 
          lty = "solid", 
          col = "darkgreen")
text(x = xstart - eps - 0.5, y = dnorm(xstart - eps) + 0.025, 
     "Avg Grad Student", col = "darkgreen")

text(x = start + 1.25, y = dnorm(start + 1) + 0.0025,
     "Faculty", 
     cex = 0.5,
     col = "red")
segments(x0 = xstart + 1, x1 = xend, y0 = 0, y1 = 0)

