My first package on CRAN
========================================================

Recently, I submitted a [paper](http://works.bepress.com/john_muschelli/3/) to the [R Journal](http://journal.r-project.org/).  I had a repository ("repo") on GitHub for it and the editor said that R Journal tries to only accept CRAN packages.  After classes and holidays, I finally got it [accepted](http://cran.r-project.org/web/packages/brainR/index.html).  I'll post about that package later, but I wanted to talk about some of the ins and outs I noticed that may have been helpful.

First things first.

[Writing R Extensions](http://cran.r-project.org/doc/manuals/R-exts.html) is *THE* manual for doing this.  It answers almost every question you have.  Use it.  CRAN has its own [POLICIES](http://cran.r-project.org/web/packages/policies.html).  Read them, they are necessary.

The CRAN team is amazing.  Granted, if you don't read the documentation, you will receive some rightfully-curt emails saying you didn't do X,Y,Z as I did.  Preparation is good before going to the show with your package.


### Things I recommend

* Use [RStudio](http://www.rstudio.com/) and [`devtools`](https://github.com/hadley/devtools).  They make things much easier.  Go to `File -> New Project` and make a git repository.  This creates a `.rproj` file that allows you to start a separate RStudio session, that has some fun options.
* Use a git repository.  I'd suggest either [GitHub](https://github.com/) or [BitBucket](https://bitbucket.org/).  BitBucket allows private repositories for free with a .edu email, but GitHub is more popular.  Either way, you're developing software, so do some version control.  Also, and put it online so it's backed up and people can use it and install it either using `install_github` or `install_bitbucket` from `devtools`.
* Use [roxygen](http://roxygen.org/) for documentation.  You have code and documentation in the same and it makes things so much easier.  Period.

### Setup
Now you have `devtools` and a new project in RStudio, then go into your project and go to `Build -> Configure Build Tools...` and add `--as-cran` to `Check Package` and check `Generate documentation with Roxygen`.  Then go to `Configure...` next to that checkbox and I'd check all the boxes. 

Almost all of this is explained as well from [Developing Packages with RStudio](http://www.rstudio.com/ide/docs/packages/overview).  You will only see this link in the RStudio application after you set up the project though, which seems odd.  

Also, if you created an online git repository, go to Git/SVN and make sure it's there.  Again, [RStudio has documentation on this](http://www.rstudio.com/ide/docs/version_control/overview?version=0.98.490&mode=desktop), but this is viewable under preferences if you're not in a project.

### Submitting to CRAN
Now, obviously you have to write the documentation and functions in your `R` package.  But when you submit to CRAN, here are some suggestions.

A few notes:

* the `inconsolata` package was a hassle and caused warnings with the PDF See [this](http://r.789695.n4.nabble.com/While-using-R-CMD-check-LaTex-error-File-inconsolata-sty-not-found-td4671431.html) and [this](http://r.789695.n4.nabble.com/inconsolata-sty-is-liable-to-disappear-texinfo-5-1-td4669976.html) for better ways to fix this.
  I fixed this by using option 2, but you can fix this 1 of 2 ways (Mac/Unix):
    * Copy zi4.sty to inconsolata.sty in the inconsolata package.  For me, this was in "/usr/local/texlive/2013/texmf-dist/tex/latex/inconsolata", which is user-dependent and which year they have MacTeX installed.  MikTeX for Windows will be in a different directory.
    * Copy zi4.sty to inconsolata.sty and move this this in "/usr/local/texlive/texmf-local". 
  The first option will work, but only for this version of TeX (which hopefully is fixed by the next iteration).  It may be preferred if you a) don't like local texmf directories, b) don't want to change your PATH to have these local directories or c) have no idea what I'm talking about.
* Make sure you turn off HTML emails.  In Gmail, on the bottom right corner, there is a down arrow, that allows you enable "plain text".  Don't send HTML emails to CRAN (they don't like that).
* Look here for submitting [http://www.r-bloggers.com/how-to-check-your-package-with-r-devel/](http://www.r-bloggers.com/how-to-check-your-package-with-r-devel/).  Download the `R`-development branch [http://r.research.att.com/](http://r.research.att.com/) and `Rswitch` as recommended.


Overall, once you get the functions and package made (hard part), you should take some time to sit and read the submission process.  It'll save you time later.  Also, setting up the build options to be like CRAN from the beginning will have you poised to field more problems.


### Links to better tutorials:
* [http://blog.revolutionanalytics.com/2009/08/creating-r-packages-a-tutorial-draft.html](http://blog.revolutionanalytics.com/2009/08/creating-r-packages-a-tutorial-draft.html)
* [http://cran.r-project.org/doc/contrib/Leisch-CreatingPackages.pdf](http://cran.r-project.org/doc/contrib/Leisch-CreatingPackages.pdf)
* Way step by step: [http://stevemosher.wordpress.com/step-one-update-your-r-and-other-tools/](http://stevemosher.wordpress.com/step-one-update-your-r-and-other-tools/)


