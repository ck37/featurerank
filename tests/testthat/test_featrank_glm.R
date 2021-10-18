# TODO: switch to a less problematic demo dataset.
data(Boston, package = "MASS")

# Use "chas" as our outcome variable, which is binary.
x = subset(Boston, select = -chas)
y = Boston$chas
family = binomial()

(res3 = featrank_glm(y, x, family))

# Compare to glm() manual results.
reg = glm(y ~ ., data = x, family = binomial())
summary(reg)