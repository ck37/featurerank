
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Feature Rank: ensemble feature ranking for variable selection

Ensemble feature ranking for variable selection in SuperLearner
ensembles ([Polley et al. 2021](#ref-polley2021package)), based on
Effrosynidis and Arampatzis ([2021](#ref-effrosynidis2021evaluation)).
Multiple algorithms estimate a ranking of the strength of the
relationship between predictors and the outcome in the training set, and
these rankings are combined into a single ranking via an aggregation
method (reciprocal ranking currently). The final ranking can then be cut
at a certain number of variables (e.g. top 10 predictors, top 70%, etc.)
to create one or more feature selection wrappers for SuperLearner. The
result should generally be more robust and stable than feature selection
using a single algorithm.

## Install

``` r
# install.packages("remotes")
remotes::install_github("ck37/featurerank")
```

## Algorithms

Currently implemented algorithms are:

-   Feature ranking: correlation, glm, glmnet, random forest, bart,
    xgboost + shap, variance
-   Rank aggregation: reciprocal ranking

## Example

A minimal example to demonstrate how the package can be used.

### Prepare dataset

``` r
# TODO: switch to a less problematic demo dataset.
data(Boston, package = "MASS")

# Use "chas" as our outcome variable, which is binary.
x = subset(Boston, select = -chas)
y = Boston$chas
family = binomial()
```

### Create feature ranking library

Specify the feature ranking wrapper for the ensemble library.

``` r
library(featurerank)

# Create a custom ensemble rank feature selector, using the RF learner.
# Also customizing top_vars to drop a single feature.

featrank_randomForest100 =
  function(...) featrank_randomForest(ntree = 100L, ...)

# Custom library of feature ranking algorithms.
ensemble_rank_custom =
  function(top_vars, ...)
    ensemble_rank(fn_rank = c(featrank_cor, featrank_randomForest100,
                              featrank_glm, featrank_glmnet,
                              #featrank_shap, # too verbose currently
                              featrank_dbarts),
                  top_vars = top_vars,
                  ...)

# There are 13 total vars so try dropping 1 of them.
top12 = function(...) ensemble_rank_custom(top_vars = 12, ...)

# Try dropping worst 2 predictors.
top11 = function(...) ensemble_rank_custom(top_vars = 11, ...)
```

### Use in SuperLearner

``` r
library(SuperLearner)

# Seems to work correctly.
set.seed(1)
sl = SuperLearner(y, x, family = binomial(),
                  cvControl = list(V = 10L, stratifyCV = TRUE),
                  SL.library =
                    list("SL.mean",
                         # Try two ensemble screening options vs. all predictors.
                         c("SL.glm", "top12", "top11", "All")))
```

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

``` r
# We do achieve an AUC benefit.
ck37r::auc_table(sl, y = y)[, -6]
```

    ##        learner       auc         se  ci_lower  ci_upper
    ## 1  SL.mean_All 0.5000000 0.08753770 0.3284293 0.6715707
    ## 4   SL.glm_All 0.7426862 0.02930653 0.6852464 0.8001259
    ## 2 SL.glm_top12 0.7485151 0.02852544 0.6926062 0.8044239
    ## 3 SL.glm_top11 0.7758200 0.02529943 0.7262341 0.8254060

``` r
# Which features were dropped (will show FALSE below)?
t(sl$whichScreen)
```

    ##          All top12 top11
    ## crim    TRUE  TRUE  TRUE
    ## zn      TRUE FALSE FALSE
    ## indus   TRUE  TRUE  TRUE
    ## nox     TRUE  TRUE  TRUE
    ## rm      TRUE  TRUE  TRUE
    ## age     TRUE  TRUE  TRUE
    ## dis     TRUE  TRUE  TRUE
    ## rad     TRUE  TRUE  TRUE
    ## tax     TRUE  TRUE  TRUE
    ## ptratio TRUE  TRUE  TRUE
    ## black   TRUE  TRUE FALSE
    ## lstat   TRUE  TRUE  TRUE
    ## medv    TRUE  TRUE  TRUE

### Assess ranking stability

``` r
# Check if we see stability across multiple runs,
# especially for comparison to individual feature ranking algorithms.
# (See stability scores in Table 3 of paper.)
set.seed(2)
results =
  do.call(rbind.data.frame,
          lapply(1:10,
                 function(i) top12(y, x, family,
                                   return_ranking = TRUE)))
names(results) = names(x)
# Stability looks excellent.
results
```

    ##    crim zn indus nox rm age dis rad tax ptratio black lstat medv
    ## 1     7 13     3   2  9  11   8   4  10       6    12     5    1
    ## 2     7 13     5   2  8  11  10   3   9       6    12     4    1
    ## 3     6 13     4   2 10  11   7   3   9       5    12     8    1
    ## 4     7 13     6   3  4  11   8   5   9       2    12    10    1
    ## 5     7 13     6   2  8  11   9   3  10       4    12     5    1
    ## 6     6 13     9   2  7  11  10   3   8       5    12     4    1
    ## 7     6 13     7   1  9  11  10   3   8       5    12     4    2
    ## 8     6 13     8   2 11  10   7   3   9       5    12     4    1
    ## 9     8 13     6   2  7  11  10   3   9       5    12     4    1
    ## 10    6 13     7   2  9  11  10   3   8       5    12     4    1

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-effrosynidis2021evaluation" class="csl-entry">

Effrosynidis, Dimitrios, and Avi Arampatzis. 2021. “An Evaluation of
Feature Selection Methods for Environmental Data.” *Ecological
Informatics* 61: 101224.

</div>

<div id="ref-polley2021package" class="csl-entry">

Polley, Eric, Erin LeDell, Chris J. Kennedy, Sam Lendle, and Mark van
der Laan. 2021. “SuperLearner: Super Learner Prediction.” CRAN.
<https://CRAN.R-project.org/package=SuperLearner>.

</div>

</div>
