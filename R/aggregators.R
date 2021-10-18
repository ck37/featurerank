#' @export
agg_reciprocal_rank = function(rank_df,
                               ties_method = "last") {
  # For each feature, sum the inverse of its ranks, then invert the sum.
  ranks = apply(rank_df, MARGIN = 1, function(row) {
     1 / sum(row^-1)
  })
  return(rank(ranks, ties.method = ties_method))
}
