library(tidyverse)
library(here)
library(cmdstanr)
library(bayesplot)

self_color <- c("#DB7093", "#AFEEEE", "#3CB371", "#9370DB", "#FFD700")
root_dir <- "teaching/2024-01-12-syllabus-adv-multivariate-esrm-6553/Lecture07/Code"
save_dir <- "~/Library/CloudStorage/OneDrive-Personal/2024 Spring/ESRM6553 - Advanced Multivariate Modeling/Lecture07"
dat <- read.csv(here(root_dir, 'conspiracies.csv'))
itemResp <- dat[,1:10]
colnames(itemResp) <- paste0('item', 1:10)
conspiracyItems <- itemResp
itemResp |> 
  rownames_to_column("ID") |> 
  pivot_longer(-ID, names_to = "Item", values_to = "Response") |> 
  mutate(Item = factor(Item, levels = paste0('item', 1:10)),
         Response = factor(Response, levels = 1:5)) |> 
  ggplot() +
  geom_bar(aes(x = Response, fill = Response, group = Response), 
           position = position_stack()) +
  facet_wrap(~ Item, nrow = 3, ncol = 4) +
  theme_classic() +
  scale_fill_manual(values = self_color)

## Prior density function plots
set.seed(1234)
### normal distribution
data.frame(
  x = seq(0, 5, .001),
  y = dnorm(x = seq(0, 5, .001), mean = 0, sd = sqrt(1000))
) |> 
  ggplot(aes(x=x, y =y)) +
  geom_path() +
  labs(x = "", y = "Probability") +
  theme_classic() +
  theme(text = element_text(size = 17))

data.frame(
  x = seq(0, 2, .001),
  y = dexp(x = seq(0, 2, .001), rate = .01)
  ) |> 
  ggplot(aes(x=x, y =y)) +
  geom_path() +
  labs(x = "", y = "Probability") +
  theme_classic() +
  theme(text = element_text(size = 17))

# R's data list object
# data dimensions
conspiracyItems = itemResp
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

# unique standard deviation hyperparameters
psiRateHyperParameter = .01
psiRateVecHP = rep(.1, nItems)

modelCFA_data = list(
  nObs = nObs,
  nItems = nItems,
  Y = conspiracyItems, 
  meanMu = muMeanVecHP,
  covMu = muCovarianceMatrixHP,
  meanLambda = lambdaMeanVecHP,
  covLambda = lambdaCovarianceMatrixHP,
  psiRate = psiRateVecHP
)

## Model 1: Hypothesis model
modelCFA_stan <- cmdstan_model(here(root_dir, "Lecture07.stan"))

## Empty model
modelEmpty_stan <- cmdstan_model(here(root_dir, "Lecture07Empty.stan"))
modelSaturated_stan <- cmdstan_model(here(root_dir, "Lecture07Saturated.stan"))

modelCFA_samples = modelCFA_stan$sample(
  data = modelCFA_data,
  seed = 09102022,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 2000
)

modelEmpty_samples = modelEmpty_stan$sample(
  data = modelCFA_data,
  seed = 09102022,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 2000
)
modelSaturated_samples = modelSaturated_stan$sample(
  data = modelCFA_data,
  seed = 09102022,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 2000
)


# save object
if (file.exists(here(save_dir, "model01.RDS"))) {
  modelCFA_samples <- readRDS(here(save_dir, "model01.RDS"))
}else{
  modelCFA_samples$save_object(here(save_dir, "model01.RDS"))
}
# Check convergence
max(modelCFA_samples$summary()$rhat, na.rm=TRUE)

# Check log-likelihood
LL_H0 <- as.numeric(modelCFA_samples$draws("mean_log_lik", format = "draws_matrix"))
LL_H0_rep <- as.numeric(modelCFA_samples$draws("mean_log_lik_rep", format = "draws_matrix"))
LL_Empty <- as.numeric(modelEmpty_samples$draws("mean_log_lik", format = "draws_matrix"))
LL_H1 <- as.numeric(modelSaturated_samples$draws("mean_log_lik", format = "draws_matrix"))

D_obs <- LL_H0 - LL_Empty
RMSEA2 = ((LL_H0 - LL_H0_rep + 2*LL_H1) - (p_star - pD)) / (p_star - pD) * nObs
RMSEA = sqrt(RMSEA2[RMSEA2 > 0])
hist(CFI)
hist(RMSEA)

