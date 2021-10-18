# Edited from SuperLearner::screen.corRank()
featrank_cor = function(Y, X, family, obsWeights = NULL, ties_method = "last", method = "pearson", ...)  {
    listp <- apply(X, 2, function(x, Y, method) {
        ifelse(var(x) <= 0, 1, cor.test(x, y = Y, method = method)$p.value)
    }, Y = Y, method = method)
    return(rank(listp, ties.method = ties_method))
}
