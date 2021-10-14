featrank_glm <- function(Y, X, family, obsWeights = NULL, ...) {
  
  # X must be a dataframe, not a matrix.
  if (is.matrix(X)) {
    X = as.data.frame(X)
  }
  
  fit.glm <- glm(Y ~ ., data = X, family = family, weights = obsWeights)
  
  # Extract p-values.
  p_vals = summary(reg)$coefficients[-1, 4]
  return(rank(p_vals))
}