## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
library(knitr)
opts_chunk$set(echo=TRUE, prompt=FALSE, message=FALSE, warning=FALSE, comment="", results='hide')

## ----, eval=FALSE--------------------------------------------------------
## devtools::install_github("muschellij2/matlabr")

## ----readin--------------------------------------------------------------
library(matlabr)
options(matlab.path = "/Applications/MATLAB_R2014b.app/bin")
have_matlab()

## ----code, results='markup', message=TRUE--------------------------------
code = c("x = 10", 
         "y=20;", 
         "z=x+y", 
         "a = [1 2 3; 4 5 6; 7 8 10]",
         "save('test.txt', 'x', 'a', 'z', '-ascii')")
res = run_matlab_code(code)

## ----, results='markup'--------------------------------------------------
file.exists("test.txt")

## ----, results='markup'--------------------------------------------------
output = readLines(con = "test.txt")
print(output)

