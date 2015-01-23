## Something for Under 36 hours and 36 - 72
## Do this more
##
##

rm(list=ls())
username <- Sys.info()["user"][[1]]
dropdir <- file.path("/Users", username, "Dropbox")
basedir = file.path(dropdir, "CTR/DHanley")
rootdir = file.path(basedir, "MISTIE")
paperdir <- file.path(basedir, "Papers")
homedir = file.path(rootdir, "ICH Analysis")
Mdir = file.path(rootdir, "MISTIE DSMB Analysis")
resdir <- file.path(dropdir, "Hopstat", "Forestplot2")
progdir <- file.path(homedir, "stataprograms")
RD <- function() setwd(progdir)
library(binom)
library(rmeta)
library(tm)
library(RColorBrewer)
source(file.path(progdir, "Forestplot2.R"))
source(file.path(progdir, "Forestplot3.R"))

load(file=file.path(homedir, "statacalc", 'MISTIE_STICH_Data.Rda'))

tryout$Category[tryout$Category == "Site of haematoma"] <- "Site"
tryout$Category[tryout$Category == "Haematoma volume"] <- "ICH Volume"
tryout$Category[tryout$Category == "Time to Randomization"] <- "To Randomization"


##### PLOTS START HERE
		# where the main should be put
		myy <- 0.82

		colnames(tryout)[colnames(tryout) == "OR.95..CI"] <- "OR.95.CI"
		## font size
		fs <- 8.5
		## graph width
		gwidth <- 3.5
		addci <- ""
			# addci <- ".95.CI"
		ranges <- c(0.15, 2.5)
		xrange <- clip <- log(ranges)
		xticks <- unique(c(ranges[1], 0.5, 1, 1.5, 2, ranges[2]))

		scaler <- gwidth / 1.5
	    addit <- 0.04* scaler
	    if (addci != "") addit <- 0.04 * gwidth /2
		indent <- "  "


		colnames(tryout)[colnames(tryout) == "OR.95..CI"] <- "OR.95.CI"
		fs <- 15
	
		gwidth <- 2.5
		below <- TRUE		
	    yy <- c(0.78)
		if (below) yy <- c(0.15)
		# myy <- 0.9
	  
	    # dev.off()
	    
		l <- as.numeric(tryout$STICH_Lower)
		m <- as.numeric(tryout$OR)
		u <- as.numeric(tryout$STICH_Upper)
		
		fontsize <- rep(fs, length(m))
		# fontsize[tryout$Category == "Time to Randomization"] <- fs/1.5			
		tabletext <- tryout[, c("Category", "STICH_N")] #"OR.95.CI",


   		
		
   		color.levs <- brewer.pal(9,"PuBu")
		cols <- rep(color.levs[9], length(m))
		# cols[tabletext$Category == ">= 36 hours"] <- "red"
		# cols[tabletext$Category == "<= 50 mL"] <- "orange"
		# cols[tabletext$Category == "> 50 mL"] <- "orange"
		# cols[tabletext$Category == "Not Lobar"] <- "green"		
#		cols[makered] <- "red"
		textcols <- rep("black", length(m))
#		textcols[tabletext$Category=="Not Lobar"] <- "black"
		lcols <- rep(color.levs[5], length(m))
#		lcols <- paste("dark", cols, sep="")


 	    tryout2 <- tryout
   		is.summary <- is.na(as.numeric(tryout2$OR))

		tryout2$Category[!is.summary] <- paste("", tryout2$Category[!is.summary], sep=indent)   	    
 	    
	    pdf(file=file.path(resdir, "Toy_Study2.pdf"))

		
	    xx <- c(0.645, 0.86) + addit - 0.052*(addci == "")

		tabletext <- tryout[, c("Category", "STICH_N")] #"OR.95.CI",

		tabletext <- tryout[, c("Category")]
		tabletext <- data.frame(Category=tabletext, stringsAsFactors=FALSE)	
		tabletext$Category <- ""
		tabletext$Category[1] <- NA
		is.summary <- is.na(as.numeric(tryout$OR))
		fontsize[is.summary] <- fontsize[is.summary]*1.2
 
				
   		makered <- tryout2$Category %in% paste(indent, c(">= 36 hours", "<= 50 mL", "> 50 mL", "Not Lobar"), sep="")
   		
   				
		forestplot2(tabletext, log(m), log(l), log(u), clip=clip, zero=0, xlog=TRUE, is.summary=is.summary  , 
			 col=meta.colors(box=cols,line=lcols, summary="royalblue", text=textcols), fontsize=fontsize, xticks=xticks, graphwidth=unit(gwidth, "inches"), xrange=xrange, cgap=unit(0, "mm"))
		main <- paste("Odds Ratios for Study 2, Log scale", sep="")
	    grid.text(main, x=unit(0.5, "npc"), y=unit(myy, "npc"), gp=gpar(fontsize=fs))
   		grid.text("Favors: Trt", x=unit(xx[1]-0.25, "npc"), y=unit(yy, "npc"), gp=gpar(fontsize=fs))    
   		# 0.78
   		grid.text("Placebo", x=unit(xx[2]-0.2 - .025*(gwidth== 2.5), "npc"), y=unit(yy, "npc"), gp=gpar(fontsize=fs)) 
   		   
  	    dev.off() 

  	    
		addci <- ""
			# addci <- ".95.CI"
		scaler <- gwidth / 1.5
	    addit <- 0.04* scaler
	    if (addci != "") addit <- 0.04 * gwidth /2
		l <- as.numeric(tryout$Lower)
		m <- as.numeric(tryout$MISTIE_OR)
		u <- as.numeric(tryout$Upper)
		tabletext <- tryout[, c("Category")] #"MISTIE_OR.95.CI"
		tabletext <- data.frame(Category=tabletext, stringsAsFactors=FALSE)	    	    	
	      	    
	pdf(file=file.path(resdir, "Toy_Study1.pdf"))

	    xx <- c(0.62, 0.83) + addit
		is.summary <- is.na(as.numeric(tryout$MISTIE_OR))
		tabletext$Category[!is.summary] <- paste("", tabletext$Category[!is.summary], sep=indent)
		
		tabletext$Category[is.summary] <- paste("Category", 1:sum(is.summary))
		tabletext$Category[which(!is.summary)] <- c(paste("Level", 1:2), paste("Level", 1:3), rep(paste("Level", 1:2), 4))
		
   		makered <- tabletext$Category %in% paste(indent, c(">= 36 hours", "<= 50 mL", "> 50 mL", "Not Lobar"), sep="")
   			    
		cols <- rep(color.levs[9], length(m))
		cols[4] <- "red"
		# cols[tabletext$Category == "<= 50 mL"] <- "orange"
		# cols[tabletext$Category == "> 50 mL"] <- "orange"
		# cols[tabletext$Category == "Not Lobar"] <- "green"		
