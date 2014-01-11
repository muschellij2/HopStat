


Recently, I found a few concepts very useful when running jobs on a Sun Grid Engine (SGE) cluster, and found others had not heard about them.

First and foremost, Googling "array jobs", or "jobs sge cluster" will get you pretty far and so I highly suggest doing that before going anywhere else (after the --help of course).  For our cluster, many topics are covered [here](http://www.biostat.jhsph.edu/bit/cluster-usage.html).

Quick rundown of a batch job.  Let's say you have an R script, let's call it Rscript.R.  In a bash script (.sh file), let's call it Rscript.sh, you may have the commands

```
#!/bin/bash 
R CMD BATCH Rscript.R
```

Now, you need to go into your SGE computer (our's is called enigma), and run:
```
qsub /path/to/script/Rscript.sh
```
or use the `-cwd` option if you are running this command in the same directory as ```Rscript.sh```.  Boom!  Job submitted to the nodes (which are a bunch of CPUs with aggregated memory).  Let your code run and do all the fun stuff you normally would on your local machine not getting bogged down.

### Array Jobs
Now you may want to run this script under certain "scenarios".  This is highly useful when I'm doing simulations.  Let's say I had three parameters: `x`, `y`, `z` and wanted to vary these over simulations.  Let's take advantage of a useful `R` command: `expand.grid`.  This will give you all combinations of these 3 variables.


```r
x <- c(0, 1, 2)
y <- c(2, 4, 6)
z <- c(1, 2)
scenarios <- expand.grid(x = x, y = y, y = z)
scenarios
```

```
   x y y
1  0 2 1
2  1 2 1
3  2 2 1
4  0 4 1
5  1 4 1
6  2 4 1
7  0 6 1
8  1 6 1
9  2 6 1
10 0 2 2
11 1 2 2
12 2 2 2
13 0 4 2
14 1 4 2
15 2 4 2
16 0 6 2
17 1 6 2
18 2 6 2
```

This will give you an object called `scenarios` that is a `data.frame` with named columns `x`, `y`, `z` (because I used the `x=x` syntax).  Be aware `stringsAsFactors` is an option if you're using character vector and don't want them to be converted to factors.  Also see `combn` if you're interested in only a subset of the combinations.

Now, we have 18 scenarios and I don't want to run a for loop, I want to parallelize them ([embarrasingly](http://en.wikipedia.org/wiki/Embarrassingly_parallel)).  I now want to create what's called an <strong>array job</strong>.  Now our Rscript.sh would be:
```
#!/bin/bash 
#$ -t 1-18
R CMD BATCH Rscript.R
```
So that 18 jobs are run when 
```
qsub /path/to/script/Rscript.sh
```
is executed.  Well that's all fun and good, but we need to explain how to reference these individual runs.  So the `-t` assigns each of the jobs a "task number".  This is how we will index scenarios.  So in your Rscript.R, let's add
```
iscen <- as.numeric(Sys.getenv("SGE_TASK_ID"))
scenarios[iscen,]
```
This will grab the `SGE_TASK_ID` (bash) environment variable (from the `Sys.getenv` command), and just change it to numeric.  This can now be used to index the scenario that I want.  Now I can run my simulation with each specific scenario in parallel.  That should speed things up significantly with minimal cost of reworking code or new packages.

### Sequential Jobs
I've worked on a cluster for a while and only recently have I used <strong>sequential jobs</strong>, where one job only starts after another has finished.  Now, you can submit our first job:
```
qsub /path/to/script/Rscript.sh
```
and let's say it gets a task id of `1234`.  Now let us execute our second job:
```
qsub -hold_jid 1234 /path/to/script/Rscript2.sh
```
Now, Rscript2.sh will only run after Rscript.sh is done.  This is highly useful in pipelining or an analysis scheme that depends on certain results before running.

Now, what if it's not going to be task id `1234`?  If you use the `-N` option, you can name the job, let's say "`script1`", and we have:
```
qsub -N script1 /path/to/script/Rscript.sh
qsub -hold_jid script1 /path/to/script/Rscript.sh
```
Hopefully you can see how this would be useful in creating a reproducible series of jobs that would replicate an analysis/create a pipeline/do a series of steps.

Now for a quote from one of my favorite (and founder of) Jesuits: "Go forth and set the world on fire." - St. Ignatius of Loyola





