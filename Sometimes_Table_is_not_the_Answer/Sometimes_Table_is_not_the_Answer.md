
The `table` command is great in its simplicity for cross tabulations.  I have run into some settings where it is slow and I wanted to demonstrate one simple example here of why you may want to use other functions or write your own tabler.  This example is a specific case where, for some examples and functions, you don't need all the good error-checking or flexibility that a function contains, but you want to do something specific and can greatly speed up computation.

## Setup of example
I have some brain imaging data.  I have a gold standard, where an expert hand-traced (on a computer) a brain scan delineating the brain.  I'll refer to this as a brain "mask".  (We use the word mask in imaging to denote a segmented image - either done manually or automatically and I generally reserve the word mask for binary 0/1 values, but others use the term more broadly.)

Using automated methods, I can try to re-create this mask automatically. This image is also binary.  I want to simply get a $2\times2$ contingency table of the automated versus manual masks so I can get sensitivity/specificity/accuracy/etc.





## The data 

For simplicity and computation, let's consider the images as just a really long vectors.  I'll call them `manual` and `auto` for the manual and automatic masks, respectively.

These are long logical vectors (9 million elements):



```r
length(manual)
```

```
[1] 9175040
```

```r
length(auto)
```

```
[1] 9175040
```

```r
head(manual)
```

```
[1] FALSE FALSE FALSE FALSE FALSE FALSE
```

```r
head(auto)
```

```
[1] FALSE FALSE FALSE FALSE FALSE FALSE
```

Naturally, you can run `table` on this data:


```r
stime = system.time({ tab = table(manual, auto) })
print(stime)
```

```
   user  system elapsed 
  4.797   0.143   5.259 
```

```r
print(tab)
```

```
       auto
manual    FALSE    TRUE
  FALSE 7941541   11953
  TRUE    15384 1206162
```

The computation took about 5.3 seconds on my MacBook Pro (2013, 16Gb RAM, 2.8GHz Intel i7), which isn't that bad.  Realize, though, that I could have hundreds or thousands of these images.  We need to speed this up. 

## What is the essense of what we're doing?
Taking 5.3 seconds to get 4 numbers seems a bit long.  As the data is binary, we can simply compute these with the `sum` command and logical operators.

Let's make the `twoXtwo` command:

```r
twoXtwo = function(x, y, dnames=c("x", "y")){
  	tt <- sum( x &  y)
		tf <- sum( x & !y)
		ft <- sum(!x &  y)
		ff <- sum(!x & !y)
		tab = matrix(c(ff, tf, ft, tt), ncol=2)
    n = list(c("FALSE", "TRUE"), c("FALSE", "TRUE"))
    names(n) = dnames
    dimnames(tab) = n
    tab = as.table(tab)
    dim
		tab
}
```

And let's see how fast this is (and confirm the result is the same):

```r
stime2 = system.time({ twotab = twoXtwo(manual, auto, dnames=c("manual", "auto")) })
print(stime2)
```

```
   user  system elapsed 
  0.934   0.027   0.976 
```

```r
print(twotab)
```

```
       auto
manual    FALSE    TRUE
  FALSE 7941541   11953
  TRUE    15384 1206162
```

```r
identical(tab, twotab)
```

```
[1] TRUE
```
Viola, `twoXtwo` runs about 5.39 times faster than `table`, largely because we knew we did not have to check certain characteristics of the data and that it's a specific example of a table.  

### More speed captain!
This isn't something astronomical such as a 100-fold increase, but we can increase the speed by not doing all the logical operations on the vectors, but taking differences from the margin sums.  



Let's confirm this is faster and accurate by running it on our data:


```r
stime3 = system.time({ twotab2 = twoXtwo2(manual, auto, dnames=c("manual", "auto")) })
print(stime3)
```

```
   user  system elapsed 
  0.217   0.001   0.221 
```

```r
print(twotab2)
```

```
       auto
manual    FALSE    TRUE
  FALSE 7941541   11953
  TRUE    15384 1206162
```

```r
identical(tab, twotab2)
```

```
[1] TRUE
```

Now, if I were going for speed, this code is good enough for me: it runs about 23.8 times faster than `table`.  The one downside is that it is not as readable as `twoXtwo`.  For even greater speed, I could probably move into C++ using the `Rcpp` package, but that seems overkill for a two by two table.  

