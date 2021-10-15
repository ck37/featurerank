## Variance threshold - rank according to variance
featrank_var = function(Y, X, family, ...)  {
  vars <- apply(X, 2, function(x) {
    var(x)
  })
  return(rank(-vars))
}
