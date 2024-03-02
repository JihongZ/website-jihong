library(tidyverse)
library(here)
library(cmdstanr)

self_color <- c("#DB7093", "#AFEEEE", "#3CB371", "#9370DB", "#FFD700")
root_dir <- "posts/2024-01-12-syllabus-adv-multivariate-esrm-6553/Lecture07/Code"
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

modelCFA_stan <- cmdstan_model(here(root_dir, "Lecture07.stan"))

modelCFA_samples = modelCFA_stan$sample(
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

# item parameter results
modelCFA_samples$summary(c("mu", "lambda", "psi")) 

# show relationship between item means and mu parameters
colMeans(conspiracyItems, na.rm = TRUE)
modelCFA_samples$summary("mu") 


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
