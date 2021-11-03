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
           # Aggregate results from this many iterations of the algorithm.
           replications = 3L,
           # Set as TRUE for debugging purposes
           detailed_results = FALSE,
           # Not used.
           ...)  {
    
    runs = list() 
    for (iteration in seq(replications)) {
      # Run each feature ranking algorithm.
      rank_df = do.call(cbind.data.frame,
                        lapply(fn_rank, function(fn) fn(Y, X, family,
                                                        obsWeights = obsWeights,
                                                        ties_method = ties_method)))
      
      names(rank_df) = paste0("fn_", seq(length(fn_rank)))
      
      runs[[iteration]] =
        list(rank_df = rank_df,
            # Calculate the aggregate ranking.
            ranking = fn_agg(rank_df, ties_method))
    }
    
    if (replications == 1L) {
      ranking = runs[[1]]$ranking
    } else {
      # Extract each ranking iteration into a combined df.
      rank_df = do.call(cbind.data.frame, lapply(runs, function(run) run$ranking))
      ranking = fn_agg(rank_df, ties_method)
    }
    
    # Apply the ranking to select the top X variables.
    which_vars = ranking <= top_vars
    
    results = list(
      runs = runs,
      agg_rank_df = rank_df,
      which_vars = which_vars,
      ranking = ranking
    )
    
    if (detailed_results) {
      return(results)
    }
    
    return(which_vars)
  }
