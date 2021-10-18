#' @export
featrank_dbarts =
  function(Y, X, family, obsWeights,
           ties_method = "last",
           ntree = 50,
           verbose = FALSE,
           ..)  {
  SuperLearner:::.SL.require("dbarts")
  SuperLearner:::.SL.require("embarcadero")
  
  model <- dbarts::bart(x.train = X,
                        y.train = Y,
                        x.test = X,
                        ntree = ntree,
                        weights = obsWeights,
                        keeptrees = TRUE,
                        verbose = verbose)
  
  dbarts.var.imp <- embarcadero::varimp(model, plot = FALSE)
  
  return(rank(-rank(dbarts.var.imp$varimps)))
}
