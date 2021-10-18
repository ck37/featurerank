library(featurerank)

# TODO: switch to a less problematic demo dataset.
data(Boston, package = "MASS")

# Use "chas" as our outcome variable, which is binary.
x = subset(Boston, select = -chas)
y = Boston$chas
family = binomial()

# Create a custom RF ranker that only uses 10 trees, to speed up testing.
featrank_randomForest10 =
  function(...) featrank_randomForest(ntree = 10, ...)

(result = ensemble_rank(y, x, family,
                        fn_rank = c(featrank_cor, featrank_randomForest10, featrank_glm)))