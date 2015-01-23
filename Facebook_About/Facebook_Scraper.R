rm(list=ls())
library(RCurl)
library("httr")
library(XML)
datadir = "~/Dropbox/Public/WordPress_Hopstat/Facebook_About"
url.stub = "https://research.facebook.com/"

cafile <- system.file("CurlSSL", "cacert.pem", package = "RCurl")
# Read page
page <- GET(
  url.stub, 
  path="datascience", 
  config(cainfo = cafile)
)

x <- content(page, as="text")

#########################
# Parse HTML
#########################
doc <- htmlTreeParse(x, asText=TRUE, useInternal=TRUE)


#########################
# Get face URLs
#########################
stub = "//div[@class = '_iew']"
urls = xpathSApply(doc, 
  path=paste0(stub, "//a"), 
	xmlGetAttr, "href")
url = urls[1]

get.about = function(url){
	
	url.page <- GET(
	  url.stub, 
	  path=url, 
	  config(cainfo = cafile)
	)

	xurl <- content(url.page, as="text")

	doc.url <- htmlTreeParse(xurl, asText=TRUE, useInternal=TRUE)
	name = xmlValue(getNodeSet(doc.url, 
		"//div[@class = '_47n9 _47n8']//h1")[[1]])

	xx = xmlValue(getNodeSet(doc.url, 
		"//div[@class = '_57y3 _2_a']//p")[[1]])
	names(xx) = name
	print(name)
	c(name=name, about=xx)
}

abouts = t(sapply(urls, get.about))
rownames(abouts) = abouts[,1]
abouts = abouts[,2, drop=FALSE]
colnames(abouts) = "About"

write.csv(abouts, 
	file = file.path(datadir, "Facebook_About.csv"))


library(tm)
library(wordcloud)


  corpus <- Corpus(DataframeSource(data.frame(abouts)))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, function(x) removeWords(x, stopwords("english")))

  addstopwords = c("use")
  corpus <- tm_map(corpus, function(x) 
    removeWords(x, addstopwords))
  
  tdm <- TermDocumentMatrix(corpus)
  m <- as.matrix(tdm)
  v <- sort(rowSums(m),decreasing=TRUE)
  d <- data.frame(word = names(v),freq=v)
  
  pal = brewer.pal(9, "RdPu")
  pal <- pal[-(1:4)]
  

  pngname = file.path(datadir, "Facebook_About.png")
  png(pngname, height=7, width=7, units = 'in', res=600)
  wordcloud(words = d$word, freq = d$freq, 
            min.freq = 1, max.words = Inf,
            random.order = FALSE, colors = pal,
            vfont=c("sans serif","plain"))
  dev.off()

  fb.names= rownames(abouts)
  library(googleCite)
  fb.names = sapply(fb.names, function(x){
  	print(x)
  	searchCite(x, gCite = FALSE)
  })

  drop = sapply(fb.names, function(x){
  	any(x == "No Author found")
  })

  run.fb.names = fb.names[!drop]

  sapply(run.fb.names, function(x){
  	auth = x$names[[1]]
  	auth = gsub(" ", "_", auth)

  	pngname = file.path(datadir, paste0(auth, ".png"))
  	if (!file.exists(pngname)) {
	  	png(pngname, height=7, width=7, units = 'in', res=600)
	  		googleCite(x$url, plotIt=TRUE)
	  	dev.off()
	 }
  	print(auth)
    })