# item parameter results
modelCFA_samples$summary(c("mu", "lambda", "psi")) 

# show relationship between item means and mu parameters
colMeans(conspiracyItems, na.rm = TRUE)
modelCFA_samples$summary("mu") 
modelCFA_samples$summary("psi") 

# investigating item parameters -------------------------------------------
itemNumber = 10

labelMu = paste0("mu[", itemNumber, "]")
labelLambda = paste0("lambda[", itemNumber, "]")
labelPsi = paste0("psi[", itemNumber, "]")
itemParameters = modelCFA_samples$draws(variables = c(labelMu, labelLambda, labelPsi), format = "draws_matrix")
itemSummary = modelCFA_samples$summary(variables = c(labelMu, labelLambda, labelPsi))

##################################################### -
## Plot a ICC for item 1
##################################################### -
theta <- seq(-3, 3, .1)

# draw item characteristic curves for item
predicted_y = sapply(theta, \(x) itemParameters[,labelMu] +  itemParameters[,labelLambda]*x)
dim(predicted_y) # each columns represent y-values give a theta

## create a data of ICC using Posterior Draws
predicted_y_alldraws <- data.frame(predicted_y)
colnames(predicted_y_alldraws) <- theta
predicted_y_alldraws <- predicted_y_alldraws |> 
  rownames_to_column("draw") |> 
  pivot_longer(-draw, names_to = "Theta", values_to = "Predicted_y") |> 
  mutate(Theta = factor(Theta, levels = theta))

## the predicted ICC give posterior mean (EAP line)
predicted_y_postMean <- data.frame(
  Theta = theta,
  y_postMean = as.numeric(itemSummary[1, 2]) + as.numeric(itemSummary[2, 2])*theta
) |> 
  mutate(Theta = factor(Theta, levels = theta))

## Color label for legend
colors <- c("Posterior Draw" = "skyblue", "EAP" = "red", "Item Limits" = "orange")
ggplot(predicted_y_alldraws) +
  geom_path(aes(x = Theta, y = Predicted_y, group = draw, color = "Posterior Draw"), linewidth = 1.2, alpha = .1) +
  geom_path(aes(x = Theta, y = y_postMean, color = "EAP"), group = 1, data = predicted_y_postMean , linewidth = 1.2) +
  geom_hline(aes(color = "Item Limits", yintercept = max(itemResp$item10)), linewidth = 1.2, linetype = "dashed") +
  geom_hline(aes(color = "Item Limits", yintercept = min(itemResp$item10)), linewidth = 1.2, linetype = "dashed") +
  scale_x_discrete(breaks = seq(-3, 3, 1)) +
  scale_y_continuous(breaks = seq(-2, 8, 1)) +
  scale_color_manual(values = colors) +
  labs(title = "ICC of Item 10", y = "Item 10 Predicted Value", x = expression(theta), color = "") +
  theme(text = element_text(size = 20),
        legend.position	= 'bottom')
ggsave(here(root_dir, "ICC_Item10.png"), width = 12, height = 7)


# Investigating latent variables ------------------------------------------
print(modelCFA_samples$summary('theta'),n=Inf)

## EAP distribution
EAP_forplot <- data.frame(
  Theta = modelCFA_samples$summary('theta')$mean,
  ID = 1:nObs
) 
ggplot(EAP_forplot) +
  geom_histogram(aes(x = Theta), binwidth = .5) +
  labs(
    x = expression(theta),
    y = 'Frequency',
    title = expression('EAP Estimates of theta')
  )
ggsave("EAP_Estimates.png", width = 7, height = 6)

ggplot(EAP_forplot) +
  geom_density(aes(x = Theta), col = 'red', linewidth = 1.2) +
  scale_x_continuous(limits = c(-2, 4)) +
  labs(
    x = expression(theta),
    y = 'Frequency',
    title = expression('EAP Estimates of theta')
  )

## Density of 500 draws
set.seed(1234)
theta_all_draws <- modelCFA_samples$draws('theta', format = 'draws_matrix')
theta_all_draws_long <- as_tibble(theta_all_draws) |> 
  rownames_to_column('draw') |> 
  pivot_longer(starts_with('theta'), names_to = 'ID', values_to = 'theta') |> 
  mutate(theta = as.numeric(theta)) |> 
  filter(draw %in% sample(1:2000, 500))

