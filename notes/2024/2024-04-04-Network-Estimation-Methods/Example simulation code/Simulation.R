# This code will give an example of how to perform simulations as discussed in the paper using a simpler 
# 6-node chain graph as true network model. The same code was used for the more advanced network structures
# Used in the paper.

# Required packages:
library("parSim")
library("qgraph")
library("bootnet")
library("mgm")
library("BGGM")
library("huge")
library("psychonetrics")
library("dplyr")
library("BDgraph")
library("GGMnonreg") # Install via github: devtools::install_github("")

# Generate a network model to simulate under:
truenetwork <- bootnet::genGGM(6)

# Run the simulation:
parSim(
  # Sim setup:
  sampleSize =  c(150, 300, 600, 1000, 2500, 5000), 
  nLevels = 4,
  data = c("normal", "skewed", "uniform ordered", "skewed ordered"), 
  missing = 0,
  sampleadjust = "pairwise_average",
 
  transformation = c("none", "rank", "npn","polychoric/categorical"),

  method = c(
    "EBICglasso",
    "ggmModSelect",
    "ggmModSelect_stepwise",
    "FIML_prune",
    "mgm_CV",
    "mgm_EBIC",
    "BGGM_explore",
    "BGGM_estimate",
    "GGM_bootstrap",
    "GGM_regression",
    "WLS_prune",
    "WLS_prune_stepup",
    "FIML_prune_modelsearch"
  ),
  
  export = "truenetwork",
  progressbar = FALSE,
  nCores = 30,
  reps = 100, 
  write = TRUE,
  name = "example_simulation",
  
  expression = {
    # Estimator function:
    source("dataGenerator.R")
    source("networkEstimator.R")
    
    # Helper:
    source("compareNetworks.R")
    
    # Is the data ordered?
    ordered <- data %in% c("uniform ordered", "skewed ordered")
    
    # Load network:
    graph <- truenetwork
    nNode <- nrow(graph)
    trueNet <- as.matrix(graph[1:nNode,1:nNode])
    rownames(trueNet) <- colnames(trueNet)
    groups <- rep(1, nNode) # No custers
    
    
    # If the number of nodes is > 40, don't do ggmModSelect (stepwise):
    if (nNode > 40 && method %in% c(
      "ggmModSelect_stepwise"
    )){
      stop("Not running stepwise estimators with > 40 nodes.")
    }
    # if (sampleSize > 1000 && grepl("BGGM",method)){
    #   stop("Not running BGGM with n > 1000")
    # }
    
    # Generate data:
    datas <- dataGenerator(trueNet, sampleSize, data, nLevels, missing)
    Data1 <- datas$data1
    Data2 <- datas$data2
    
    t0 <- Sys.time()
    
    # Estimate models:
    estNet <- networkEstimator(Data1,transformation=transformation,method=method,ordinal = ordered)
    estNet2 <- networkEstimator(Data2,transformation=transformation,method=method,ordinal = ordered)
    
    t1 <- Sys.time()
    
    if (length(unique(groups)) == 1){
      Result <- compareNetworks(trueNet, estNet, estNet2)        
    } else {
      Result <- compareNetworks(trueNet, estNet, estNet2, groups = groups)
    }
    
    Result$difftime <- as.numeric(difftime(t1,t0,units="secs"))
    
    Result
  }
)
