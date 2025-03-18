library(tidyverse)
library(kableExtra)
library(here)
library(blavaan)
library(cmdstanr)

# Read in data ------------------------------------------------------------
root_dir <- "teaching/2024-01-12-syllabus-adv-multivariate-esrm-6553/Lecture07/Code"
current_dir <- "teaching/2024-01-12-syllabus-adv-multivariate-esrm-6553/Lecture09/Code"
save_dir <- "~/Library/CloudStorage/OneDrive-Personal/2024 Spring/ESRM6553 - Advanced Multivariate Modeling/Lecture09/"
dat <- read.csv(here(root_dir, 'conspiracies.csv'))
itemResp <- dat[,1:10]
colnames(itemResp) <- paste0('item', 1:10)
conspiracyItems = itemResp

conspiracyItemsDichtomous <- itemResp |> 
  mutate(across(everything(), \(x) ifelse(x <= 3, 0, 1)))


# Run the model -----------------------------------------------------------
modelIRT_2PL_SI_stan <- cmdstanr::cmdstan_model(here(current_dir, 'lecture09.stan'))
nObs = nrow(conspiracyItems)
nItems = ncol(conspiracyItems)

# item intercept hyperparameters
muMeanHyperParameter = 0
muMeanVecHP = rep(muMeanHyperParameter, nItems)

muVarianceHyperParameter = 1000
muCovarianceMatrixHP = diag(x = sqrt(muVarianceHyperParameter), nrow = nItems)

# item discrimination/factor loading hyperparameters
lambdaMeanHyperParameter = 0
lambdaMeanVecHP = rep(lambdaMeanHyperParameter, nItems)

lambdaVarianceHyperParameter = 1000
lambdaCovarianceMatrixHP = diag(x = sqrt(lambdaVarianceHyperParameter), nrow = nItems)

modelIRT_2PL_SI_data = list(
  nObs = nObs,
  nItems = nItems,
  Y = t(conspiracyItemsDichtomous), 
  meanMu = muMeanVecHP,
  covMu = muCovarianceMatrixHP,
  meanLambda = lambdaMeanVecHP,
  covLambda = lambdaCovarianceMatrixHP
)

modelIRT_2PL_SI_samples = modelIRT_2PL_SI_stan$sample(
  data = modelIRT_2PL_SI_data,
  seed = 02112022,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 5000,
  iter_sampling = 5000,
  init = function() list(lambda=rnorm(nItems, mean=5, sd=1))
)

summary(modelIRT_2PL_SI_samples$summary(.cores =4)['rhat'])
# modelIRT_2PL_SI_samples$save_object(here(save_dir, "modelIRT_2PL_SI_samples.RDS"))
modelIRT_2PL_SI_samples$summary(.cores =4)
modelIRT_2PL_SI_samples$diagnostic_summary()

### ICC plots  ----------------------------------------
thetas = seq(-5, 5, .1)
mu_PosteriorMean <- modelIRT_2PL_SI_samples$summary('mu', .cores =4)$mean
lambda_PosteriorMean <- modelIRT_2PL_SI_samples$summary('lambda', .cores =4)$mean
ICC_fun <- function(theta, mu, lambda) {
  exp(mu+lambda*theta)/(1+exp(mu+lambda*theta))
}
expected_scores = lapply(thetas, \(x) ICC_fun(theta = x, mu = mu_PosteriorMean, lambda = lambda_PosteriorMean))
expected_scores_ICC <- as.data.frame(Reduce(rbind, expected_scores))
colnames(expected_scores_ICC) <- paste0("Item", 1:10)
expected_scores_ICC$theta = thetas

expected_scores_ICC |> 
  pivot_longer(starts_with('Item')) |> 
  mutate(name = factor(name, levels = paste0("Item", 1:10))) |> 
  ggplot() +
  geom_path(aes(x = theta, y = value, col = name), linewidth = 1.3, alpha = .7) +
  theme_classic() +
  theme(text = element_text(size = 17))
ggsave(here(current_dir, "expected_scores_ICC.png"), width = 8, height = 6)


### ICC for item 5
# investigating item parameters ================================================
itemNumber = 5

