# Code modified from https://github.com/saraemoore/SLScreenExtra/blob/master/R/rf.R#L119-L228
#' Screen features via a fast implementation of Random Forest
#'
#' Speed up \code{\link[SuperLearner]{screen.randomForest}} or
#' \code{\link{screen.randomForest.imp}}. Uses the
#' \code{\link[FSelector]{cutoff}} selectors.
#' @inheritParams screen.randomForest.imp
#' @inherit screen.randomForest.imp return
#' @param importanceType Importance type. \code{"permutation"} (default) indicates
#' mean decrease in accuracy (for \code{binomial()} family) or percent increase
#' in mean squared error (for \code{gaussian()} family) when comparing
#' predictions using the original variable versus a permuted version of the
#' variable (column of \code{X}). \code{"impurity"} indicates increase in
#' node purity achieved by splitting on that column of \code{X} (for
#' \code{binomial()} family, measured by Gini index; for \code{gaussian()},
#' measured by variance of the responses). See
#' \code{\link[ranger]{ranger}} for more details.
#' @param scalePermutationImportance Scale permutation importance by standard
#' error. Ignored if \code{importanceType = "impurity"}. See
#' \code{\link[ranger]{ranger}} for more details.
#' @param probabilityTrees Logical. If family is \code{binomial()} and
#' \code{probabilityTrees} is FALSE (the default), classification trees are
#' grown. If family is \code{binomial()} and
#' \code{probabilityTrees} is TRUE (the default), probability trees are
#' grown (Malley et al., 2012). Ignored if family is \code{gaussian()}, for
#' which regression trees are always grown. See \code{\link[ranger]{ranger}}
#' for more details.
#' @param numThreads Number of threads. Default: 1.
#' @importFrom ranger ranger
#' @importFrom methods is
#' @importFrom FSelector cutoff.biggest.diff cutoff.k cutoff.k.percent
#' @references \url{http://dx.doi.org/10.18637/jss.v077.i01}
#' \url{http://dx.doi.org/10.1023/A:1010933404324}
#' \url{http://dx.doi.org/10.3414/ME00-01-0052}
#' @export
featrank_ranger =
  function(Y, X, family, obsWeights = NULL,
           ties_method = "last",
           nTree = 1000,
           mTry = ifelse(family$family == "gaussian", floor(sqrt(ncol(X))), max(floor(ncol(X)/3), 1)),
           nodeSize = ifelse(family$family == "gaussian", 5, 1),
           importanceType = c("permutation", "impurity"),
           scalePermutationImportance = TRUE,
           probabilityTrees = FALSE,
           numThreads = 1,
           verbose = FALSE,
           ...) {
  
  importanceType <- match.arg(importanceType)
  selector <- match.arg(selector)
  if(!is(family, "family")) {
    stop("screen.ranger(): please supply a 'family' of gaussian() or binomial().")
  }
  
  df <- NULL
  if (family$family == "gaussian") {
    df <- data.frame(X, Y = Y)
    probability <- FALSE
  } else if (family$family == "binomial") {
    df <- data.frame(X, Y = as.factor(Y))
  } else {
    stop("screen.ranger(): family '", family$family, "' not supported.")
  }
  y_name <- colnames(df)[ncol(df)]
  
  rf_fit <- ranger(data = df, dependent.variable.name = y_name,
                   num.trees = nTree, mtry = mTry,
                   importance = importanceType, probability = probabilityTrees,
                   write.forest = FALSE, min.node.size = nodeSize,
                   scale.permutation.importance = scalePermutationImportance,
                   num.threads = numThreads, verbose = verbose)
  
  filter_res = as.data.frame(rf_fit$variable.importance)
  
  # TODO: return rank
}