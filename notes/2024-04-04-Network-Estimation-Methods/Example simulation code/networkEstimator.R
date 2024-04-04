# Common estimation function for all networks:
networkEstimator <- function(
  data,
  transformation = c("none", "rank", "quantile","npn","polychoric/categorical"),
  method = c("EBICglasso", "pcor", "ggmModSelect", "ggmModSelect_stepwise", "FIML_prune","FIML_prune_stepup",
             "FIML_prune_modelsearch", "WLS_prune", "WLS_prune_stepup",
             "mgm_CV", "mgm_EBIC","huge","adalasso", "BGGM_explore", "BGGM_estimate","GGM_bootstrap","GGM_regression",
             "BDgraph"),
  variant,
  ordinal
){
  library("qgraph")
  library("bootnet")
  library("mgm")
  library("BGGM")
  library("GGMnonreg")
  library("huge")
  library("psychonetrics")
  library("dplyr")
  # library("parcor")
  library("BDgraph")
  sampleAdjust  <-  "pairwise_average"
  
  if (missing(ordinal)){
    ordinal <- all(na.omit(unique(unlist(data))) %%1 == 0)
  }

  
  if (missing(variant)){
    if (method %in% c("EBICglasso","BGGM_explore", "GGM_regression",
                      "BDgraph")){
      variant <- 1
    } else if (method %in% c("pcor", "FIML_prune","FIML_prune_stepup",
                             "FIML_prune_modelsearch", "WLS_prune", "WLS_prune_stepup",
                             "mgm_CV", "adalasso",  "GGM_bootstrap")){
      variant <- 2
    } else if (method %in% c("ggmModSelect", "ggmModSelect_stepwise")){
      variant <- 3
    } else {
      variant <- 1
    }
  }
  
  transformation <- match.arg(transformation)
  method <- match.arg(method)
  
  # Some should give an error:
  if (!ordinal & transformation == "polychoric/categorical"){
    stop("Cannot treat continuous data as (ordered) categorical")
  }
  if (method == "GGM_regression" && variant != 1){
    stop("'GGM_regression' only has one variant included at the moment.")
  }
  if (method == "BDgraph" && variant == 3){
    stop("'BDgraph' only has two variants")
  }
  
  # Variant:
  alpha <- switch(variant, 
                  `1` = 0.005,
                  `2` = 0.01,
                  `3` = 0.05)
  
  # BF_cut <- switch(variant, 
  #                 `1` = 30,
  #                 `2` = 10,
  #                 `3` = 3)
  
  EBICtuning <- switch(variant, 
                       `1` = 0.5,
                       `2` = 0.25,
                       `3` = 0)
  hugetype <- switch(variant,
                     `1` = "mb",
                     `2` = "ct",
                     `3` = "tiger")
  CVfolds <- switch(variant,
                     `1` = 20,
                     `2` = 10,
                     `3` = 5)
  BDalgorithm <- switch(variant,
                    `1` = "bdmcmc",
                    `2` = "rjmcmc")
  

  # Transform data:
  if (transformation == "rank"){
    data <- as.data.frame(scale(bootnet::rank_transformation(data)))
  }
  if (transformation == "quantile"){
    data <- bootnet::quantile_transformation(data)
  }
  if (transformation == "polychoric/categorical"){
    if (!method %in% c("EBICglasso", "pcor", "ggmModSelect","ggmModSelect_stepwise", "WLS_prune", "WLS_prune_stepup",
                       "mgm_CV", "mgm_EBIC","BGGM_explore","BGGM_estimate")){
      stop("Treating data as (ordered) categorical not supported for this method.")
    }
  }
  if (transformation == "npn"){
    if (any(is.na(data))){
      stop("'npn' transformation not supported for missing data")
    }
    data <- huge.npn(data)
  }
  
  # Check for psychonetrics:
  psychonetricscheck <- function(x){
    if (!psychonetrics:::sympd_cpp(x@information)) stop("Information matrix is not positive semi-definite.")
    return(x)
  }
  
  
  # Estimate model:
  if (method == "EBICglasso"){
    res <- estimateNetwork(data, default = "EBICglasso",
                           sampleSize = sampleAdjust,
                           tuning = EBICtuning,
                           corMethod = ifelse(transformation == "polychoric/categorical",
                                              "cor_auto",
                                              "cor"))
    
    estnet <- res$graph
  } else  if (method == "pcor"){
    res <- estimateNetwork(data, default = "pcor",
                           sampleSize = sampleAdjust,
                           alpha = alpha,
                           corMethod = ifelse(transformation == "polychoric/categorical",
                                              "cor_auto",
                                              "cor"))
    
    estnet <- res$graph
  } else if (method == "ggmModSelect"){
    res <- estimateNetwork(data, default = "ggmModSelect",
                           sampleSize = sampleAdjust, stepwise = FALSE,
                           tuning = EBICtuning,
                           corMethod = ifelse(transformation == "polychoric/categorical",
                                              "cor_auto",
                                              "cor"))
    
    estnet <- res$graph
  } else if (method == "ggmModSelect_stepwise"){
    res <- estimateNetwork(data, default = "ggmModSelect",
                           sampleSize = sampleAdjust, stepwise = TRUE,
                           tuning = EBICtuning,
                           corMethod = ifelse(transformation == "polychoric/categorical",
                                              "cor_auto",
                                              "cor"))
    
    estnet <- res$graph
  } else if (method == "FIML_prune"){
    
    mod <- ggm(data, estimator = "FIML", standardize = "z") %>% prune(alpha = alpha, recursive = FALSE) %>% psychonetricscheck
    
    estnet <- getmatrix(mod, "omega")
    
  } else if (method == "FIML_prune_stepup"){

    mod <- ggm(data, estimator = "FIML", standardize = "z") %>% 
      prune(alpha = alpha, recursive = FALSE)  %>% psychonetricscheck %>% 
      stepup(alpha = alpha)
    
    estnet <- getmatrix(mod, "omega")
    
  } else if (method == "FIML_prune_modelsearch"){

    mod <- ggm(data, estimator = "FIML", standardize = "z") %>% 
      prune(alpha = alpha, recursive = FALSE)  %>% psychonetricscheck  %>% 
      modelsearch(prunealpha = alpha, addalpha = alpha)
    
    estnet <- getmatrix(mod, "omega")
    
  } else if (method == "WLS_prune"){
    
    mod <- ggm(data, estimator = "WLS", ordered = (ordinal && transformation == "polychoric/categorical")) %>%
      prune(alpha = alpha, recursive = FALSE)  %>% psychonetricscheck
    
    estnet <- getmatrix(mod, "omega")
    
  } else if (method == "WLS_prune_stepup"){
    mod <- ggm(data, estimator = "WLS", ordered = (ordinal && transformation == "polychoric/categorical")) %>%
      prune(alpha = alpha, recursive = FALSE)  %>% psychonetricscheck %>% 
      stepup(alpha = alpha, criterion = "none")
    
    estnet <- getmatrix(mod, "omega")
    
  } else if (method %in% c("mgm_CV","mgm_EBIC")){
    cat <- (ordinal && transformation == "polychoric/categorical")
  
    type <- rep(ifelse(cat,"c","g"),ncol(data))
    level <- rep(ifelse(cat,length(unique(na.omit(c(as.matrix(data))))),1),ncol(data))

    res <- mgm(na.omit(data), type = type, level = level, lambdaFolds = CVfolds,
               lambdaSel = gsub("mgm_","",method), lambdaGam = EBICtuning)
    if (cat){
      estnet <- res$pairwise$wadj
      warning("Signs are not included in the network")
    } else {
      estnet <- ifelse(is.na(res$pairwise$signs),1,res$pairwise$signs) * res$pairwise$wadj      
    }
  } else if (method == "huge"){
    res <- huge(data, method = hugetype)
    estnet <- as.matrix(huge.select(res)$refit)
    warning("Weights are not included in the network")
    
  } else if(method == "adalasso"){
    res <- adalasso.net(data, k = CVfolds)
    estnet <- res$pcor.adalasso
  } else if(method == "BGGM_explore"){
      exp <- BGGM::explore(data, type = ifelse(ordinal && transformation == "polychoric/categorical","ordinal","continuous"))
      sel <- BGGM::select(exp)
      estnet <- sel$pcor_mat_zero
  } else if(method == "BGGM_estimate"){
    exp <- BGGM::estimate(data, type = ifelse(ordinal && transformation == "polychoric/categorical","ordinal","continuous"))
    sel <- BGGM::select(exp)
    estnet <- sel$pcor_adj
  } else if (method == "GGM_bootstrap"){
    res <- GGM_bootstrap(data, alpha = alpha)
    estnet <- res$pcor_selected
  } else if (method == "GGM_regression"){
    
    res <- GGM_regression(data)
    estnet <- res$pcor_selected
  } else if (method == "BDgraph"){
    res <- bdgraph(data, algorithm = BDalgorithm, iter = 1000)
    K <- summary(res)$K_hat
    sel <- summary(res)$selected_g
    diag(sel) <- 1
    K <- K * sel
    estnet <- as.matrix(qgraph::wi2net(K))
  }

  return(as.matrix(estnet))
}
  
