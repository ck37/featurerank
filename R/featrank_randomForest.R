#' @export
# Edited from screen.randomForest
featrank_randomForest =  function (Y, X, family, obsWeights = NULL, ties_method = "last", ntree = 1000, mtry = ifelse(family$family == 
    "gaussian", floor(sqrt(ncol(X))), max(floor(ncol(X)/3), 1)), 
    nodesize = ifelse(family$family == "gaussian", 5, 1), maxnodes = NULL, 
    ...)  {
    SuperLearner:::.SL.require("randomForest")
    if (family$family == "gaussian") {
        rank.rf.fit <- randomForest::randomForest(Y ~ ., data = X, 
            ntree = ntree, mtry = mtry, nodesize = nodesize, 
            keep.forest = FALSE, maxnodes = maxnodes)
    }
    if (family$family == "binomial") {
        rank.rf.fit <- randomForest::randomForest(as.factor(Y) ~ 
            ., data = X, ntree = ntree, mtry = mtry, nodesize = nodesize, 
            keep.forest = FALSE, maxnodes = maxnodes)
    }
    return(rank(-rank.rf.fit$importance, ties.method = ties_method))
}