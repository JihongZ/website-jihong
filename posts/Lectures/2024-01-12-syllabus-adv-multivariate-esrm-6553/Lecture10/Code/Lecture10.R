library(tidyverse)
library(ggpubr)
library(kableExtra)
library(here)
library(cmdstanr)
library(posterior)
library(blavaan)
self_color <- c("#DB7093", "#AFEEEE", "#3CB371", "#9370DB", "#FFD700")
root_dir <- "posts/Lectures/2024-01-12-syllabus-adv-multivariate-esrm-6553/Lecture07/Code"
current_dir <- "posts/Lectures/2024-01-12-syllabus-adv-multivariate-esrm-6553/Lecture10/Code"
save_dir <- "~/Library/CloudStorage/OneDrive-Personal/2024 Spring/ESRM6553 - Advanced Multivariate Modeling/Lecture10"
save_dir_lec9 <- "~/Library/CloudStorage/OneDrive-Personal/2024 Spring/ESRM6553 - Advanced Multivariate Modeling/Lecture09"
save_dir_lec7 <- "~/Library/CloudStorage/OneDrive-Personal/2024 Spring/ESRM6553 - Advanced Multivariate Modeling/Lecture07"

theme_set(theme_bw() + theme(legend.position = 'top') )
  

dat <- read.csv(here(root_dir, 'conspiracies.csv'))
itemResp <- dat[,1:10]
colnames(itemResp) <- paste0('item', 1:10)
conspiracyItems = itemResp
as.data.frame(table(itemResp[,2]-1)) |> 
  ggplot() +
  geom_col(aes(x = Var1, y = Freq)) + 
  labs(x = "y", title = "Empirical distribution of Item 2's Responses") +
  theme_classic()

set.seed(1234)
Reduce(rbind, lapply(c(.1, .3, .5, .7), \(x) data.frame(P = rbinom(n = 177, prob = x, size = 4), prob = x))) |> 
  mutate(prob = factor(prob, levels = c(.1, .3, .5, .7))) |> 
  ggplot() +
  geom_histogram(aes(x = P, fill = prob), position = position_dodge(), binwidth = .9) + 
  labs(x = "y", title = "Theorectical Probability Mass Functions") +
  theme_classic() 


# Transform to 0-4 scale --------------------------------------------------
conspiracyItemsBinomial = conspiracyItems
for (item in 1:ncol(conspiracyItemsBinomial)){
  conspiracyItemsBinomial[, item] = conspiracyItemsBinomial[, item] - 1
}
maxItem = apply(X = conspiracyItemsBinomial,
                MARGIN = 2, 
                FUN = max)
maxItem
### Prepare data list -----------------------------
# data dimensions
nObs = nrow(conspiracyItems)
nItems = ncol(conspiracyItems)

# item intercept hyperparameters
muMeanHyperParameter = 0
muMeanVecHP = rep(muMeanHyperParameter, nItems)

muVarianceHyperParameter = 1000
muCovarianceMatrixHP = diag(x = muVarianceHyperParameter, nrow = nItems)

# item discrimination/factor loading hyperparameters
lambdaMeanHyperParameter = 0
lambdaMeanVecHP = rep(lambdaMeanHyperParameter, nItems)

lambdaVarianceHyperParameter = 1000
lambdaCovarianceMatrixHP = diag(x = lambdaVarianceHyperParameter, nrow = nItems)


modelBinomial_data = list(
  nObs = nObs,
  nItems = nItems,
  maxItem = maxItem,
  Y = t(conspiracyItemsBinomial), 
  meanMu = muMeanVecHP,
  covMu = muCovarianceMatrixHP,
  meanLambda = lambdaMeanVecHP,
  covLambda = lambdaCovarianceMatrixHP
)


# Run Stan Model with Polytomous Response ---------------------------------
modelBinomial_stan <- cmdstan_model(here(current_dir, "Lecture10PolyResponse.stan"))
modelBinomial_samples = modelBinomial_stan$sample(
  data = modelBinomial_data,
  seed = 12112022,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 5000,
  iter_sampling = 5000,
  init = function() list(lambda=rnorm(nItems, mean=5, sd=1))
)

# save object
if (file.exists(here(save_dir, "modelBinomial_samples.RDS"))) {
  modelBinomial_samples <- readRDS(here(save_dir, "modelBinomial_samples.RDS"))
}else{
  modelBinomial_samples$save_object(here(save_dir, "modelBinomial_samples.RDS"))
}

