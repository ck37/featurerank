
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Feature Rank: ensemble feature ranking for variable selection

An implementation of ensemble feature ranking for variable selection in
SuperLearner ensembles, based on Effrosynidis and Arampatzis
([2021](#ref-effrosynidis2021evaluation)).

## Install

``` r
# install.packages("remotes")
remotes::install_github("ck37/featurerank")
```

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

ensemble_rank_custom =
  function(...) ensemble_rank(fn_rank = c(featrank_cor,
                                          featrank_randomForest100,
                                          featrank_glm),
                              # There are 13 total vars so try dropping 1 of them.
                              top_vars = 12,
                              ...)
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
                         # Try two screening options: ensemble_rank_custom or All.
                         c("SL.glm", "ensemble_rank_custom", "All")))
```

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

    ## Warning: glm.fit: fitted probabilities numerically 0 or 1 occurred

``` r
# We do achieve a small AUC benefit.
ck37r::auc_table(sl, y = y)[, -6]
```

    ##                       learner       auc         se  ci_lower  ci_upper
    ## 1                 SL.mean_All 0.5000000 0.08753770 0.3284293 0.6715707
    ## 3                  SL.glm_All 0.7426862 0.02930653 0.6852464 0.8001259
    ## 2 SL.glm_ensemble_rank_custom 0.7495789 0.02874162 0.6932464 0.8059114

``` r
# Which feature was dropped in the final SL?
names(x)[!sl$whichScreen["ensemble_rank_custom", ]]
```

    ## [1] "zn"

``` r
# Full results:
t(sl$whichScreen)
```

    ##          All ensemble_rank_custom
    ## crim    TRUE                 TRUE
    ## zn      TRUE                FALSE
    ## indus   TRUE                 TRUE
    ## nox     TRUE                 TRUE
    ## rm      TRUE                 TRUE
    ## age     TRUE                 TRUE
    ## dis     TRUE                 TRUE
    ## rad     TRUE                 TRUE
    ## tax     TRUE                 TRUE
    ## ptratio TRUE                 TRUE
    ## black   TRUE                 TRUE
    ## lstat   TRUE                 TRUE
    ## medv    TRUE                 TRUE

### Assess ranking stability

``` r
# Check if we see stability across multiple runs,
# especially for comparison to individual feature ranking algorithms.
# (See stability scores in Table 3 of paper.)
set.seed(2)
results =
  do.call(rbind.data.frame,
          lapply(1:10,
                 function(i) ensemble_rank_custom(y, x, family,
                                                  return_ranking = TRUE)))
names(results) = names(x)
# Stability looks excellent.
results
```

    ##    crim zn indus nox rm age dis rad tax ptratio black lstat medv
    ## 1     9 13     8  10  6  11   7   3   5       4    12     2    1
    ## 2    10 13     9   4  8  11   7   3   6       5    12     2    1
    ## 3     8 13     7  10  6  11   9   3   5       4    12     2    1
    ## 4    10 13     8   7  4  11   9   3   6       5    12     2    1
    ## 5     9 13     8  10  6  11   7   3   5       4    12     2    1
    ## 6    10 13     9   8  6  11   7   3   5       4    12     2    1
    ## 7    11 13     8   9  6  10   7   3   5       4    12     2    1
    ## 8    10 13     8   9  7  11   5   3   6       4    12     2    1
    ## 9    10 13     8  11  6   9   7   3   5       4    12     2    1
    ## 10   10 13     8   9  6  11   7   3   5       4    12     2    1

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-effrosynidis2021evaluation" class="csl-entry">

Effrosynidis, Dimitrios, and Avi Arampatzis. 2021. “An Evaluation of
Feature Selection Methods for Environmental Data.” *Ecological
Informatics* 61: 101224.

</div>

</div>
