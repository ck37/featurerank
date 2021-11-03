#' @export
featrank_glmnet =
  function(Y, X, family,
           obsWeights = rep(1,length(Y)),
           id = NULL,
           ranking_type = 1,
           run_type = "cv",
           ties = "last", alpha = 1, nlambda = 100,  ...) {
  SuperLearner:::.SL.require('glmnet')
  
  if (!is.matrix(X)) {
    X <- model.matrix(~ -1 + ., X)
  }
  
  if (run_type == "cv") {
    fitCV <- cv.glmnet(x = X, y = Y, weights = obsWeights,
                       lambda = NULL,
                        type.measure = 'deviance', family = family,
                        alpha = alpha, nlambda = nlambda)
    fit <- fitCV$glmnet.fit
  }
  else {
    fit <- glmnet(x = X, y = Y, weights = obsWeights,
                  lambda = NULL,
                  type.measure = 'deviance', family = family,
                  alpha = alpha, nlambda = nlambda)
  }
  
  coef.matrix <- abs(fit$beta) > 0
  
  if (ranking_type == 1) {
    col.ones <- rep(1,ncol(fit$beta))
    coef.sum <- coef.matrix %*% col.ones
    out.rank <- rank(-coef.sum, ties.method = ties)
  } else {
    col.count <- c(ncol(fit$beta):1)
    diag.count <- diag(col.count, ncol(fit$beta), ncol(fit$beta))
    pos.coef <- coef.matrix %*% diag.count
    max.col <- matrixStats::rowMaxs(as.matrix(pos.coef))
    out.rank <- rank(-max.col,ties.method = ties)
  }
  
  return(out.rank)
}