# checking convergence
max(modelBinomial_samples$summary(.cores = 4)$rhat, na.rm = TRUE)

# item parameter results
print(modelBinomial_samples$summary(variables = c("mu", "lambda"), .cores = 4) ,n=Inf)

### Option Characteristic Curves -----------------------------
itemNumber = 10

labelMu = paste0("mu[", itemNumber, "]")
labelLambda = paste0("lambda[", itemNumber, "]")
itemParameters = modelBinomial_samples$draws(variables = c(labelMu, labelLambda), format = "draws_matrix")
itemSummary = modelBinomial_samples$summary(variables = c(labelMu, labelLambda))

# item plot
theta = seq(-3,3,.1) # for plotting analysis lines--x axis values
y = matrix(data = 0, nrow = length(theta), ncol=5)

thetaMat = NULL
prob = exp(itemSummary$mean[which(itemSummary$variable==labelMu)] + 
             itemSummary$mean[which(itemSummary$variable==labelLambda)]*theta)/
  (1+exp(itemSummary$mean[which(itemSummary$variable==labelMu)] + 
           itemSummary$mean[which(itemSummary$variable==labelLambda)]*theta))

option = 1
for (option in 1:5){
  y[,option] = dbinom(x = option-1, size=4, prob=prob)
}
colnames(y) <- paste0("Option", 1:5)

cbind(theta, y) |> 
  as.data.frame() |> 
  pivot_longer(starts_with('Option'), names_to = "Option", values_to = "y") |> 
  ggplot() +
  geom_line(aes(x = theta, y = y, col = Option, group = Option), linewidth = 1.4) +
  theme_bw() +
  labs(xlab=expression(theta), ylab="P(Y |theta)", 
       title=paste0("Option Characteristic Curves for Item ", itemNumber)) +
  theme(legend.position = 'top') 
ggsave(here(current_dir, "OPC_item10.png"), width = 8, height = 6 )

### Investigating item parameters -----------------------------
# item plot
theta = seq(-3,3,.1) # for plotting analysis lines--x axis values

# drawing item characteristic curves for item
y_posteriorMean = sapply(theta, function(x){
  4*exp(as.numeric(itemParameters[1,labelMu]) + as.numeric(itemParameters[1,labelLambda])*x)/
    (1+exp(as.numeric(itemParameters[1,labelMu]) + as.numeric(itemParameters[1,labelLambda])*x)) +1
})


get_result(a)
y_draws <- sapply(2:nrow(itemParameters), function(draw){
  browser()
  4*exp(as.numeric(itemParameters[draw,labelMu]) + as.numeric(itemParameters[draw,labelLambda])*theta)/
    (1+exp(as.numeric(itemParameters[draw,labelMu]) + as.numeric(itemParameters[draw,labelLambda])*theta)) +1 
})
colnames(y_draws) <- paste0("y_draw", 1:ncol(y_draws))
ICC_plot <- cbind(
  theta,
  y_posteriorMean,
  y_draws
) |> 
  as.data.frame() |> 
  pivot_longer(starts_with('y_'), names_to = "Type", values_to = "y") |> 
  mutate(Type_Color = ifelse(Type == "y_posteriorMean", "Posterior Mean", "Draw"))

ggplot(ICC_plot |> filter(Type %in% c("y_posteriorMean", paste0("y_draw", sample(1:10000, 500))))) +
  geom_line(aes(x = theta, y = y, group = Type, col = Type_Color, linewidth = Type_Color)) +
  scale_color_manual(values = c("black", "red")) + 
  scale_linewidth_manual(values = c(1, 1.5)) + 
  scale_x_continuous(limits = c(-3, 3), breaks = seq(-3,3, 1)) +
  theme_bw() +
  theme(legend.position = 'top')  +
  labs(x = greekLetters::greeks('theta'), y = 'Item 10 Expected Value', title = "Item 10 ICC")
ggsave(here(current_dir, "ICC_item10.png"), width = 8, height = 6 )

# EAP Estimates of Latent Variables
hist(modelBinomial_samples$summary(variables = c("theta"))$mean, main="EAP Estimates of Theta", 
     xlab = expression(theta))

