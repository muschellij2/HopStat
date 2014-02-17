## Problem Setup
I had noted in a [previous post](http://hopstat.wordpress.com/2014/01/11/creating-stata-dtas-from-r-issues-and-resolutions/) that I have been using the [`XML`](http://cran.r-project.org/web/packages/XML/index.html) package in `R`  to process an XML from an export of our database.  I used `xmlToDataFrame` to change from an XML set to an `R` `data.frame` and I have found it to be remarkably slow.  After some Googling, I found a [link](https://groups.google.com/forum/#!topic/r-help-archive/qp83D5NRBAc) where the author states that `xmlToDataFrame` is a generic function and if you know the structure of the data, you can leverage that to speed up the function.

So, that's what I did for my data.  I think this structure is applicable to similar data structures in XML, so I thought I'd share.

### Data Structure
Let's look at the data structure.  For my data, an example XML would be:

```
<?xml version="1.0" encoding="UTF-8"?>
<export date="13-Jan-2014 14:08 -0600" createdBy="John Muschelli" role="Data Manager">

  <dataset1>
    <ID>001</ID>
    <age>50</age>
    <field3>blah</field3>
    <field4 />
  </dataset1>
  <dataset2>
    <ID>001</ID>
    <visit>1</visit>
    <scale1>20</scale1>
    <scale2 />
    <scale3>20</scale3>
  </dataset2>
  <dataset1>
    <ID>002</ID>
    <age>40</age>
    <field4 />
  </dataset1>  
</export>  
```

which tells me a few things:

1. I'm XML (first line).  There are other pieces of information which can be extracted as tags, but we won't cover that here.
2. This is part of a large field called `export` (a parent in XML talk I believe) (second line)
3. Datasets are a `child` of `export` (it's nested in `export`).  For example, we have `dataset1` and `dataset2` in this export.  
4. There are missing data points, either references by `<tag></tag>` or `<tag />`.  Both are valid XML.
5. Not all records of the datasets have all fields.  The second record of `dataset1` doesn't have fields `field3` but has `field4`.

So I wrote this function to make my `data.frame`s, which I found to be much faster for conversion for large datasets.


```r
require(XML)
xmlToDF = function(doc, xpath, isXML = TRUE, usewhich = TRUE, verbose = TRUE) {
    
    if (!isXML) 
        doc = xmlParse(doc)
    #### get the records for that form
    nodeset <- getNodeSet(doc, xpath)
    
    ## get the field names
    var.names <- lapply(nodeset, names)
    
    ## get the total fields that are in any record
    fields = unique(unlist(var.names))
    
    ## extract the values from all fields
    dl = lapply(fields, function(x) {
        if (verbose) 
            print(paste0("  ", x))
        xpathSApply(proc, paste0(xpath, "/", x), xmlValue)
    })
    
    ## make logical matrix whether each record had that field
    name.mat = t(sapply(var.names, function(x) fields %in% x))
    df = data.frame(matrix(NA, nrow = nrow(name.mat), ncol = ncol(name.mat)))
    names(df) = fields
    
    ## fill in that data.frame
    for (icol in 1:ncol(name.mat)) {
        rep.rows = name.mat[, icol]
        if (usewhich) 
            rep.rows = which(rep.rows)
        df[rep.rows, icol] = dl[[icol]]
    }
    
    return(df)
}
```


### Function Options
So how do I use this?:

  *  You need the `XML` package.
  *  `doc` is an parsed XML file. For exmaple, run: 

```r
doc = xmlParse("xmlFile.xml")
```

  *  `xpath` is an [XPath](http://www.w3schools.com/xpath/) expression extracting the dataset you want.  For example if I wanted `dataset1`, I'd run:

```r
doc = xmlParse("xmlFile.xml")
xmlToDF(doc, xpath = "/export/dataset1")
```

  *  You can set `isXML=FALSE` and pass in a character string of the xml filename, which just parses it for you.

```r
xmlToDF("xmlFile.xml", xpath = "/export/dataset1", isXML = FALSE)
```

  *  `usewhich` just flags if you should use `which` for subsetting.  It seems faster, and I'm trying to think of reasons logical subsetting would be faster.  This doesn't change functionality really as long as `which` returns something of length `> 1`, which it should by construction, but maybe speed up the code for large datasets.
  * `verbose` - do you want things printed to screen?

### Function Explanation
So what is this code doing?: 

1.  Parses the document (if `isXML = FALSE`)
2.  Extracts the nodes that are for that specific dataset.
3.  Get's the variable names for each record (`var.names`)
4.  Takes the union of all those variable names (`fields`).  This will be the variable names of the resultant dataset.  If every record had all fields, then this would be redundant, but this is a safer way of getting the column/variable names.
5.  Extract all the values from each field for each record (`dl`, which is a list).
6.  For each record, a logical matrix is made to record if that record had that field represented in XML.
7. A loop over each field then fills in the values to the `data.frame`.
8. `data.frame` is returned.


## Timing differences
Obviously, I wanted to use this because I think it'd be faster than `xmlToDataFrame`.  First off, what was the size of the dataset I was converting?  

```r
dim(df$df.list[[1]])
# [1] 16824 161
```

So *only* `16824` rows and `161` columns.  Let's see how long it took to convert using `xmlToDataFrame`:
```
    user   system  elapsed 
4194.900   93.590 4288.996 
```
Where each measurement is in seconds, so that's over 1 hour! I think this is pretty long, and don't know all the checks going on, so that may not be unreasonable to those who have used this package a lot.  But I think that's unscalable for *large* datasets.

What about `xmlToDF`? 
```
   user  system elapsed 
225.004   0.356 225.391 
```
which takes about 4 mintues.  This is significantly faster, and makes it reasonable to parse the `150` or so datasets I have.  

## Conclusion
This function (`xmlToDF`) may be useful if you're converting XML to a `data.frame` with similar structure from XML.  If you're data is different, then you may have to tweak it to make it fit your needs. I understand that the `for loop` is probably not the most efficient, but it was clearer in code to those I'm writing for (other collaborators) and the efficiency gains from using this function over the `xmlToDataFrame` were enough for our needs.

The code is hosted [here](https://github.com/muschellij2/processVISION/blob/master/R/processVISION.R).  Also, you can use this function (and any updates that are made) by using the `processVISION` pacakge:


```r
require(devtools)
install_github("processVISION", "muschellij2")
```