ggplot() +
  geom_density(aes(x = theta, group = draw), col = alpha('black', .1), 
               data = theta_all_draws_long) +
  geom_density(aes(x = Theta), col = 'red', linewidth = 1.2, data = EAP_forplot) +
  labs(
    x = expression(theta),
    y = 'Frequency',
    title = expression('EAP Estimates and 500 draws of θ')
  ) + 
  theme_classic() 
ggsave("Theta_Draws_density.png", width = 7, height = 6)
  
## Plotting three theta distribution side-by-side
theta_all_draws_long |> 
  filter(ID %in% paste0('theta[', c(106, 162, 166), ']')) |> 
  ggplot() +
  geom_density(aes(x = theta, fill = ID), alpha = .4) +
  labs(
    x = expression(theta),
    y = 'Frequency',
    title = expression('Density of θ for three individuals')
  ) + 
  theme_classic() 
ggsave("Theta_density_ThreeIndividuals.png", width = 7, height = 6)

## Comparing EAP estimates with posterior SDs
tibble(
  y = modelCFA_samples$summary('theta')$sd,
  x = modelCFA_samples$summary('theta')$mean
) |> 
  ggplot() +
  geom_point(aes(x = x, y = y), shape = 1, size = 3) +
  labs(x = 'E(θ|Y)', y = 'SD(θ|Y)') + 
  theme_classic() 
ggsave("EAP_SD.png", width = 7, height = 6)

## Comparing EAP estimates with sum scores
tibble(
  sumscore = rowSums(itemResp),
  EAP = modelCFA_samples$summary('theta')$mean
)|> 
  ggplot() +
  geom_point(aes(x = sumscore, y = EAP), shape = 1, size = 3) +
  labs(x = 'Sum Score', y = 'EAP') + 
  theme_classic() 
ggsave("EAP_SumScore.png", width = 7, height = 6)

## Comparing EAP estimates with factor scores by lavaan
library(lavaan)
lavaan.model <- ' theta  =~ item1 + item2 + item3 + item4 + item5 + item6 + item7 + item8 + item9 + item10 '

fit <- cfa(lavaan.model, data=conspiracyItems, std.lv = TRUE)
fs <- as.numeric(predict(fit))
tibble(
  fs = fs,
  EAP = modelCFA_samples$summary('theta')$mean
)|> 
  ggplot() +
  geom_point(aes(x = fs, y = EAP), shape = 1, size = 3) +
  labs(x = 'Factor Score', y = 'EAP') + 
  theme_classic() 
ggsave("EAP_FactorScore.png", width = 7, height = 6)




# Model 2 with seed 24102022 ----------------------------------------------
modelCFA_samplesFail = modelCFA_stan$sample(
  data = modelCFA_data,
  seed = 25102022,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 2000
)
# save object
if (file.exists(here(save_dir, "model01fail.RDS"))) {
  modelCFA_samplesFail <- readRDS(here(save_dir, "model01fail.RDS"))
}else{
  modelCFA_samplesFail$save_object(here(save_dir, "model01fail.RDS"))
}
# Check convergence
max(modelCFA_samplesFail$summary()$'rhat')

## Check posterior trace for lambda for first 100 people
bayesplot::mcmc_trace(modelCFA_samplesFail$draws(paste0('lambda[',1:9,']')), size = 1.2) +
  scale_color_manual(values = alpha(c("#DB7093", "#3CB371", "#9370DB", "#FFD700"), .8)) +
  theme_classic()
ggsave("Posterior_lambda.png", width = 10, height = 6)

## Check posterior densities
color_scheme_set(scheme = 'red')
bayesplot_theme_set(theme_classic())
mcmc_dens(modelCFA_samplesFail$draws(paste0('lambda[',1:9,']')), size = 1.2) 
ggsave("Posterior_lambda_density.png", width = 10, height = 6)

## Check Posterior trace plots of θ
mcmc_trace(modelCFA_samplesFail$draws(paste0('theta[',1:2,']')), size = 1.2) +
  scale_color_manual(values = alpha(c("#DB7093", "#3CB371", "#9370DB", "#FFD700"), .8))