### ICC for all items -----------------------------
itemParameters_all = modelBinomial_samples$draws(variables = c("mu", "lambda"), format = "draws_matrix")
ICC_AllItems <- sapply(1:10, function(itemNumber){
  labelMu = paste0("mu[", itemNumber, "]")
  labelLambda = paste0("lambda[", itemNumber, "]")
  4*exp(as.numeric(itemParameters_all[1,labelMu]) + as.numeric(itemParameters_all[1,labelLambda])*theta)/
    (1+exp(as.numeric(itemParameters_all[1,labelMu]) + as.numeric(itemParameters_all[1,labelLambda])*theta)) +1
})
ICC_AllItems <- as.data.frame(ICC_AllItems)
colnames(ICC_AllItems) <- paste0("I", 1:10)
ICC_AllItems$theta = theta

ICC_AllItems |> 
  pivot_longer(starts_with('I'), names_to = "Item", values_to = 'y') |> 
  mutate(Item = factor(Item, levels = paste0("I", 1:10))) |> 
  ggplot() +
  geom_vline(aes(xintercept = 0), col = "black", linewidth = 1.5, linetype = "dotted") +
  geom_vline(aes(xintercept = 2), col = "black", linewidth = 1.5, linetype = "dotted") +
  geom_path(aes(x = theta, y = y, col = Item), linewidth = 1.5, alpha = .7) +
  theme_bw() +
  theme(legend.position = 'top')  +
  labs(x = greekLetters::greeks('theta'), y = 'Item Expected Value', title = "All Items' ICC")
ggsave(here(current_dir, "ICC_itemAll.png"), width = 8, height = 6 )

### Compared to IRT with dichotomous response -----------------------------
modelIRT_2PL_SI_samples <- readRDS(here(save_dir_lec9, "modelIRT_2PL_SI_samples.RDS"))
modelNormal_samples <- readRDS(here(save_dir_lec7, "model03fix.RDS"))

Score_table <- tibble(
  Score_BinomialModel = modelBinomial_samples$summary(variables = c("theta"), .cores = 5)$mean,
  Score_IRT2PLModel = modelIRT_2PL_SI_samples$summary(variables = c("theta"), .cores = 5)$mean,
  Score_NormalModel = modelNormal_samples$summary(variables = c("theta"), .cores = 5)$mean,
  Score_Sum = scale(rowSums(itemResp)),
  ID = 1:177
) 

Score_table_densityplot <- Score_table |> 
  pivot_longer(-ID, names_to = "Score", values_to = "theta") |> 
  mutate(Score = factor(Score, levels = c("Score_BinomialModel", "Score_IRT2PLModel", "Score_NormalModel", "Score_Sum"),
                        labels =c("Binomial Model", "2PL IRT", "CFA", "Sum Score"))) 

## Density Plot
ggplot(Score_table_densityplot) +
  geom_density(aes(x = theta, col = Score, fill = Score), alpha = .3) +
  labs(x = greekLetters::greeks('theta'), y = 'Probability Density', title = "Model Differences in Factor Scores Estimates") +
  scale_fill_manual(values = self_color[c(1,3, 4, 5)])  +
  scale_color_manual(values = self_color[c(1, 3, 4, 5)]) 
ggsave(here(current_dir, "FactorScore_TwoModels.png"), width = 8, height = 6 )  

## Scatter Plot
Score_table_scatter <- Score_table |> 
  pivot_longer(-c(ID, Score_Sum), names_to = "Score", values_to = "theta") |> 
  mutate(Score = factor(Score, levels = c("Score_BinomialModel", "Score_IRT2PLModel", "Score_NormalModel"),
                        labels =c("Binomial Model", "2PL IRT", "CFA"))) 

ggplot(Score_table_scatter) +
  geom_point(aes(y = Score_Sum, x = theta, col = Score), shape = 1, size = 3, stroke = 1.3, alpha = .5) +
  labs(y = "Sum Score", x = greekLetters::greeks('theta'), title = "Model Differences in Factor Scores Estimates") +
  scale_color_manual(values = self_color[c(1, 3, 4)]) 
ggsave(here(current_dir, "FactorScore_Scatters.png"), width = 8, height = 6 )  



## Graded Response Model -------------------------------------
modelOrderedLogit_stan = cmdstan_model(here(current_dir, "Lecture10GradedResponse.stan"))

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

thrVarianceHyperParameter = 1000
thrCovarianceMatrixHP = diag(x = thrVarianceHyperParameter, nrow = maxCategory-1)
thrCovArray = array(data = 0, dim = c(nItems, maxCategory-1, maxCategory-1))
for (item in 1:nItems){
  thrCovArray[item, , ] = diag(x = thrVarianceHyperParameter, nrow = maxCategory-1)
}

