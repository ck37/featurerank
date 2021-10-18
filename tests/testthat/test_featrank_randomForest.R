# TODO: switch to a less problematic demo dataset.
data(Boston, package = "MASS")

# Use "chas" as our outcome variable, which is binary.
x = subset(Boston, select = -chas)
y = Boston$chas
family = binomial()

# random forest
# These aren't named currently.
(res2 = featrank_randomForest(y, x, family, ntree = 10))