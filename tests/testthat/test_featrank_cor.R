# TODO: switch to a less problematic demo dataset.
data(Boston, package = "MASS")

# Use "chas" as our outcome variable, which is binary.
x = subset(Boston, select = -chas)
y = Boston$chas
family = binomial()

# Univariate correlation 
(res1 = featrank_cor(y, x, family))

# rad does have the high p-value and medv has the lowest.
sapply(x, function(x) {
        cor.test(x, y = y, method = "pearson")$p.value
})
