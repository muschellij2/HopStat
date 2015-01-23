
# https://gist.github.com/hammady/9046168
   # create a simple prediction object
  rm(list=ls())
   library(ROCR)
   data(ROCR.simple)
   pred <- prediction(ROCR.simple$predictions,ROCR.simple$labels)


define.environments <- function(funnames = NULL, # name of measure
    longnames = NULL, # name of actual thing
    exprs = NULL, # list of 2 character vectors to be expressed
    optargs, # list
    default.vals,
    xaxis
    )
{
  require(ROCR)
  # get original environments
  envir.list <- ROCR::.define.environments()
  long.unit.names = envir.list$long.unit.names
  function.names = envir.list$function.names   
  obligatory.x.axis = envir.list$obligatory.x.axis
  optional.arguments = envir.list$optional.arguments         
  default.values = envir.list$default.values

  # .performance.wss <- function(predictions, labels, cutoffs,
  #   fp, tp, fn, tn, n.pos, n.neg, n.pos.pred, n.neg.pred) # append any optional arguments
  # {
  #   list(cutoffs, (tn+fn)/(n.pos+n.neg) - 1 + tp/(tp+fn))
  # }

  #     assign("wss", "Work Saved over Random Sampling",
  #       envir = long.unit.names)
  #     assign("wss", .performance.wss,
  #       envir = function.names)

  #   .performance.dice <- function (predictions, labels, cutoffs, fp, 
  #       tp, fn, tn, n.pos, 
  #       n.neg, n.pos.pred, n.neg.pred) {
  #       list(cutoffs, 2 * tp / (2*tp + fp + fn))
         
  #   }  


  #   assign("dice", ".performance.dice", 
  #       envir=.define.environments()$function.names)

  #   assign("dice", "Sorensen–Dice coefficient", 
  #       envir=.define.environments()$long.unit.names)    

    #######################################
    # Allow for general adding
    #######################################
    if (!is.null(funnames)){
        stopifnot(
            length(funnames) == length(longnames) &&
            length(funnames) == length(exprs)
            )
        if (!missing(optargs)){
          stopifnot(length(optargs) == length(funnames))
        }
        if (!missing(optargs)){
          stopifnot(length(default.vals) == length(funnames))
        } 
        if (!missing(xaxis)){
          stopifnot(length(xaxis) == length(funnames))
        }                
        for (iname in seq_along(funnames)){
            func <- function (predictions, labels, 
                cutoffs, fp, 
                tp, fn, tn, n.pos, 
                n.neg, n.pos.pred, n.neg.pred) {
                e1 = as.expression(
                    parse(text=exprs[[iname]][[1]])
                    )
                e2 = as.expression(
                    parse(text=exprs[[iname]][[2]])
                    )                
                list(eval(e1), eval(e2))
            }  

            assign(funnames[iname], func, 
                envir=function.names)
            assign(funnames[iname], longnames[iname],
                envir=long.unit.names)
            #############
            # optional arguments
            #############
            if (!missing(optargs)){
              oargs = optargs[[iname]]
              for (ioarg in seq_along(oargs)){
                assign(oargs[[ioarg]][[1]], oargs[[ioarg]][[2]],
                  envir=optional.arguments)
              }
            }

            #############
            # Default values
            #############
            if (!missing(default.vals)){
              oargs = default.vals[[iname]]
              for (ioarg in seq_along(oargs)){
                assign(oargs[[ioarg]][[1]], oargs[[ioarg]][[2]],
                  envir=default.values)
              }
            }

            if (!missing(default.vals)){
              oargs = default.vals[[iname]]
              for (ioarg in seq_along(oargs)){
                assign(oargs[[ioarg]][[1]], oargs[[ioarg]][[2]],
                  envir=obligatory.x.axis)
              }
            }            


        }
    } # is is.null

  list(
    long.unit.names = long.unit.names,
    function.names = function.names,
    obligatory.x.axis = obligatory.x.axis,
    optional.arguments = optional.arguments,
    default.values = default.values
  )
}

