# Package installation ======================================================================
needed_packages = c("ggplot2", "cmdstanr", "HDInterval", "bayesplot", "loo", "here")
for(i in 1:length(needed_packages)){
  haspackage = require(needed_packages[i], character.only = TRUE)
  if(haspackage == FALSE){
    install.packages(needed_packages[i])
  }
  library(needed_packages[i], character.only = TRUE)
}
# set number of cores to 4 for this analysis
options(mc.cores = 4)

# Import data ===============================================================================
current_dir <- "posts/2024-01-12-syllabus-adv-multivariate-esrm-6553/Lecture11/Code"
save_dir <- "/Users/jihong/Library/CloudStorage/OneDrive-Personal/2024 Spring/ESRM6553 - Advanced Multivariate Modeling/Lecture11"
conspiracyData = read.csv(here("posts/2024-01-12-syllabus-adv-multivariate-esrm-6553/Lecture07/Code", "conspiracies.csv"))
conspiracyItems = conspiracyData[,1:10]

# Build a Q-Matrix ===========================================================================

Qmatrix = matrix(data = 0, nrow = ncol(conspiracyItems), ncol = 2)
colnames(Qmatrix) = c("Gov", "NonGov")
rownames(Qmatrix) = paste0("item", 1:ncol(conspiracyItems))
Qmatrix[1,2] = 1
Qmatrix[2,1] = 1
Qmatrix[3,2] = 1
Qmatrix[4,2] = 1
Qmatrix[5,1] = 1
Qmatrix[6,2] = 1
Qmatrix[7,1] = 1
Qmatrix[8,1] = 1
Qmatrix[9,1] = 1
Qmatrix[10,2] = 1

Qmatrix

# Ordered Logit (Multinomial/categorical distribution) Model Syntax =======================
modelOrderedLogit_stan = cmdstan_model(here(current_dir, "Lecture11.stan"))

# Data needs: successive integers from 1 to highest number (recode if not consistent)
maxCategory = 5

# data dimensions
nObs = nrow(conspiracyItems)
nItems = ncol(conspiracyItems)

# item threshold hyperparameters
thrMeanHyperParameter = 0
thrMeanVecHP = rep(thrMeanHyperParameter, maxCategory-1)
thrMeanMatrix = NULL
for (item in 1:nItems){
  thrMeanMatrix = rbind(thrMeanMatrix, thrMeanVecHP)
}

thrVarianceHyperParameter = 10
thrCovarianceMatrixHP = diag(x = thrVarianceHyperParameter, nrow = maxCategory-1)
thrCovArray = array(data = 0, dim = c(nItems, maxCategory-1, maxCategory-1))
for (item in 1:nItems){
  thrCovArray[item, , ] = diag(x = thrVarianceHyperParameter, nrow = maxCategory-1)
}

# item discrimination/factor loading hyperparameters
lambdaMeanHyperParameter = 0
lambdaMeanVecHP = rep(lambdaMeanHyperParameter, nItems)

lambdaVarianceHyperParameter = 10
lambdaCovarianceMatrixHP = diag(x = lambdaVarianceHyperParameter, nrow = nItems)

thetaMean = rep(0, 2)

modelOrderedLogit_data = list(
  nObs = nObs,
  nItems = nItems,
  maxCategory = maxCategory,
  Y = t(conspiracyItems), 
  nFactors = ncol(Qmatrix),
  Qmatrix = Qmatrix,
  meanThr = thrMeanMatrix,
  covThr = thrCovArray,
  meanLambda = lambdaMeanVecHP,
  covLambda = lambdaCovarianceMatrixHP,
  meanTheta = thetaMean
)


modelOrderedLogit_samples = modelOrderedLogit_stan$sample(
  data = modelOrderedLogit_data,
  seed = 191120221,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 2000,
  iter_sampling = 2000,
  init = function() list(lambda=rnorm(nItems, mean=5, sd=1))
)
modelOrderedLogit_samples$save_object(here(save_dir, "modelOrderedLogit_samples.RDS"))

# checking convergence
max(modelOrderedLogit_samples$summary(.cores = 6)$rhat, na.rm = TRUE)

# item parameter results
print(modelOrderedLogit_samples$summary(variables = c("lambda", "mu", "thetaCorr"), .cores = 6) ,n=Inf)

