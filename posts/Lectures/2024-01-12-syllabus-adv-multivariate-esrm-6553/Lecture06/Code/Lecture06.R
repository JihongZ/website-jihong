if (0) {
  load(here::here("posts", "Lectures","2024-01-12-syllabus-adv-multivariate-esrm-6553", 
                  "Lecture06", "Code", "Lecture06.RData"))
}
root_dir <- here::here("posts", "Lectures","2024-01-12-syllabus-adv-multivariate-esrm-6553", "Lecture06", "Code")
large_data_dir <- here::here("~/Library/CloudStorage/OneDrive-Personal/2024 Spring/ESRM6553 - Advanced Multivariate Modeling/Lecture06")
# Simulation Study: Model 1 -----------------------------------------------
# One-factor model without cross-loadings
library(tidyverse)
library(cmdstanr)
set.seed(1234)
N <- 1000
J <- 6
# parameters
psi <- .3 # factor correlation
sigma <- .1 # residual varaince
FS <- mvtnorm::rmvnorm(N, mean = c(0, 0), sigma = matrix(c(1, psi, psi, 1), 2, 2, byrow = T))
Lambda <- matrix(
  c(
    0.7, 0,
    0.5, 0,
    0.3, 0,
    0, 0.7,
    0, 0.5,
    0, 0.3
  ), 6, 2,
  byrow = T
)
mu <- matrix(rep(0.1, J), nrow = 1, byrow = T)
residual <- mvtnorm::rmvnorm(N, mean = rep(0, J), sigma = diag(sigma^2, J))
Y <- t(apply(FS %*% t(Lambda), 1, \(x) x + mu)) + residual


# lavaan
library(lavaan)
mod <- "
F1 =~ I1 + I2 + I3
F2 =~ I4 + I5 + I6
"
dat <- as.data.frame(Y)
colnames(dat) <- paste0('I', 1:6)
fit <- cfa(mod, data = dat, std.lv = TRUE)
summary(fit, fit.measures = TRUE)

# input variables
Q <- matrix(
  c(
    1, 0,
    1, 0,
    1, 0,
    0, 1,
    0, 1,
    0, 1
  ), 6, 2,
  byrow = T
)
Q

## Transform Q to location index
loc <- Q |>
  as.data.frame() |>
  rename(`1` = V1, `2` = V2) |> 
  rownames_to_column("Item") |>
  pivot_longer(c(`1`, `2`), names_to = "Theta", values_to = "q") |> 
  mutate(across(Item:q, as.numeric)) |> 
  filter(q == 1) |> 
  as.matrix()

data_list <- list(
  N = 1000, # number of subjects/observations
  J = J, # number of items
  K = 2, # number of latent variables,
  Y = Y,
  Q = Q,
  # location of lambda
  kk = loc[,2],
  #hyperparameter
  sigmaRate = .1,
  meanMu = rep(0, J),
  covMu = diag(1000, J),
  meanTheta = rep(0, 2),
  eta = 1,
  meanLambda = rep(0, J),
  covLambda = diag(1000, J)
)

mod_cfa_twofactor <- cmdstan_model(here::here(root_dir, "simulation_loc.stan"))

# quick check using pathfinder
# fit_pf <- mod_cfa_twofactor$pathfinder(data = data_list, seed = 1234, draws = 4000)
# fit_pf$summary('lambda')

fit_cfa_twofactor <- mod_cfa_twofactor$sample(
  data = data_list,
  seed = 1234,
  chains = 4,
  parallel_chains = 4, 
  iter_sampling = 2000,
  iter_warmup = 1000
)

## save model 1 object into local directory
# m1_temp_rds_file <- tempfile(fileext = ".RDS", tmpdir = large_data_dir)
# fit_cfa_twofactor$save_object(file = m1_temp_rds_file)


fit_cfa_twofactor$summary("lambda")
fit_cfa_twofactor$summary(c("corrTheta[1,2]", "corrTheta[2,1]"))
fit_cfa_twofactor$summary("L[2,1]")

