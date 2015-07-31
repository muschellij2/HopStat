## ----label=opts, results='hide', echo=FALSE, message = FALSE, warning=FALSE----
library(knitr)
opts_chunk$set(echo=TRUE, prompt=FALSE, message=FALSE, warning=FALSE, comment="", results='hide')

## ---- eval=FALSE---------------------------------------------------------
## library(devtools)
## install_github("muschellij2/latexreadme")

## ------------------------------------------------------------------------
library(latexreadme)

## ------------------------------------------------------------------------
args(parse_latex)

## ----example, cache=TRUE-------------------------------------------------
rmd = file.path(tempdir(), "README_unparse.rmd")
download.file(
"https://raw.githubusercontent.com/muschellij2/Github_Markdown_LaTeX/master/README_unparse.rmd",
destfile = rmd, method = "curl")
new_md = file.path(tempdir(), "README.md")
parse_latex(rmd,
            new_md,
            git_username = "muschellij2",
            git_reponame = "Github_Markdown_LaTeX")
library(knitr)
new_html = pandoc(new_md, format = "html")

## ----showhtml, eval=FALSE------------------------------------------------
## browseURL(new_html)

