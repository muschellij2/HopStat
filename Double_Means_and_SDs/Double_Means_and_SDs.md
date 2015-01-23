

## Message
Interpretation of values is important.  I show 3 ways of calculating the same mean but each estimate has different variances depending on the assumptions used, the sampling assumed, and the interpretation of the mean. 

## Setup of the Problem
In some applications, you have a matrix of $N$ observations with $P$ columns.  Let $X$ be the matrix with elements $x_{ij}$, where $i = 1, \dots, N$ and $j = 1, \dots, P$: 
$$X = \left( 
\begin{array}{cccc}
x_{1,1} & x_{1,2} & \cdots & x_{1,P} \newline
x_{2,1} & x_{2,2} & \cdots & x_{2,P} \newline
\vdots & \vdots & \vdots & \vdots \newline
x_{N,1} & x_{N,2} & \cdots & x_{N,P} 
\end{array} 
\right)$$

Let's say the matrix is $P$ voxels from a brain image and $N$ is the number of participants in the study.  Let's also assume you can collapse informations across voxels and across people and you want to describe the sample.  






## A tale of 3 means
Let $M$ be the grand mean, collapsing over rows and columns.  We know that:
$$
M = \frac{1}{N\times P}\sum_{k = 1}^{N\times P}x_{k}
$$

Let $M_{NP}$ be mean of means of the $P$ columns.  We can show that this is equal to $M_{PN}$, the mean of the means of the $N$ rows:


$$\begin{align}
M_{NP} & =\frac{1}{N} \sum_{i=1}^{N} \bar{x}_{iP} \newline
& =\frac{1}{N} \sum_{i=1}^{N} \frac{1}{P} \sum_{j=1}^{P} x_{ij} \newline
& =\frac{1}{N \times P} \sum_{i=1}^{N} \sum_{j=1}^{P} x_{ij} \newline
& =\frac{1}{N \times P} \sum_{i=1}^{N} (x_{i1} + x_{i2} + \cdots + x_{i,P-1} + x_{iP}) \newline
& =\frac{1}{N \times P} ( x_{1,1} + x_{2,1} + \cdots + x_{N,1} + x_{1,2} + x_{2,2} + \cdots + x_{N,2} + \cdots +  x_{1,P} + x_{2,P} + \cdots + x_{N-1,P} + x_{N,P} )\newline
&= M \newline
& =\frac{1}{N \times P} ( x_{1,1} + x_{1,2} + \cdots + x_{1,P} + x_{2,1} + x_{2,2} + \cdots + x_{2,P} + \cdots + x_{N,1} + x_{N,2} + \cdots + x_{N,P-1} + x_{N,P} ) \newline
& =\frac{1}{N \times P} \sum_{j=1}^{P} (x_{1j} + x_{2j} + \cdots + x_{N-1,j} + x_{Nj}) \newline
& = \frac{1}{N \times P} \sum_{j=1}^{P} \sum_{i=1}^{N} x_{ij} \newline
& = \frac{1}{P} \sum_{j=1}^{P} \frac{1}{N} \sum_{i=1}^{N} x_{ij} \newline
& =\frac{1}{P} \sum_{j=1}^{P} \bar{x}_{Nj} \newline
& = M_{PN}
\end{align}$$

Thus, the mean voxel value ($\bar{x}_{Nj}$) per person is equal to the average activation level per person ($\bar{x}_{iP}$), averaged over voxels, which both are equal to the grand mean. 

### Simulation Means
We can illustrate this property with a simple simulation.  Let's say $N = 100$ and $P=10000$ and $X$ are independent normals.


```r
N = 100
P = 10000
true.var = 1
X = matrix(rnorm(N * P, sd = sqrt(true.var)), nrow=N, ncol=P)
print({grand_mean = mean(X)})
```

```
[1] 0.0001732881
```

```r
x_iP = rowMeans(X)
print({x_P_N = mean(x_iP)})
```

```
[1] 0.0001732881
```

```r
x_Nj = colMeans(X)
print({x_N_P = mean(colMeans(X))})
```

```
[1] 0.0001732881
```

```r
all.equal(grand_mean, x_P_N)
```

```
[1] TRUE
```

```r
all.equal(grand_mean, x_N_P)
```

```
[1] TRUE
```


