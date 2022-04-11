
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
using a single algorithm. See also ([Neumann, Genze, and Heider
2017](#ref-neumann2017efs)) for a similar method.

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

Specify the feature ranking wrappers for the ensemble library.

``` r
library(featurerank)

# Modify RF feature ranker to use 100 trees (faster than default of 500).
featrank_randomForest100 =
  function(...) featrank_randomForest(ntree = 100L, ...)

# Specify the set of feature ranking algorithms.
ensemble_rank_custom =
  function(top_vars, ...)
    ensemble_rank(fn_rank = c(featrank_cor, featrank_randomForest100,
                              featrank_glm, featrank_glmnet),
                              #featrank_shap, # too verbose currently
                              #featrank_dbarts), # skip for speed
                  top_vars = top_vars,
                  ...)

# There are 13 total vars so try dropping 1 of them.
top12 = function(...) ensemble_rank_custom(top_vars = 12, ...)

# Try dropping worst 2 predictors.
top11 = function(...) ensemble_rank_custom(top_vars = 11, ...)

# Drop worst 3 predictors.
top10 = function(...) ensemble_rank_custom(top_vars = 10, ...)
```

### Use in SuperLearner

``` r
library(SuperLearner)

set.seed(1)
# Takes 93 seconds with 1 core.
sl = SuperLearner(y, x, family = binomial(),
                  # 10-fold cross-validation stratified on the outcome.
                  cvControl = list(V = 10L, stratifyCV = TRUE),
                  SL.library =
                    list("SL.glm", # Baseline estimator uses all predictors.
                         # Try three ensemble screening options, giving the
                         # screened variable list to logistic regression (SL.glm).
                         c("SL.glm", "top12", "top11", "top10")))

# Review timing.
sl$times$everything
```

    ##    user  system elapsed 
    ##  90.609   0.649  91.550

``` r
# We do achieve a modest AUC benefit.
ck37r::auc_table(sl, y = y)[, -6]
```

    ##        learner       auc         se  ci_lower  ci_upper
    ## 1   SL.glm_All 0.7426862 0.02930653 0.6852464 0.8001259
    ## 2 SL.glm_top12 0.7485151 0.02852544 0.6926062 0.8044239
    ## 3 SL.glm_top11 0.7535018 0.02760091 0.6994050 0.8075986
    ## 4 SL.glm_top10 0.7613032 0.02585664 0.7106251 0.8119813

``` r
# Which features were dropped (will show FALSE below)?
t(sl$whichScreen)
```

    ##          All top12 top11 top10
    ## crim    TRUE  TRUE  TRUE FALSE
    ## zn      TRUE FALSE FALSE FALSE
    ## indus   TRUE  TRUE  TRUE  TRUE
    ## nox     TRUE  TRUE  TRUE  TRUE
    ## rm      TRUE  TRUE  TRUE  TRUE
    ## age     TRUE  TRUE  TRUE  TRUE
    ## dis     TRUE  TRUE  TRUE  TRUE
    ## rad     TRUE  TRUE  TRUE  TRUE
    ## tax     TRUE  TRUE  TRUE  TRUE
    ## ptratio TRUE  TRUE  TRUE  TRUE
    ## black   TRUE  TRUE FALSE FALSE
    ## lstat   TRUE  TRUE  TRUE  TRUE
    ## medv    TRUE  TRUE  TRUE  TRUE

### Assess ranking stability

``` r
# Check if we see stability across multiple runs,
# especially for comparison to individual feature ranking algorithms.
# (See stability scores in Table 3 of paper.)
set.seed(2)

# Takes about 90 seconds using 1 core.
system.time({
results =
  do.call(rbind.data.frame,
          lapply(1:10,
                 function(i) top12(y, x, family,
                                   # Default replications is 3 - more replications increases stability.
                                   replications = 10,
                                   detailed_results = TRUE)$ranking))
})
```

    ##    user  system elapsed 
    ##  90.818   0.661  91.794

``` r
names(results) = names(x)
# Stability looks excellent.
results
```

    ##    crim zn indus nox rm age dis rad tax ptratio black lstat medv
    ## 1    11 13     8   5  9  10   6   3   7       4    12     2    1
    ## 2    11 13     7   4  9  10   8   3   6       5    12     2    1
    ## 3    11 13     7   4  9  10   6   3   8       5    12     2    1
    ## 4    11 13     7   4 10   9   6   3   8       5    12     2    1
    ## 5    11 13    10   4  7   9   6   3   8       5    12     2    1
    ## 6    11 13     8   4  9   7  10   3   6       5    12     2    1
    ## 7    11 13     9   5 10   7   6   3   8       4    12     2    1
    ## 8    11 13     9   4  6  10   7   3   8       5    12     2    1
    ## 9    11 13    10   4  6   8   7   3   9       5    12     2    1
    ## 10   11 13     9   4  6   8  10   3   7       5    12     2    1

``` r
# What if we treated each iteration as its own ranking and then aggregated?
agg_reciprocal_rank(t(results))
```

    ##    crim      zn   indus     nox      rm     age     dis     rad     tax ptratio 
    ##      11      13       9       4       8      10       6       3       7       5 
    ##   black   lstat    medv 
    ##      12       2       1

## References

<div id="refs" class="references csl-bib-body hanging-indent">

<div id="ref-effrosynidis2021evaluation" class="csl-entry">

Effrosynidis, Dimitrios, and Avi Arampatzis. 2021. “An Evaluation of
Feature Selection Methods for Environmental Data.” *Ecological
Informatics* 61: 101224.

</div>

<div id="ref-neumann2017efs" class="csl-entry">

Neumann, Ursula, Nikita Genze, and Dominik Heider. 2017. “EFS: An
Ensemble Feature Selection Tool Implemented as r-Package and
Web-Application.” *BioData Mining* 10 (1): 1–9.

</div>

<div id="ref-polley2021package" class="csl-entry">

Polley, Eric, Erin LeDell, Chris J. Kennedy, Sam Lendle, and Mark van
der Laan. 2021. “SuperLearner: Super Learner Prediction.” CRAN.
<https://CRAN.R-project.org/package=SuperLearner>.

</div>

</div>