labelMu = paste0("mu[", itemNumber, "]")
labelLambda = paste0("lambda[", itemNumber, "]")
itemParameters = modelIRT_2PL_SI_samples$draws(variables = c(labelMu, labelLambda), format = "draws_matrix")
itemSummary = modelIRT_2PL_SI_samples$summary(variables = c(labelMu, labelLambda))

# item plot
theta = seq(-3,3,.1) # for plotting analysis lines--x axis values

# drawing item characteristic curves for item
logit = as.numeric(itemParameters[1,labelMu]) + as.numeric(itemParameters[1,labelLambda])*theta
y = exp(logit)/(1+exp(logit))
plot(x = theta, y = y, type = "l", main = paste("Item", itemNumber, "ICC"), 
     ylim=c(0,1), xlab = expression(theta), ylab=paste("Item", itemNumber, "Predicted Value"))

for (draw in 2:nrow(itemParameters)){
  logit = as.numeric(itemParameters[draw,labelMu]) + as.numeric(itemParameters[draw,labelLambda])*theta
  y = exp(logit)/(1+exp(logit))
  lines(x = theta, y = y)
}

# drawing EAP line
logit = itemSummary$mean[which(itemSummary$variable==labelMu)] + 
  itemSummary$mean[which(itemSummary$variable==labelLambda)]*theta
y = exp(logit)/(1+exp(logit))
lines(x = theta, y = y, lwd = 5, lty=3, col=2)

# legend
legend(x = -3, y = 1, legend = c("Posterior Draw", "EAP"), col = c(1,2), lty = c(1,3), lwd=5)

### Investigating the item parameters  ----------------------------------------
library(bayesplot)
color_scheme_set('red')
mcmc_trace(modelIRT_2PL_SI_samples$draws('mu')) + theme_classic()
ggsave(here(current_dir, "traceplot_mu.png"), width = 10, height = 6)

mcmc_dens_chains(modelIRT_2PL_SI_samples$draws('mu')) +
  scale_x_continuous(limits = c(-7, -1)) +
  theme_classic()
ggsave(here(current_dir, "densityplot_mu.png"), width = 10, height = 6)

mcmc_trace(modelIRT_2PL_SI_samples$draws('lambda')) + theme_classic()
ggsave(here(current_dir, "traceplot_lambda.png"), width = 10, height = 6)

mcmc_dens_chains(modelIRT_2PL_SI_samples$draws('lambda')) +
  theme_classic()
ggsave(here(current_dir, "densityplot_lambda.png"), width = 10, height = 6)

### bivariate posterior distributions  ----------------------------------------
itemNum = 1
muLabel = paste0("mu[", itemNum, "]")
lambdaLabel = paste0("lambda[", itemNum, "]")
mcmc_pairs(modelIRT_2PL_SI_samples$draws(), pars = c(muLabel, lambdaLabel))
ggsave(here(current_dir, "bivariate_lambda1_mu1.png"), width = 10, height = 6)

# EAP Estimates of Latent Variables

hist(modelIRT_2PL_SI_samples$summary(variables = c("theta"))$mean, main="EAP Estimates of Theta", 
     xlab = expression(theta))

# Comparing Two Posterior Distributions
theta1 = "theta[1]"
theta2 = "theta[2]"
thetaSamples = modelIRT_2PL_SI_samples$draws(variables = c(theta1, theta2), format = "draws_matrix")
thetaVec = rbind(thetaSamples[,1], thetaSamples[,2])
thetaDF = data.frame(observation = c(rep(theta1,nrow(thetaSamples)), rep(theta2, nrow(thetaSamples))), 
                     sample = thetaVec)
names(thetaDF) = c("observation", "sample")
ggplot(thetaDF, aes(x=sample, fill=observation)) +geom_density(alpha=.25)

# Comparing EAP Estimates with Posterior SDs

plot(y = modelIRT_2PL_SI_samples$summary(variables = c("theta"))$sd, 
     x = modelIRT_2PL_SI_samples$summary(variables = c("theta"))$mean,
     xlab = "E(theta|Y)", ylab = "SD(theta|Y)", main="Mean vs SD of Theta")

# Comparing EAP Estimates with Sum Scores
plot(y = rowSums(conspiracyItemsDichtomous), x = modelIRT_2PL_SI_samples$summary(variables = c("theta"))$mean,
     ylab = "Sum Score", xlab = expression(theta))