## What about variances/standard deviations?
Now, let's assume independence over voxels and over people.  Note, this is usually a really bad assumption, at least over voxels or whatever $P$ represents, but let's calculate some numbers.

### Theoretical Variances
As we know the distribution of the data, we can calculate the theoretical variances.  We know that $x_{ij} \sim (\mu, \sigma^2)$ and we know the $x_{ij}$ are independent.  

The variance of the grand mean is:

$$\begin{align}
Var(M_{NP}) &= Var\left( \frac{1}{N \times P} \sum_{j=1}^{P} \sum_{i=1}^{N} x_{ij} \right) \newline
&=  \frac{1}{N^2 P^2} Var\left( \sum_{j=1}^{P} \sum_{i=1}^{N} x_{ij} \right) \newline
&=  \frac{1}{N^2 P^2} \sum_{j=1}^{P} \sum_{i=1}^{N} Var\left(  x_{ij} \right) \newline
&=  \frac{1}{N^2 P^2} \sum_{j=1}^{P} \sum_{i=1}^{N} \sigma^2 \newline
&=  \frac{1}{N P} \sigma^2
\end{align}$$

As we know that $\sigma^2 = 1$ from the simulation, we can calculate the theoretical value:


```r
true.var/(N*P)
```

```
[1] 1e-06
```

We would calculate this variance by:

$$
\hat{\sigma}_N(M_{NP}) = \frac{1}{NP} \frac{1}{ NP-1} \sum_{k=1}^{NP} (x_{k} - 
M_{NP})^2
$$


```r
var(c(X))/(N*P)
```

```
[1] 9.982729e-07
```

We can look at the variances of each mean over the different columns or rows.  The subscript $N$ or $P$, represents which are taking variances over:

$$\begin{align}
\hat{\sigma}^2_N(M_{NP}) &= \frac{1}{N} \frac{1}{ N-1} \sum_{i=1}^{N} (\bar{x}_{iP} - M_{NP})^2 \newline
&= \frac{1}{N} \frac{1}{N-1} \left( (\bar{x}_{1P} - M_{NP})^2 + (\bar{x}_{2P} - M_{NP})^2 + \cdots + (\bar{x}_{NP} - M_{NP})^2 \right) \newline
\hat{\sigma}^2_P(M_{NP}) &= \frac{1}{P} \frac{1}{P-1} \sum_{j=1}^{P} (\bar{x}_{Nj} - M_{NP})^2 \newline
&= \frac{1}{P} \frac{1}{P-1} \left( (\bar{x}_{N1} - M_{NP})^2 + (\bar{x}_{N2} - M_{NP})^2 + \cdots + (\bar{x}_{NP} - M_{NP})^2 \right) 
\end{align}$$

### Simulation Variances
Although the means are equal on the margins, we see that the variances are very different.  How do they compare?


```r
var(x_iP)
```

```
[1] 0.0001198331
```

```r
var(x_Nj)
```

```
[1] 0.01000895
```

```r
var(x_iP) / var(x_Nj)
```

```
[1] 0.01197259
```

## So what are the variances?
We can see though, that the variances actually estimate the true variance, divided by the respective margin, which is the variance of each estimate's sampling distribution:


```r
true.var/P
```

```
[1] 1e-04
```

```r
var(x_iP)
```

```
[1] 0.0001198331
```

```r
true.var/N
```

```
[1] 0.01
```

```r
var(x_Nj)
```

```
[1] 0.01000895
```



## Assumptions of Independence
Averaging across $P$ for each person gives a scalar per person.  In many applications, we assume that values are independent across people, but not measurements within a person.  Therefore, $\sigma^2_N(M_{NP})$ may violate fewer assumptions of independence than $\sigma^2_P(M_{NP})$, which may in turn violate fewer assumptions of independence than $\sigma^2(M_{NP})$.  



## Conclusion: Interpretation is important
Thus, if the marginal means are the same, but the marginal variances are different.  The variance--and usually therefore the confidence interval-- depend on the interpretation of the quantity in question.  

If one is not explicit in which margin they are taking, a standard deviation is almost useless.  In that case, some nefarious author could "choose" the variance that they want.  Choosing the variances leads to choosing the confidence interval and conclusion wanted.  Therefore, one must be explicit when reporting means and standard deviations where it is not clear which margin the variance is taken over.





