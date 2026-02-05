library(ggplot2) # R package for data visualization
library(here)
# read in data
dat <- read.csv(here("teaching/2024-01-12-syllabus-adv-multivariate-esrm-6553/Lecture03/Code", "DietData.csv"))
dat$DietGroup <- factor(dat$DietGroup, levels = 1:3)
head(dat)

# Histgram for WeightLB - Dependent Variable
ggplot(dat) +
  geom_histogram(aes(x = WeightLB, y = ..density..), position = "identity", binwidth = 20, fill = 'grey', col = 'grey') +
  geom_density(aes(x = WeightLB), alpha = .2, size = 1.2) +
  theme_classic()

# Histgram for HeightIN - Independent Variable
ggplot(dat) +
  geom_histogram(aes(x = HeightIN, y = ..density..), position = "identity", binwidth = 2, fill = 'grey', col = 'grey') +
  geom_density(aes(x = HeightIN), alpha = .2, size = 1.2) +
  theme_classic()

# Histgram for WeightLB x Group
ggplot(dat) +
  aes(x = WeightLB, fill = DietGroup, col = DietGroup) +
  geom_histogram(aes(y = ..density..), position = "identity", binwidth = 20, alpha = 0.3) +
  geom_density(alpha = .2, size = 1.2) +
  theme_classic()
  
# Histgram for WeightLB x HeightIN x Group
ggplot(dat, aes(y = WeightLB, x = HeightIN, col = DietGroup, shape = DietGroup)) +
  geom_smooth(method = 'lm', se = FALSE) +
  geom_point() +
  theme_classic()

# Linear Model with Least Squares
## Center independent variable - HeightIN for better interpretation
dat$HeightIN <- dat$HeightIN - 60

## an empty model suggested by data
EmptyModel <- lm(WeightLB ~ 1, data = dat)

## Examine assumptions and leverage of fit
### Residual plot, Q-Q residuals, Scale-Location
plot(EmptyModel)

## Look at ANOVA table
### F-values, Sum/Mean of square of residuals
anova(EmptyModel)

## look at parameter summary
summary(EmptyModel)


library(cmdstanr)
# compile model -- this method is for stand-alone stan files (uses cmdstanr)
model00.fromFile = cmdstan_model(stan_file = here("~/github/website-jihong/teaching/2024-01-12-syllabus-adv-multivariate-esrm-6553/Lecture03/Code", "EmptyModel.stan"))

# build R list containing data for Stan: Must be named what "data" are listed in analysis
stanData = list(
  N = nrow(dat),
  weightLB = dat$WeightLB
)

# snippet of Stan syntax:
stanSyntaxSnippet = "
data {
  int<lower=0> N;
  vector[N] y;
}
"

# run MCMC chain (sample from posterior)
model00.samples = model00.fromFile$sample(
  data = stanData,
  seed = 1,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 10000,
  iter_sampling = 10000
)

model00.samples$summary()[c('variable','mean', 'rhat')][1:3, ]

## Using rstan
library(rstan)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# example MCMC analysis in rstan
model00.rstan = stan(
  model_code = stanModel,
  model_name = "Empty model",
  data = stanData,
  warmup = 10000,
  iter = 20000,
  chains = 4,
  verbose = TRUE
)

## Model 0 with poor convergence
model00Poor.fromFile = cmdstan_model(stan_file = "EmptyModelPoor.stan")
model00Poor.samples = model00Poor.fromFile$sample(
  data = stanData,
  seed = 1,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 10000,
  iter_sampling = 10000,
  refresh = 5000
)
model00Poor.samples$summary()
bayesplot::mcmc_trace(model00Poor.samples$draws("beta0"))


# Bonus: using rstanarm ---------------------------------------------------
## It is as simple as we did linear regression using lm()
library(rstanarm)
# Set this manually if desired:
ncores <- parallel::detectCores(logical = FALSE)
###
options(mc.cores = ncores)
set.seed(5078022)
refm_fit <- stan_glm(
  WeightLB ~ 1,
  family = gaussian(),
  data = dat,
  ### 5000 warmups and 5000 samplings
  chains = 4, iter = 10000
)
summary(refm_fit)
