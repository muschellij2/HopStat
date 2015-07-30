## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
library(knitr)
opts_chunk$set(echo=TRUE, prompt=FALSE, message=FALSE, warning=FALSE, comment="",  results='markup', fig.path='figure/')

## ----final_plot, echo = FALSE, results='hide'----------------------------
library(ggplot2)
library(reshape2)
library(plyr)
library(grid)
N <- 30
id <- as.character(1:N)
sexes = c("male", "female")
sex <- sample(sexes, size = N/2, replace = TRUE)
diseases = c("low", "med", "high")
disease <- rep(diseases, each=N/3)
times = c("Pre", "0", "30", "60")
time <- rep(times, times = 30)
t <- 0:3
y1 <- c(replicate(15, rnorm(4, mean=10+2*t)), replicate(15, rnorm(4, mean=10+4*t)))
y2 <- c(replicate(15, rnorm(4, mean=10-2*t)), replicate(15, rnorm(4, mean=10-4*t)))
y3 <- c(replicate(15, rnorm(4, mean=10+t^2)), replicate(15, rnorm(4, mean=10-t^2)))

data <- data.frame(id=rep(id, each=4), sex=rep(sex, each=4), 
                   severity=rep(disease, each=4), time=time, 
                   Y1=c(y1), Y2=c(y2), Y3=c(y3))
data$sex = factor(data$sex, levels = sexes)
data$time = factor(data$time, levels = times)
data$severity = factor(data$severity, levels = diseases)

long = melt(data, measure.vars = c("Y1", "Y2", "Y3") )

pre_data = long[ long$time == "Pre", ]
data = long[ long$time != "Pre", ]

agg = ddply(long, .(severity, sex, variable, time), function(x){
  # c(mean=mean(x$value), se = sd(x$value)/nrow(x))
  c(mean=mean(x$value), se = sd(x$value))
})

agg$num_time = as.numeric(as.character(agg$time))
agg$num_time[ is.na(agg$num_time) ] = -1
agg$lower = agg$mean + agg$se
agg$upper = agg$mean - agg$se

agg$new_time = as.numeric(agg$time)


pd <- position_dodge(width = 0.2) # move them .05 to the left and right

sub_no_pre = agg[ agg$time != "Pre",]
g_final = ggplot(agg, aes(y=mean, colour=severity)) + 
  geom_errorbar(aes(x=new_time, ymin=lower, ymax=upper), width=.3, position=pd) +
  geom_line(data = sub_no_pre, position=pd, 
            aes(x = new_time, y=mean, colour=severity)) +
  geom_point(aes(x=new_time), position=pd) + facet_grid(variable ~ sex) + 
  scale_x_continuous(breaks=c(1:4), labels=c("Pre", "0", "30", "60"))
g_final = g_final + theme(panel.margin.x = unit(1, "lines"), 
                          panel.margin.y = unit(0.25, "lines"))
print(g_final)

## ----gen_data------------------------------------------------------------
N <- 30
id <- as.character(1:N) # create ids
sexes = c("male", "female")
sex <- sample(sexes, size = N/2, replace = TRUE) # create a sample of sex
diseases = c("low", "med", "high")
disease <- rep(diseases, each = N/3) # disease severity 
times = c("Pre", "0", "30", "60")
time <- rep(times, times = N) # times measured 
t <- 0:3
ntimes = length(t)
y1 <- c(replicate(N/2, rnorm(ntimes, mean = 10+2*t)), 
        replicate(N/2, rnorm(ntimes, mean = 10+4*t)))
y2 <- c(replicate(N/2, rnorm(ntimes, mean = 10-2*t)), 
        replicate(N/2, rnorm(ntimes, mean = 10-4*t)))
y3 <- c(replicate(N/2, rnorm(ntimes, mean = 10+t^2)), 
        replicate(N/2, rnorm(ntimes, mean = 10-t^2)))

data <- data.frame(id=rep(id, each=ntimes), sex=rep(sex, each=ntimes), 
                   severity=rep(disease, each=ntimes), time=time, 
                   Y1=c(y1), Y2=c(y2), Y3=c(y3)) # create data.frame
#### factor the variables so in correct order
data$sex = factor(data$sex, levels = sexes)
data$time = factor(data$time, levels = times)
data$severity = factor(data$severity, levels = diseases)
head(data)

## ----reshape_data--------------------------------------------------------
library(reshape2)
long = melt(data, measure.vars = c("Y1", "Y2", "Y3") )
head(long)

## ----reshape_data2-------------------------------------------------------
head(long[ order(long$id, long$time, long$variable),], 10)

## ----aggregate_data------------------------------------------------------
library(plyr)
agg = ddply(long, .(severity, sex, variable, time), function(x){
  c(mean=mean(x$value), sd = sd(x$value))
})
head(agg)

## ----create_limits-------------------------------------------------------
agg$lower = agg$mean + agg$sd
agg$upper = agg$mean - agg$sd

## ----gbase---------------------------------------------------------------
class(agg$time)
pd <- position_dodge(width = 0.2) # move them .2 to the left and right

gbase  = ggplot(agg, aes(y=mean, colour=severity)) + 
  geom_errorbar(aes(ymin=lower, ymax=upper), width=.3, position=pd) +
  geom_point(position=pd) + facet_grid(variable ~ sex)
gline = gbase + geom_line(position=pd) 
print(gline + aes(x=time))

## ----create_time---------------------------------------------------------
agg$num_time = as.numeric(as.character(agg$time))
agg$num_time[ is.na(agg$num_time) ] = -1
unique(agg$num_time)

## ----plus----------------------------------------------------------------
gline = gline %+% agg
print(gline + aes(x=num_time))

## ----create_time_neg-----------------------------------------------------
agg$num_time[ agg$num_time == -1 ] = -30
gline = gline %+% agg
print(gline + aes(x=num_time))

## ----new_time------------------------------------------------------------
agg$new_time = as.numeric(agg$time)
unique(agg$new_time)
gline = gline %+% agg
print(gline + aes(x = new_time))

## ----subset_data---------------------------------------------------------
sub_no_pre = agg[ agg$time != "Pre",]

## ----prev, eval = FALSE--------------------------------------------------
## gline = gbase + geom_line(position=pd)

## ----non_conn------------------------------------------------------------
gbase = gbase %+% agg
gline = gbase + geom_line(data = sub_no_pre, position=pd, 
                          aes(x = new_time, y = mean, colour=severity)) 
print(gline + aes(x = new_time))

## ----relabel-------------------------------------------------------------
g_final = gline + aes(x=new_time) +
  scale_x_continuous(breaks=c(1:4), labels=c("Pre", "0", "30", "60"))

## ----relabel2------------------------------------------------------------
time_levs = levels(agg$time)
g_final = gline + aes(x=new_time) +
  scale_x_continuous(
    breaks= 1:length(time_levs), 
    labels = time_levs)
print(g_final)

## ----final---------------------------------------------------------------
library(grid)
g_final = g_final + theme(panel.margin.x = unit(1, "lines"), 
                          panel.margin.y = unit(0.5, "lines"))
print(g_final)