fit_cfa_twofactor$summary("mu")
fit_cfa_twofactor$summary("sigma")
fit_cfa_twofactor$summary("Item_Mean_rep")

### PPMC
Item_Mean_rep_mat <- fit_cfa_twofactor$draws("Item_Mean_rep", format = 'matrix')
Item_Mean_obs <- colMeans(Y)
PPP <- rep(NA, J)
for (item in 1:J) {
  PPP[item] <- mean(Item_Mean_rep_mat[, item] > Item_Mean_obs[item])
}
data.frame(
  Item = factor(1:J, levels = 1:J),
  PPP = PPP
) |> 
  ggplot() +
  geom_col(aes(x = Item, y = PPP)) + 
  geom_hline(aes(yintercept = .5), col = 'red', size = 1.3) + 
  theme_classic()


# Simulation 2 ------------------------------------------------------------
set.seed(1234)
N <- 1000
J2 <- 7
# parameters
psi <- .3 # factor correlation
sigma <- .1 # residual varaince
FS <- mvtnorm::rmvnorm(N, mean = c(0, 0), sigma = matrix(c(1, psi, psi, 1), 2, 2, byrow = T))
Lambda2 <- matrix(
  c(
    0.7, 0,
    0.5, 0,
    0.3, 0,
    0.5, 0.5,
    0, 0.7,
    0, 0.5,
    0, 0.3
  ), J2, 2,
  byrow = T
)
mu <- matrix(rep(0.1, J2), nrow = 1, byrow = T)
residual <- mvtnorm::rmvnorm(N, mean = rep(0, J2), sigma = diag(sigma^2, J2))
Y2 <- t(apply(FS %*% t(Lambda2), 1, \(x) x + mu)) + residual

## Data preparation
## Transform Q to location index
Q2 = Lambda2
Q2[Q2 != 0] <- 1
loc2 <- Q2 |>
  as.data.frame() |>
  rename(`1` = V1, `2` = V2) |> 
  rownames_to_column("Item") |>
  pivot_longer(c(`1`, `2`), names_to = "Theta", values_to = "q") |> 
  mutate(across(Item:q, as.numeric)) |> 
  mutate(q = -q + 2) |> 
  as.matrix()

mod_cfa_exp2 <- cmdstan_model(here::here(root_dir, "simulation_exp2.stan"))

data_list2 <- list(
  N = 1000, # number of subjects/observations
  J = J2, # number of items
  K = 2, # number of latent variables,
  Y = Y2,
  Q = Q2,
  # location of lambda
  R = nrow(loc2),
  jj = loc2[,1],
  kk = loc2[,2],
  q = loc2[,3],
  #hyperparameter
  meanSigma = .1,
  scaleSigma = 1,
  meanMu = rep(0, J2),
  covMu = diag(10, J2),
  meanTheta = rep(0, 2),
  corrTheta = matrix(c(1, .3, .3, 1), 2, 2, byrow = T)
)
    
## MCMC
fit_cfa_exp2 <- mod_cfa_exp2$sample(
  data = data_list2,
  seed = 1234,
  chains = 4,
  parallel_chains = 4, 
  iter_sampling = 3000,
  iter_warmup = 3000
)

## save model 2 object into local directory
m2_temp_rds_file <- tempfile(fileext = ".RDS", tmpdir = large_data_dir)
fit_cfa_exp2$save_object(file = m2_temp_rds_file)

fit_cfa_exp2$summary('lambda')
fit_cfa_exp2$summary('mu')

  

# quick check using pathfinder
# fit_pf2 <- mod_cfa_exp2$pathfinder(data = data_list2, seed = 1234, draws = 4000)
# fit_pf2$summary('lambda')

#save(Y, fit, Q, loc, data_list,
#     Q2, loc2, data_list2, Lambda2,
#     file = here::here("posts", "Lectures","2024-01-12-syllabus-adv-multivariate-esrm-6553", 
#                       "Lecture06", "Code", "Lecture06.RData")
#)