# correlation posterior distribution
mcmc_trace(modelOrderedLogit_samples$draws(variables = "thetaCorr[1,2]"))
mcmc_dens(modelOrderedLogit_samples$draws(variables = "thetaCorr[1,2]"))

# example theta posterior distributions

thetas = modelOrderedLogit_samples$summary(variables = c("theta"))
mcmc_pairs(x = modelOrderedLogit_samples$draws(variables = c("theta[1,1]", "theta[1,2]")))

plot(x = thetas$mean[1:177], y = thetas$mean[178:354], xlab="Theta 1", ylab="Theta 2")




# Model 2: Graded Response IRT with missing values ------------------------
# Build a Q-Matrix ===========================================================================
# here, we are back to a one-factor Q-matrix
Qmatrix = matrix(data = 1, nrow = ncol(conspiracyItems), ncol = 1)

Qmatrix

modelOrderedLogitNoMiss_stan = cmdstan_model(here(current_dir, "Lecture11withMissingValues.stan"))

# Build list of observations for each variable along with count of each: =====================
observed = matrix(data = -1, nrow = nrow(conspiracyItems), ncol = ncol(conspiracyItems))
nObserved = NULL
for (variable in 1:ncol(conspiracyItems)){
  nObserved = c(nObserved, length(which(!is.na(conspiracyItems[, variable]))))
  observed[1:nObserved[variable], variable] = which(!is.na(conspiracyItems[, variable]))
}

# Fill in NA values in Y
Y = conspiracyItems
for (variable in 1:ncol(conspiracyItems)){
  Y[which(is.na(Y[,variable])),variable] = -1
}

# Data needs: successive integers from 1 to highest number (recode if not consistent)
maxCategory = 5

# data dimensions
nObs = nrow(conspiracyItems)
nItems = ncol(conspiracyItems)

# item threshold hyperparameters
thrMeanHyperParameter = 0
thrMeanVecHP = rep(thrMeanHyperParameter, maxCategory-1)
thrMeanMatrix = NULL
for (item in 1:nItems){
  thrMeanMatrix = rbind(thrMeanMatrix, thrMeanVecHP)
}

thrVarianceHyperParameter = 10
thrCovarianceMatrixHP = diag(x = thrVarianceHyperParameter, nrow = maxCategory-1)
thrCovArray = array(data = 0, dim = c(nItems, maxCategory-1, maxCategory-1))
for (item in 1:nItems){
  thrCovArray[item, , ] = diag(x = thrVarianceHyperParameter, nrow = maxCategory-1)
}

# item discrimination/factor loading hyperparameters
lambdaMeanHyperParameter = 0
lambdaMeanVecHP = rep(lambdaMeanHyperParameter, nItems)

lambdaVarianceHyperParameter = 10
lambdaCovarianceMatrixHP = diag(x = lambdaVarianceHyperParameter, nrow = nItems)

thetaMean = rep(0, ncol(Qmatrix))

modelOrderedLogitNoMiss_data = list(
  nObs = nObs,
  nItems = nItems,
  maxCategory = maxCategory,
  nObserved = nObserved,
  observed = t(observed),
  Y = t(Y), 
  nFactors = ncol(Qmatrix),
  Qmatrix = Qmatrix,
  meanThr = thrMeanMatrix,
  covThr = thrCovArray,
  meanLambda = lambdaMeanVecHP,
  covLambda = lambdaCovarianceMatrixHP,
  meanTheta = thetaMean
)


modelOrderedLogitNoMiss_samples = modelOrderedLogitNoMiss_stan$sample(
  data = modelOrderedLogitNoMiss_data,
  seed = 191120221,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 2000,
  iter_sampling = 2000,
  init = function() list(lambda=rnorm(nItems, mean=5, sd=1))
)
modelOrderedLogitNoMiss_samples$save_object(here(save_dir, "modelOrderedLogitNoMiss_samples.RDS"))

# checking convergence
max(modelOrderedLogitNoMiss_samples$summary()$rhat, na.rm = TRUE)

# item parameter results
print(modelOrderedLogitNoMiss_samples$summary(variables = c("lambda", "mu")) ,n=Inf)