# define.environments(funnames = "dice", 
#   longnames = "Sorensen–Dice coefficient", 
#   exprs = list(c("cutoffs", "2 * tp / (2*tp + fp + fn)")))



# copied from original function
performance <- function (prediction.obj, measure, 
    x.measure = "cutoff", ...)
{
    envir.list <- define.environments(...)
    long.unit.names <- envir.list$long.unit.names
    function.names <- envir.list$function.names
    obligatory.x.axis <- envir.list$obligatory.x.axis
    optional.arguments <- envir.list$optional.arguments
    default.values <- envir.list$default.values
    if (class(prediction.obj) != "prediction" || !exists(measure,
        where = long.unit.names, inherits = FALSE) || !exists(x.measure,
        where = long.unit.names, inherits = FALSE)) {
        stop(paste("Wrong argument types: First argument must be of type",
            "'prediction'; second and optional third argument must",
            "be available performance measures!"))
    }
    if (exists(x.measure, where = obligatory.x.axis, inherits = FALSE)) {
        message <- paste("The performance measure", x.measure,
            "can only be used as 'measure', because it has",
            "the following obligatory 'x.measure':\n", get(x.measure,
                envir = obligatory.x.axis))
        stop(message)
    }
    if (exists(measure, where = obligatory.x.axis, inherits = FALSE)) {
        x.measure <- get(measure, envir = obligatory.x.axis)
    }
    if (x.measure == "cutoff" || exists(measure, where = obligatory.x.axis,
        inherits = FALSE)) {
        optional.args <- list(...)
        argnames <- c()
        if (exists(measure, where = optional.arguments, inherits = FALSE)) {
            argnames <- get(measure, envir = optional.arguments)
            default.arglist <- list()
            for (i in 1:length(argnames)) {
                default.arglist <- c(default.arglist, get(paste(measure,
                  ":", argnames[i], sep = ""), envir = default.values,
                  inherits = FALSE))
            }
            names(default.arglist) <- argnames
            for (i in 1:length(argnames)) {
                templist <- list(optional.args, default.arglist[[i]])
                names(templist) <- c("arglist", argnames[i])
                optional.args <- do.call(".farg", templist)
            }
        }
        optional.args <- .select.args(optional.args, argnames)
        function.name <- get(measure, envir = function.names)
        x.values <- list()
        y.values <- list()
        for (i in 1:length(prediction.obj@predictions)) {
            argumentlist <- .sarg(optional.args, predictions = prediction.obj@predictions[[i]],
                labels = prediction.obj@labels[[i]], cutoffs = prediction.obj@cutoffs[[i]],
                fp = prediction.obj@fp[[i]], tp = prediction.obj@tp[[i]],
                fn = prediction.obj@fn[[i]], tn = prediction.obj@tn[[i]],
                n.pos = prediction.obj@n.pos[[i]], n.neg = prediction.obj@n.neg[[i]],
                n.pos.pred = prediction.obj@n.pos.pred[[i]],
                n.neg.pred = prediction.obj@n.neg.pred[[i]])
            ans <- do.call(function.name, argumentlist)
            if (!is.null(ans[[1]]))
                x.values <- c(x.values, list(ans[[1]]))
            y.values <- c(y.values, list(ans[[2]]))
        }
        if (!(length(x.values) == 0 || length(x.values) == length(y.values))) {
            stop("Consistency error.")
        }
        return(new("performance", x.name = get(x.measure, envir = long.unit.names),
            y.name = get(measure, envir = long.unit.names), alpha.name = "none",
            x.values = x.values, y.values = y.values, alpha.values = list()))
    }
    else {
        perf.obj.1 <- performance(prediction.obj, measure = x.measure,
            ...)
        perf.obj.2 <- performance(prediction.obj, measure = measure,
            ...)
        return(.combine.performance.objects(perf.obj.1, perf.obj.2))
    }
}


