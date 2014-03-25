

library(reshape2)
library(plyr)
library(stringr)
suppressMessages(library(zoo))
getslot = function(x, slot){
	x[slot]
}

get.rundown = function(username=NULL, all.q = TRUE){
	out = system('qstat -u "*"', intern=TRUE)
	out = out[3:length(out)]
	out = gsub(" +", " ", out)
	out = str_trim(out)

	### keep only ones that are running
	ss = strsplit(out, " ")
	running = sapply(ss, getslot, slot=5)
	out = out[running == "r"]
	ss = strsplit(out, " ")

	### just grab username and queue
	user.q = t(sapply(ss, getslot, slot=c(4,8)))
	user.q = data.frame(user.q, stringsAsFactors=FALSE)
	colnames(user.q) = c("user", "queue")
	### don't want the node - just the queue
	ss = strsplit(user.q$queue, split="@")
	user.q$queue = sapply(ss, getslot, slot=1)

	### taking off the trailing .q
	user.q$queue = gsub("\\.q", "", user.q$queue)
	### table of number of jobs by each queue
	indiv.q = tapply(user.q$user, user.q$queue, 
		function(x) {
			sort(table(x), decreasing=TRUE)
		})
	user.table = sort(table(user.q$user), decreasing=TRUE)
	standard = user.q[user.q$queue == "standard", ]


	user.tab = NULL
	if (!is.null(username)) {
		dat = user.q
		if (all.q) dat$queue = factor(dat$queue)
		dat = dat[dat$user == username,]
		if (nrow(dat) == 0)  dat[1,] = c(username, NA)
		user.tab = table(dat$user, dat$queue, useNA='no')
	}
	return(list(user.q=user.q, 
		standard = standard, 
		q.users=indiv.q,
		user.table = user.table,
		user.tab = user.tab))
}



## out = get.rundown(user='jmuschel')
## print(out$user.tab)
## #            cegs chaklab download gwas interactive jabba mathias ozone sas
## #   jmuschel    0       0        0    0           1     0       0     0   0
## #
## #            standard stanley
## #   jmuschel        0       0



#### get resources for different queue and nodes
get.resource = function(){
  out = system('qstat -u "*" -F', intern=TRUE)
  out = out[2:length(out)]
  qs = grep("-----------", out)+1
  out = cbind(out, NA)
  out[qs, 2] = out[qs,1]
  colnames(out) = c("info", "node")
  out = data.frame(out, stringsAsFactors=FALSE)
  out$node = na.locf(out$node, na.rm=FALSE)
  ss= strsplit(out$node, " ")
  out$node = sapply(ss, getslot, 1)
  out = out[ -(c(qs -1, qs)), ]
  out$queue = gsub("(.*).q@(.*)", "\\1", out$node)
  out$info = gsub("\thl:", "", out$info)
  out$info = gsub("\tqf:", "", out$info)
  out$info = gsub("\tqc:", "", out$info)

  keeprows = grepl("mem_|swap_|virtual_|^cpu", out$info)
  out = out[keeprows, ]
  out$var = gsub("(.*)=(.*)", "\\1", out$info)
  out$value = gsub("(.*)=(.*)", "\\2", out$info)

  cpu = out[ out$var == "cpu", ]
  out = out[ out$var != "cpu", ]
  out$tf = gsub("(.*)_(.*)", "\\2", out$var)
  out$var = gsub("(.*)_(.*)", "\\1", out$var)
  out$gorm =  gsub("(.*)(.)$", "\\2", out$value)
  ### T is future hopes...
  stopifnot(all(out$gorm %in% c("0", "G", "K", "M", "T")))
  ### all output is in gigabytes
  out$value = as.numeric( gsub("G|K|M", "", out$value))
  out$value[out$gorm == "M"] = out$value[out$gorm == "M"]/1024
  out$value[out$gorm == "K"] = out$value[out$gorm == "K"]/(1024*1024)
  out$gorm = out$info = NULL

	varwide = dcast(out, queue + node + var ~ tf, value.var = "value")
	tfwide = dcast(out, queue + node + tf ~ var, value.var = "value")
	wide = dcast(out, queue + node  ~ var + tf, value.var = "value")

	agg = wide[ ,!colnames(wide) %in% "node"]
	agg = ddply(.data=agg, 
		.(queue), function(x) {
			colSums(x[ ,!colnames(x) %in% "queue"], na.rm=TRUE)
		})

	return(list(out=out,
		varwide=varwide,
		tfwide = tfwide,
		wide=wide,
		byqueue = agg))
}



## x= get.resource()
## agg = x$byqueue
## agg[agg$queue == "standard", ]
## #       queue mem_free mem_total mem_used swap_free swap_total swap_used
## # 16 standard  5233.08  6564.179 1331.098  6526.928   6568.344  41.41569
## #    virtual_free virtual_total virtual_used
## # 16     11760.01      13132.52     1372.515


