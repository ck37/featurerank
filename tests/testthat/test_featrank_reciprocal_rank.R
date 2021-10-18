# TODO: switch to a less problematic demo dataset.
data(Boston, package = "MASS")

# Use "chas" as our outcome variable, which is binary.
x = subset(Boston, select = -chas)
y = Boston$chas
family = binomial()


(res1 = featrank_cor(y, x, family))
(res2 = featrank_randomForest(y, x, family, ntree = 10))
(res3 = featrank_glm(y, x, family))

# Create a dataframe containing all rankings.
# Interestingly "rad" and "tax" have such divergent results for glm.
(rank_df = data.frame(cor = res1, rf = res2, glm = res3))

# Give it a ranking of multiple algorithms, and it will return the overall ranking.
agg_reciprocal_rank(rank_df)