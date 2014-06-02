
Last year, [Aaron Fisher](http://aaronjfisher.github.io/) spoke at a computing club about a text expander named [Typinator](http://www.ergonis.com/products/typinator/).  In the past year, I have used it for the majority of my LaTeX and math writing and wanted to discuss a bit why I think Typinator is useful to use.

### Seeing your Math symbols
The main reason to use Typinator is to expand text to [unicode](http://en.wikipedia.org/wiki/Unicode) -- symbols such as $β$ instead of writing \beta in LaTeX.  When I say "expand text" is I type a set string that I set in Typinator and it replaces that string with the symbol or phrase that I designated as the replacement.  I type `:alpha` and out comes an $α$ symbol.  

### Why should you care
Writing \alpha or `:alpha` saves no time -- it's the same number of characters.  I like using unicode because I like reading **in the LaTeX**: 
$$
Y = X β + ε
$$
instead of 
```
Y = X \beta + \varepsilon
```
and "the $β$ estimate is" versus "the \$\beta\$ estimate is".  

### `pdflatex` doesn't show my characters! Use XeLaTeX

Running `pdflatex` on your LaTeX document will not render these symbols out of the box, depending on your encoding.  Using the package LaTeX `inputenc` with a command such as `\usepackage[utf8x]{inputenc}` can incorporate unicode (according to [this StackExchange Post](http://tex.stackexchange.com/questions/34604/entering-unicode-characters-in-latex)), but I have not used this so I cannot confirm this.

I use [XeLaTeX](http://en.wikipedia.org/wiki/XeLaTeX), which has unicode support.  I also set my font type, and in my preamble I have

```
\usepackage{ifxetex}
\ifxetex
  \usepackage{unicode-math}
  \setmathfont{[Asana-Math]}
\fi
```

I then run the `xelatex` command on the document and the $α$ appears in the PDF and all is good in the world.  

You can also incorporate `xelatex` in your `knitr` documents in RStudio by going to `RStudio -> Preferences -> Sweave Tab -> Typset LaTeX into PDF using` and change this option to `XeLaTeX`.  Now you're ready to knit with unicode!


## Other uses for Unicode than LaTeX
If you don't use LaTeX, this information is not useful but Unicode can be used in other than LaTeX.  Here are some instances where I use Unicode other than LaTeX:

1.  Twitter.  Using β or ↑/↓ can be useful in conveying information as well as [saving characters](https://twitter.com/StrictlyStat/status/466317463899357184) or writing things such as 𝜃̂.
2.  E-mail.  Using Gmail or with emailing class rosters (such as in CoursePlus), using symbols such as σ^2 versus \sigma\^

