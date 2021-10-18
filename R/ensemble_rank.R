#' @export
ensemble_rank =
  function(Y, X, family,
           obsWeights = NULL,
           # Feature ranking algorithms.
           fn_rank = c(featrank_cor, featrank_randomForest, featrank_glm),
           # Rank aggregation algorithm.
           fn_agg = agg_reciprocal_rank,
           # How many variables we want to select. Top 50% by default.
           top_vars = ceiling(ncol(X) / 2),
           ties_method = getOption("featrank.ties.default", "last"),
           # Set as TRUE for debugging purposes
           return_ranking = FALSE,
           # Not used.
           ...)  {
    
    # Run each feature ranking algorithm.
    rank_df = do.call(cbind.data.frame,
                      lapply(fn_rank, function(fn) fn(Y, X, family,
                                                      obsWeights = obsWeights,
                                                      ties_method = ties_method)))
    
    # Calculate the aggregate ranking.
    ranking = fn_agg(rank_df, ties_method)
    
    if (return_ranking) {
      return(ranking)
    }
    
    # Apply the ranking to select the top X variables.
    whichVariable <- (ranking <= top_vars)
    return(whichVariable)
  }