Other examples of speeding up the calculation can be found [here](http://pvanb.wordpress.com/2012/06/21/cross-tables-in-r-some-ways-to-do-it-faster/).

## Finishing up
I said I wanted sensitivity/specificity/accuracy/etc. so I will show how to get these. I'm going to use `prop.table`, which I didn't know about for a while when I first started using R (see `margin.table` too).  


```r
ptab = prop.table(twotab)
rowtab = prop.table(twotab, margin=1)
coltab = prop.table(twotab, margin=2)
```

As you can see, like the `apply` command, the `prop.table` command can either take no margin or take the dimension to divide over (1 for rows, 2 for columns).  This means that in `ptab`, each cell of `twotab` was divided by the grand total (or `sum(tab)`).  For `rowtab`, each cell was divided by the `rowSums(tab)` to get a proportion, and similarly cells in `coltab` were divided by `colSums(tab)`.  After the end of the post, I can show you these are the same.

### Getting Performance Measures
#### Accuracy
Getting the accuracy is very easy:

```r
accur = sum(diag(ptab))
print(accur)
```

```
[1] 0.997
```

#### Sensitivity/Specificity
For sensitivity/specificity, the "truth" is the rows of the table, so we want the row percentages:

```r
sens = rowtab["TRUE", "TRUE"]
spec = rowtab["FALSE", "FALSE"]
print(sens)
```

```
[1] 0.9874
```

```r
print(spec)
```

```
[1] 0.9985
```

#### Positive/Negative Predictive Value
We can also get the [positive predictive value (PPV) and negative predictive value (NPV)](http://en.wikipedia.org/wiki/Positive_predictive_value) from the column percentages:

```r
ppv = coltab["TRUE", "TRUE"]
npv = coltab["FALSE", "FALSE"]
print(ppv)
```

```
[1] 0.9902
```

```r
print(npv)
```

```
[1] 0.9981
```

## Conclusions
After using R for years, I find things to still be very intuitive.  Sometimes, though, for large data sets or specific examples, you may want to write your own function for speed, checking against the base functions for a few iterations as a double-check.  I have heard this to be a nuisance for those who dislike R, as well as hampering reproducibility in some cases.  Overall, I find that someone has made a vetted package that does what you want, but there are still simple cases (such as above) where "rolling your own" is OK and easier than adding a dependency to your code.





## Aside: How prop.table works

### Over all margins
For just doing `prop.table` without a margin, you can think of the table being divided by its sum.

```r
print(round(ptab, 3))
```

```
       auto
manual  FALSE  TRUE
  FALSE 0.866 0.001
  TRUE  0.002 0.131
```

```r
print(round(twotab / sum(twotab), 3))
```

```
       auto
manual  FALSE  TRUE
  FALSE 0.866 0.001
  TRUE  0.002 0.131
```

### Over row margins
For the `margin=1`, or row percentages, you can think of dividing the table by the row sums.


```r
print(round(rowtab, 3))
```

```
       auto
manual  FALSE  TRUE
  FALSE 0.998 0.002
  TRUE  0.013 0.987
```

```r
print(round(twotab / rowSums(twotab), 3))
```

```
       auto
manual  FALSE  TRUE
  FALSE 0.998 0.002
  TRUE  0.013 0.987
```

### Over column margins

Now for column percentages, you can think of R dividing each cell by its column's sum.  This is what `prop.table` does.  

Let's look at the result we should get:

```r
print(round(coltab, 3))
```

```
       auto
manual  FALSE  TRUE
  FALSE 0.998 0.010
  TRUE  0.002 0.990
```

But in R, when you take a matrix and then add/divide/subtract/multiply it by a vector, R does the operation column-wise.  So when you take column sums on the table, you get a vector with the same number of columns as the table:


```r
print(colSums(twotab))
```

```
  FALSE    TRUE 
7956925 1218115 
```

If you try to divide the table by this value, it will not give you the desired result:

```r
print(round( twotab / colSums(twotab), 3))
```

```
       auto
manual  FALSE  TRUE
  FALSE 0.998 0.002
  TRUE  0.013 0.990
```

#### R operations with matrices and vectors

This is because R thinks of a vector as a column vector (or a matrix of 1 column).  R then takes the first column of the table and divides the first element from the first column sum (which is correct), but take the second element of the first column and divides it by the second column sum (which is not correct).
A detailed discussion on SO is located [here](http://stackoverflow.com/questions/3643555/multiply-rows-of-matrix-by-vector) of how to do row-wise operations on matrices.

### Back to column percentages
We can use the `t( t() )` operation to get the correct answer:

```r
print(round( t( t(twotab) / colSums(twotab)), 3))
```

```
       auto
manual  FALSE  TRUE
  FALSE 0.998 0.010
  TRUE  0.002 0.990
```
You can think of R implicitly making the matrix of the correct size with the correct values and then dividing:

```r
cs = colSums(twotab)
cs = matrix(cs, nrow=nrow(tab), ncol=ncol(tab), byrow=TRUE)
print(cs)
```

```
        [,1]    [,2]
[1,] 7956925 1218115
[2,] 7956925 1218115
```

```r
print(round( twotab/cs, 3))
```

```
       auto
manual  FALSE  TRUE
  FALSE 0.998 0.010
  TRUE  0.002 0.990
```

Happy tabling!