ggsave("Posterior_theta_traceplot.png", width = 10, height = 6)

## Check Posterior density plots of θ
mcmc_dens(modelCFA_samplesFail$draws(paste0('theta[',1:2,']')), size = 1.2)
ggsave("Posterior_theta_density.png", width = 10, height = 6)


# Model 3: Fixing convergence ---------------------------------------------
modelCFA_samplesFix = modelCFA_stan$sample(
  data = modelCFA_data,
  seed = 25102022,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 1000,
  iter_sampling = 2000,
  init = \() list(lambda=rnorm(nItems, mean = 10, sd = 2))
)
# save object
if (file.exists(here(save_dir, "model03fix.RDS"))) {
  modelCFA_samplesFix <- readRDS(here(save_dir, "model03fix.RDS"))
}else{
  modelCFA_samplesFix$save_object(here(save_dir, "model03fix.RDS"))
}
# Check convergence
max(modelCFA_samplesFix$summary()$'rhat')

## compare model 01 with model 03
tibble(y = modelCFA_samplesFix$summary(variables = c("mu", "lambda", "psi", "theta"), .cores = 4)$mean,
       x = modelCFA_samples$summary(variables = c("mu", "lambda", "psi", "theta"), .cores = 4)$mean) |> 
  ggplot() +
  geom_point(aes(x = x, y = y), shape = 1, size = 3) +
  labs(
    title = "Comparing Results from Converged based on EAP of mu, lambda, psi and theta", 
    x = "Without Starting Values",
    y = "With Starting Values"
  )
ggsave("EAP_mu_lambda_psi_theta.png", width = 10, height = 6)
     
# blavaan -----------------------------------------------------------------
library(blavaan)

blavaan.model <- ' theta  =~ item1 + item2 + item3 + item4 + item5 + item6 + item7 + item8 + item9 + item10 '
model01_blv <- bcfa(blavaan.model, data=conspiracyItems,
            n.chains = 4, burnin = 1000, sample = 2000,
            target = 'stan', seed = 09102022,
            save.lvs = TRUE, # save sampled latent variable
            std.lv = TRUE,
            bcontrol = list(cores = 4),
            mcmcfile=TRUE # save Stan file
            ) # standardized latent variable

summary(model01_blv)

blavaanObj <- blavInspect(model01_blv, "mcobj")
blavaanLambdasummary <- summary(blavaanObj, 'ly_sign', prob = c(.05, .95))
blavaanLambdasummary$summary

# saveRDS(fit, here(save_dir, "model01_blv.RDS"))
tibble(y = as.numeric(c(modelCFA_samples$summary(variables = "lambda", .cores = 4)$mean,
                        ## psi is sd in stan, we need to compute psi^2 
                        (modelCFA_samples$summary(variables = "psi", .cores = 4)$mean)^2)),
       x = as.numeric(coef(model01_blv)),
       param = c(rep("factor loadings", 10), rep('unique variances', 10))
) |> 
  ggplot() +
  geom_abline(aes(slope = 1, intercept = 0), col = 'grey', linewidth = 1.5) +
  geom_point(aes(x = x, y = y, col = param), shape = 1, size = 5, stroke = 2) +
  labs(
    title = "Comparing Parameters Between Stan and blavaan", 
    x = "Stan Model",
    y = "blavaan Model"
  ) +
  scale_color_manual(values = self_color[c(1,3)]) +
  theme_classic()
ggsave(here(root_dir, "EAP_psi_lambda_Stan_blavaan.png"), width = 10, height = 6)

fs_blav <- rowMeans(Reduce(cbind, blavPredict(model01_blv)))
tibble(y = as.numeric(modelCFA_samples$summary(variables = c("theta"), .cores = 4)$mean),
       x = as.numeric(fs_blav)
  ) |> 
  ggplot() +
  geom_abline(aes(slope = 1, intercept = 0), col = 'grey', linewidth = 1.5) +
  geom_point(aes(x = x, y = y), shape = 1, size = 5, stroke = 2, col = self_color[1]) +
  labs(
    title = "Comparing Factor Scores Between Stan and blavaan", 
    x = "Stan Model",
    y = "blavaan Model"
  ) +
theme_classic()
ggsave(here(root_dir, "EAP_FactorScore_Stan_blavaan.png"), width = 6, height = 6)
