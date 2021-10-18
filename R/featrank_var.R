## Variance threshold - rank according to variance
featrank_var = function(Y, X, family, ties_method = "last", ...)  {
  vars <- apply(X, 2, function(x) {
    var(x)
  })
  return(rank(-vars, ties.method = ties.method))
}