#		cols[makered] <- "red"
		textcols <- rep("black", length(m))
#		textcols[tabletext$Category=="Not Lobar"] <- "black"
		lcols <- rep(color.levs[5], length(m))
		lcols[4] <- "darkred"
#		lcols <- paste("dark", cols, sep="")

		
		
		# lcols <- paste("dark", cols, sep="")
		# lcols[cols == "royalblue"] <- "darkblue"
		# textcols <- rep("gray", length(m))
		# textcols[tabletext$Category=="Not Lobar"] <- "black"
				
		forestplot2(tabletext, log(m), log(l), log(u), clip=clip, zero=0, xlog=TRUE, is.summary= is.summary , 
			 col=meta.colors(box=cols,line=lcols, summary="royalblue", text=textcols), fontsize=fontsize, graphwidth=unit(gwidth, "inches"), xrange=xrange, cgap=unit(0, "mm"), xticks=xticks)
		main <- paste("Odds Ratios for Study1 Log scale", sep="")
	    grid.text(main, x=unit(0.5, "npc"), y=unit(myy, "npc"), gp=gpar(fontsize=fs))
   		grid.text("Favors: Trt", x=unit(xx[1]-0.2, "npc"), y=unit(yy, "npc"), gp=gpar(fontsize=fs))    
   		grid.text("Placebo", x=unit(xx[2]-0.175, "npc"), y=unit(yy, "npc"), gp=gpar(fontsize=fs)) 
   		
	  dev.off()  	    


  	 
  	 
  	 
  	    
iadd <- 3
setwd(resdir)
	texfile <- paste("Toy_Example.tex", sep="")
	
	tex <- NULL
	tex <- c("\\documentclass{article}", 
	"\\usepackage{float}", 
	"\\usepackage{verbatim}", 
	"\\usepackage{graphicx}", 
	"\\usepackage{onimage}", 
	"\\usepackage[active, tightpage]{preview}", 
	"\\PreviewEnvironment{tabular}", 
	"\\begin{document}", 
	"% Define block styles", 
	"\\begin{tabular}{cc}")
	

	mtrim <- strim <- c(0, 2, 1, 2)
	coords <- c(0.5, 1)
	if (iadd > 2) {
		coords <- c(0.4, 0.7)
		mtrim <- strim <- c(2.75, 2, 2, 2)
		strim[1] <- 4.8
		strim[3] <- 4
	}	
	
	mtrim <- paste(mtrim, "", sep="cm", collapse = " ")
	mtrimmer <- paste("[trim=", mtrim, ", clip=TRUE]", sep="")

	strim <- paste(strim, "", sep="cm", collapse = " ")
	strimmer <- paste("[trim=", strim, ", clip=TRUE]", sep="")
	
	boxes <- c(red=paste("    \\draw [red, line width=1pt] (", coords[1], ",0.22) rectangle (", coords[2], ", 0.2525);", sep=""), orange=paste("    \\draw [orange, line width=1pt] (", coords[1], ", 0.35) rectangle (", coords[2], ", 0.46);", sep=""), green=paste("    \\draw [green, line width=1pt] (", coords[1], ",0.48) rectangle (", coords[2], ", 0.51);", sep=""))
	boxes <- ""
	
	
	tex <- c(tex, 
	paste("\\begin{tikzonimage}", mtrimmer, "{Toy_Study1.pdf}", sep=""), 
	"%    \\draw [orange, line width=1pt] (0.5,0.25) rectangle (1, 0.3);", 
	"\\end{tikzonimage} & ")
	


	tex <- c(tex, 
	paste("\\begin{tikzonimage}", strimmer, "{Toy_Study2.pdf}", sep=""), 
	paste("%    \\draw [green, line width=1pt] (", coords[1], ",0.25) rectangle (", coords[2], ", 0.3);", sep=""), 
	boxes[!names(boxes) %in% c("red")],
	"\\end{tikzonimage}", 
	"\\end{tabular}", 
	"\\end{document}")
	
	cat(tex, file=texfile, sep="\n")
	
	
	
	
	
	
	system(sprintf('/usr/texbin/pdflatex "%s"', texfile))
	system(sprintf('open "%s"', gsub(".tex", '.pdf', texfile, fixed=TRUE)))