performance(pred, "dice", funnames = "dice", 
  longnames = "Sorensen–Dice coefficient", 
  exprs = list(c("cutoffs", "2 * tp / (2*tp + fp + fn)")))



my.define.environments <- function(funnames = NULL, # name of measure
    longnames = NULL, # name of actual thing
    exprs = NULL, # list of 2 character vectors to be expressed
    optargs, # list
    default.vals,
    xaxis
    )
{
  require(ROCR)
  # get original environments
  envir.list <- ROCR::.define.environments()
  long.unit.names = envir.list$long.unit.names
  function.names = envir.list$function.names   
  obligatory.x.axis = envir.list$obligatory.x.axis
  optional.arguments = envir.list$optional.arguments         
  default.values = envir.list$default.values

  # .performance.wss <- function(predictions, labels, cutoffs,
  #   fp, tp, fn, tn, n.pos, n.neg, n.pos.pred, n.neg.pred) # append any optional arguments
  # {
  #   list(cutoffs, (tn+fn)/(n.pos+n.neg) - 1 + tp/(tp+fn))
  # }

  #     assign("wss", "Work Saved over Random Sampling",
  #       envir = long.unit.names)
  #     assign("wss", .performance.wss,
  #       envir = function.names)

    .performance.dice <- function (predictions, labels, cutoffs, fp, 
        tp, fn, tn, n.pos, 
        n.neg, n.pos.pred, n.neg.pred) {
        list(cutoffs, 2 * tp / (2*tp + fp + fn))
         
    }  

    assign("dice", .performance.dice, 
        envir=function.names)

    assign("dice", "Sorensen–Dice coefficient", 
        envir=long.unit.names)    

    #######################################
    # Allow for general adding
    #######################################
    if (!is.null(funnames)){
        stopifnot(
            length(funnames) == length(longnames) &&
            length(funnames) == length(exprs)
            )
        if (!missing(optargs)){
          stopifnot(length(optargs) == length(funnames))
        }
        if (!missing(optargs)){
          stopifnot(length(default.vals) == length(funnames))
        } 
        if (!missing(xaxis)){
          stopifnot(length(xaxis) == length(funnames))
        }                
        for (iname in seq_along(funnames)){
            func <- function (predictions, labels, 
                cutoffs, fp, 
                tp, fn, tn, n.pos, 
                n.neg, n.pos.pred, n.neg.pred) {
                e1 = as.expression(
                    parse(text=exprs[[iname]][[1]])
                    )
                e2 = as.expression(
                    parse(text=exprs[[iname]][[2]])
                    )                
                list(eval(e1), eval(e2))
            }  

            assign(funnames[iname], func, 
                envir=function.names)
            assign(funnames[iname], longnames[iname],
                envir=long.unit.names)
            #############
            # optional arguments
            #############
            if (!missing(optargs)){
              oargs = optargs[[iname]]
              for (ioarg in seq_along(oargs)){
                assign(oargs[[ioarg]][[1]], oargs[[ioarg]][[2]],
                  envir=optional.arguments)
              }
            }

            #############
            # Default values
            #############
            if (!missing(default.vals)){
              oargs = default.vals[[iname]]
              for (ioarg in seq_along(oargs)){
                assign(oargs[[ioarg]][[1]], oargs[[ioarg]][[2]],
                  envir=default.values)
              }
            }

            if (!missing(default.vals)){
              oargs = default.vals[[iname]]
              for (ioarg in seq_along(oargs)){
                assign(oargs[[ioarg]][[1]], oargs[[ioarg]][[2]],
                  envir=obligatory.x.axis)
              }
            }            


        }
    } # is is.null

  list(
    long.unit.names = long.unit.names,
    function.names = function.names,
    obligatory.x.axis = obligatory.x.axis,
    optional.arguments = optional.arguments,
    default.values = default.values
  )
}