# item discrimination/factor loading hyperparameters
lambdaMeanHyperParameter = 0
lambdaMeanVecHP = rep(lambdaMeanHyperParameter, nItems)

lambdaVarianceHyperParameter = 1000
lambdaCovarianceMatrixHP = diag(x = lambdaVarianceHyperParameter, nrow = nItems)


modelOrderedLogit_data = list(
  nObs = nObs,
  nItems = nItems,
  maxCategory = maxCategory,
  maxItem = maxItem,
  Y = t(conspiracyItems), 
  meanThr = thrMeanMatrix,
  covThr = thrCovArray,
  meanLambda = lambdaMeanVecHP,
  covLambda = lambdaCovarianceMatrixHP
)

modelOrderedLogit_samples = modelOrderedLogit_stan$sample(
  data = modelOrderedLogit_data,
  seed = 121120221,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 5000,
  iter_sampling = 5000,
  init = function() list(lambda=rnorm(nItems, mean=5, sd=1))
)

# save object
if (file.exists(here(save_dir, "modelOrderedLogit_samples.RDS"))) {
  modelOrderedLogit_samples <- readRDS(here(save_dir, "modelOrderedLogit_samples.RDS"))
}else{
  modelOrderedLogit_samples$save_object(here(save_dir, "modelOrderedLogit_samples.RDS"))
}
 
# checking convergence
max(modelOrderedLogit_samples$summary(.cores = 5)$rhat, na.rm = TRUE)

# item parameter results
print(modelOrderedLogit_samples$summary(variables = c("lambda", "mu"), .cores = 5) ,n=Inf)

### Option Characteristic Curves with GRM -----------------------------
OPC_Plot_GRM <- function(itemNumber) {
  labelMu = paste0("mu[", itemNumber, ",", 1:4, "]")
  labelLambda = paste0("lambda[", itemNumber, "]")
  muParams = modelOrderedLogit_samples$summary(variables = labelMu)
  lambdaParams = modelOrderedLogit_samples$summary(variables = labelLambda)
  
  # item plot
  theta = seq(-3,3,.1) # for plotting analysis lines--x axis values
  y = NULL
  thetaMat = NULL
  expectedValue = 0
  
  
  for (option in 1:5){
    if (option==1){
      prob = 1 - exp(muParams$mean[which(muParams$variable == labelMu[option])] + 
                       lambdaParams$mean[which(lambdaParams$variable == labelLambda[1])]*theta)/
        (1+exp(muParams$mean[which(muParams$variable == labelMu[option])] + 
                 lambdaParams$mean[which(lambdaParams$variable == labelLambda[1])]*theta))
    } else if (option == 5){
      
      prob = (exp(muParams$mean[which(muParams$variable == labelMu[option-1])] + 
                    lambdaParams$mean[which(lambdaParams$variable == labelLambda[1])]*theta)/
                (1+exp(muParams$mean[which(muParams$variable == labelMu[option-1])] + 
                         lambdaParams$mean[which(lambdaParams$variable == labelLambda[1])]*theta)))
    } else {
      prob = (exp(muParams$mean[which(muParams$variable == labelMu[option-1])] + 
                    lambdaParams$mean[which(lambdaParams$variable == labelLambda[1])]*theta)/
                (1+exp(muParams$mean[which(muParams$variable == labelMu[option-1])] + 
                         lambdaParams$mean[which(lambdaParams$variable == labelLambda[1])]*theta))) -
        exp(muParams$mean[which(muParams$variable == labelMu[option])] + 
              lambdaParams$mean[which(lambdaParams$variable == labelLambda[1])]*theta)/
        (1+exp(muParams$mean[which(muParams$variable == labelMu[option])] + 
                 lambdaParams$mean[which(lambdaParams$variable == labelLambda[1])]*theta))
    }
    
    # thetaMat = cbind(thetaMat, theta)
    expectedValue = expectedValue + prob*option
    y = cbind(y, prob)
  }
  
  colnames(y) <- paste0("Option", 1:5)
  
  cbind(theta, y) |> 
    as.data.frame() |> 
    pivot_longer(starts_with('Option'), names_to = "Option", values_to = "y") |> 
    ggplot() +
    geom_line(aes(x = theta, y = y, col = Option, group = Option), linewidth = 1.4) +
    theme_bw() +
    labs(xlab=expression(theta), ylab="P(Y |theta)", 
         title=paste0("Option Characteristic Curves for Item ", itemNumber," with GRM")) +
    theme(legend.position = 'top') 
}

