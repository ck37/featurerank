featrank_lasso_upd <- function(Y, X, family,obsWeights = rep(1,length(Y)), ranking.type = 1, run.type = "nocv", ties = "last", alpha = 1, nlambda = 100,  ...) {
  
  if(!is.matrix(X)) {
    X <- model.matrix(~ -1 + ., X)
  }
  
  if (run.type == "cv") {
    fitCV  <- cv.glmnet(x = X, y = Y, weights = obsWeights, lambda = NULL, type.measure = 'deviance', family = family, alpha = alpha, nlambda = nlambda)
    fit <- fitCV$glmnet.fit
  }
  else {
    fit  <- glmnet(x = X, y = Y, weights = obsWeights, lambda = NULL, type.measure = 'deviance', family = family, alpha = alpha, nlambda = nlambda)
  }
  
  coef.matrix <- abs(fit$beta) > 0
  
  if (ranking.type == 1) {
    
  col.ones <- rep(1,ncol(fit$beta))
  
  coef.sum <- coef.matrix%*%col.ones
  
  out.rank <- rank(-coef.sum,ties.method = ties)
  }
  
  else {
  
  col.count <- c(ncol(fit$beta):1)
  
  diag.count <- diag(col.count,ncol(fit$beta),ncol(fit$beta))
  
  pos.coef <- coef.matrix%*%diag.count
  
  max.col <- matrixStats::rowMaxs(as.matrix(pos.coef))
  out.rank <- rank(-max.col,ties.method = ties)
  }
  
  return(out.rank)
}