# copied from original function
myperformance <- function (prediction.obj, measure, 
    x.measure = "cutoff", ...)
{
    envir.list <- my.define.environments(...)
    long.unit.names <- envir.list$long.unit.names
    function.names <- envir.list$function.names
    obligatory.x.axis <- envir.list$obligatory.x.axis
    optional.arguments <- envir.list$optional.arguments
    default.values <- envir.list$default.values
    if (class(prediction.obj) != "prediction" || !exists(measure,
        where = long.unit.names, inherits = FALSE) || !exists(x.measure,
        where = long.unit.names, inherits = FALSE)) {
        stop(paste("Wrong argument types: First argument must be of type",
            "'prediction'; second and optional third argument must",
            "be available performance measures!"))
    }
    if (exists(x.measure, where = obligatory.x.axis, inherits = FALSE)) {
        message <- paste("The performance measure", x.measure,
            "can only be used as 'measure', because it has",
            "the following obligatory 'x.measure':\n", get(x.measure,
                envir = obligatory.x.axis))
        stop(message)
    }
    if (exists(measure, where = obligatory.x.axis, inherits = FALSE)) {
        x.measure <- get(measure, envir = obligatory.x.axis)
    }
    if (x.measure == "cutoff" || exists(measure, where = obligatory.x.axis,
        inherits = FALSE)) {
        optional.args <- list(...)
        argnames <- c()
        if (exists(measure, where = optional.arguments, inherits = FALSE)) {
            argnames <- get(measure, envir = optional.arguments)
            default.arglist <- list()
            for (i in 1:length(argnames)) {
                default.arglist <- c(default.arglist, get(paste(measure,
                  ":", argnames[i], sep = ""), envir = default.values,
                  inherits = FALSE))
            }
            names(default.arglist) <- argnames
            for (i in 1:length(argnames)) {
                templist <- list(optional.args, default.arglist[[i]])
                names(templist) <- c("arglist", argnames[i])
                optional.args <- do.call(".farg", templist)
            }
        }
        optional.args <- .select.args(optional.args, argnames)
        function.name <- get(measure, envir = function.names)
        x.values <- list()
        y.values <- list()
        for (i in 1:length(prediction.obj@predictions)) {
            argumentlist <- .sarg(optional.args, predictions = prediction.obj@predictions[[i]],
                labels = prediction.obj@labels[[i]], cutoffs = prediction.obj@cutoffs[[i]],
                fp = prediction.obj@fp[[i]], tp = prediction.obj@tp[[i]],
                fn = prediction.obj@fn[[i]], tn = prediction.obj@tn[[i]],
                n.pos = prediction.obj@n.pos[[i]], n.neg = prediction.obj@n.neg[[i]],
                n.pos.pred = prediction.obj@n.pos.pred[[i]],
                n.neg.pred = prediction.obj@n.neg.pred[[i]])
            ans <- do.call(function.name, argumentlist)
            if (!is.null(ans[[1]]))
                x.values <- c(x.values, list(ans[[1]]))
            y.values <- c(y.values, list(ans[[2]]))
        }
        if (!(length(x.values) == 0 || length(x.values) == length(y.values))) {
            stop("Consistency error.")
        }
        return(new("performance", x.name = get(x.measure, envir = long.unit.names),
            y.name = get(measure, envir = long.unit.names), alpha.name = "none",
            x.values = x.values, y.values = y.values, alpha.values = list()))
    }
    else {
        perf.obj.1 <- myperformance(prediction.obj, measure = x.measure,
            ...)
        perf.obj.2 <- myperformance(prediction.obj, measure = measure,
            ...)
        return(.combine.performance.objects(perf.obj.1, perf.obj.2))
    }
}


perf = myperformance(pred, "dice")
df = data.frame(x = perf@x.values[[1]], y = perf@y.values[[1]])
df = df[ is.finite(df$x) & is.finite(df$y),]
lo = loess(y ~ x, data=df)
lo.pred = predict(lo, df)
plot(perf)
lines(x = df$x, y = lo.pred, type="l")