p_i10 <- OPC_Plot_GRM(itemNumber = 10)
ggsave(here(current_dir, "OPC_item10_GRM.png"), width = 8, height = 6 )

p_i1 <- OPC_Plot_GRM(itemNumber = 1)
p_i2 <- OPC_Plot_GRM(itemNumber = 2)
p_i3 <- OPC_Plot_GRM(itemNumber = 3)
p_i4 <- OPC_Plot_GRM(itemNumber = 4)
p_i5 <- OPC_Plot_GRM(itemNumber = 5)
p_i6 <- OPC_Plot_GRM(itemNumber = 6)
p_i7 <- OPC_Plot_GRM(itemNumber = 7)
p_i8 <- OPC_Plot_GRM(itemNumber = 8)
p_i9 <- OPC_Plot_GRM(itemNumber = 9)

ggpubr::ggarrange(p_i1, p_i2, p_i3, p_i4, p_i5, p_i6, p_i7, p_i8, p_i9, ncol = 3, nrow = 3)
ggsave(here(current_dir, "OPC_item1-9_GRM.png"), width = 12, height = 10 )


### EAP of Theta -----------------------------
Score_table <- tibble(
  Score_BinomialModel = modelBinomial_samples$summary(variables = c("theta"), .cores = 5)$mean,
  Score_IRT2PLModel = modelIRT_2PL_SI_samples$summary(variables = c("theta"), .cores = 5)$mean,
  Score_NormalModel = modelNormal_samples$summary(variables = c("theta"), .cores = 5)$mean,
  Score_Sum = scale(rowSums(itemResp)),
  ID = 1:177
) 

Score_table$Score_GRM <- modelOrderedLogit_samples$summary(variables = c("theta"), .cores = 5)$mean
Score_table_scatter2 <-  
  Score_table |> 
  pivot_longer(-c(ID, Score_Sum), names_to = "Score", values_to = "theta") |> 
  mutate(Score = factor(Score, levels = c("Score_BinomialModel", "Score_IRT2PLModel", "Score_NormalModel", "Score_GRM"),
                        labels =c("Binomial Model", "2PL IRT", "CFA", "GRM"))) 

ggplot(Score_table_scatter2) +
  geom_point(aes(y = Score_Sum, x = theta, col = Score), shape = 1, size = 3, stroke = 1.3, alpha = .1) +
  geom_smooth(aes(y = Score_Sum, x = theta, col = Score), se = FALSE) +
  labs(y = "Sum Score", x = greekLetters::greeks('theta'), title = "Model Differences in Factor Scores Estimates") +
  scale_color_manual(values = self_color[c(1, 3, 4, 5)]) 
ggsave(here(current_dir, "FactorScore_ThreeModels.png"), width = 10, height = 8 )

### Posterior SDs -----------------------------
Score_SD_table <- tibble(
  Score_SD_BinomialModel = modelBinomial_samples$summary(variables = c("theta"), .cores = 5)$sd,
  Score_SD_IRT2PLModel = modelIRT_2PL_SI_samples$summary(variables = c("theta"), .cores = 5)$sd,
  Score_SD_NormalModel = modelNormal_samples$summary(variables = c("theta"), .cores = 5)$sd,
  Score_SD_GRM = modelOrderedLogit_samples$summary(variables = c("theta"), .cores = 5)$sd,
  Sum_Score = rowSums(itemResp),
  ID = 1:177
) 

Score_SD_table_scatter2 <-  
  Score_SD_table |> 
  pivot_longer(-c(ID, Sum_Score), names_to = "Model", values_to = "SD") |> 
  mutate(Model = factor(Model, levels = c("Score_SD_BinomialModel", "Score_SD_IRT2PLModel", "Score_SD_NormalModel", "Score_SD_GRM"),
                        labels =c("Binomial Model", "2PL IRT", "CFA" , "GRM"))) 

ggplot(Score_SD_table_scatter2) +
  geom_point(aes(x = Sum_Score, y = SD, col = Model), shape = 1, size = 1, stroke = 1.3, alpha = .5) +
  geom_smooth(aes(x = Sum_Score, y = SD, col = Model), se = FALSE) +
  labs(x = "Observed Sum Score", y = "Posterior SD", title = "Model Differences in Factor Scores Uncertainty") +
  scale_color_manual(values = self_color[c(1, 3, 4, 5)])
ggsave(here(current_dir, "FactorScoreSD_ThreeModels.png"), width = 10, height = 8 )
