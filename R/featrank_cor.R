# Edited from SuperLearner::screen.corRank()
#' @export
featrank_cor =
  function(Y, X, family, obsWeights = NULL, id = NULL,
           ties_method = "last",
           # Not used
           method = "pearson",
           ...) {
    SuperLearner:::.SL.require("weights")
    listp <- apply(X, 2, function(x, Y, method) {
        ifelse(var(x) <= 0, 1,
               weights::wtd.cor(x, Y, weight = obsWeights)[1, "p.value"])
    }, Y = Y, method = method)
    return(rank(listp, ties.method = ties_method))
}
