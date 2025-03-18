## Load packages
library(cmdstanr)
library(bayesplot)
## Read in data
dat <- read.csv(here::here("teaching", "2024-01-12-syllabus-adv-multivariate-esrm-6553", "Data", "DietData.csv"))
dat$DietGroup <- factor(dat$DietGroup, levels = 1:3)
dat$HeightIN60 <- dat$HeightIN - 60
head(dat)

### Multivariate
set.seed(1234)

##
mod_full_new <- cmdstan_model(here::here("teaching", "2024-01-12-syllabus-adv-multivariate-esrm-6553", "Lecture04", "Code", "FullModel_New.stan"))
FullModelFormula <- as.formula("WeightLB ~ HeightIN60 + DietGroup + HeightIN60*DietGroup")
X <- model.matrix(FullModelFormula, data = dat)
data_full_new <- list(
  N = nrow(dat),
  P = ncol(X),
  X = X,
  weightLB = dat$WeightLB,
  sigmaRate = 0.1
)
fit_full_new <- mod_full_new$sample(
  data = data_full_new,
  seed = 1234,
  chains = 4,
  parallel_chains = 4
)
fit_full_new$summary()
fit_full_new$time()


## Always save to RData


### PPP-values in Stan
mod_full_ppp <- cmdstan_model(here::here("teaching", "2024-01-12-syllabus-adv-multivariate-esrm-6553", "Lecture05", "Code", "FullModel_PPP.stan"))
fit_full_ppp <- mod_full_ppp$sample(
  data = data_full_new,
  seed = 1234,
  chains = 4,
  parallel_chains = 4
)
fit_full_ppp$summary(variables = c("mean_weightLB_rep", "sd_weightLB_rep", "ppp_mean", "ppp_sd"))

### WAIC, LOO
library(loo)
waic(fit_full_ppp$draws("log_lik"))
fit_full_ppp$loo("log_lik")



### WAIC/LOO in empty model
mod_empty_ppp <- cmdstan_model(here::here("teaching", "2024-01-12-syllabus-adv-multivariate-esrm-6553", "Lecture03", "Code", "EmptyModel.stan"))
fit_empty_ppp <- mod_empty_ppp$sample(
  data = data_full_new,
  seed = 1234,
  chains = 4,
  parallel_chains = 4
)
fit_empty_ppp$loo("log_lik")



WAIC_full <- loo::waic(fit_full_ppp$draws("log_lik"))$estimates[3, 1]
WAIC_empty <- loo::waic(fit_empty_ppp$draws("log_lik"))$estimates[3, 1]
LOO_full <- fit_full_ppp$loo("log_lik")$estimates[3, 1]
LOO_empty <- fit_empty_ppp$loo("log_lik")$estimates[3, 1]


# Stan's LBFGS algorithm
fit_full_optim <- mod_full_ppp$optimize(data = data_full_new, seed = 1234, jacobian = TRUE)
fit_full_laplace <- mod_full_ppp$laplace(data = data_full_new, mode = fit_full_optim, draws = 4000)

# Run 'variational' method to use ADVI to approximate posterior
fit_full_vb <- mod_full_ppp$variational(data = data_full_new, seed = 1234, draws = 4000, algorithm = "meanfield", init = list(list(beta = fit_full_optim$summary("beta")$estimate, sigma = fit_full_optim$summary("sigma")$estimate)))

# Run 'pathfinder' method, a new alternative to the variational method
fit_pf <- mod_full_ppp$pathfinder(data = data_full_new, seed = 1234, draws = 4000)

library(tidyverse)
rbind(
  cbind(data.frame(Algorithm = "Laplace Approx."), fit_full_laplace$draws(paste0("beta[", 1:6, "]"), format = "draws_df")[, 1:6]),
  cbind(data.frame(Algorithm = "Variational Approx."), fit_full_vb$draws(paste0("beta[", 1:6, "]"), format = "draws_df")[, 1:6]),
  cbind(data.frame(Algorithm = "Pathfinder"), fit_pf$draws(paste0("beta[", 1:6, "]"))[, 1:6]),
  cbind(data.frame(Algorithm = "MCMC"), fit_full_ppp$draws(paste0("beta[", 1:6, "]"), format = "draws_df")[, 1:6])
) |>
  pivot_longer(starts_with("beta"), names_to = "Parameter", values_to = "Draws") |>
  ggplot() +
  geom_density(aes(x = Draws, fill = Algorithm), alpha = 0.4) +
  facet_wrap(~Parameter, scales = "free")

fit_full_optim$summary()
fit_full_ppp$summary()

save(dat, data_full_new, mod_full_ppp, fit_empty_ppp, fit_full_new, fit_full_ppp, WAIC_full, WAIC_empty, LOO_full, LOO_empty,
  fit_full_optim, fit_full_laplace, fit_full_vb, fit_pf,
  file = here::here("teaching","2024-01-12-syllabus-adv-multivariate-esrm-6553", "Lecture05", "Code", "Lecture05.RData")
)
