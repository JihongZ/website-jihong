library(tidyverse)
library(networktools)
library(ggplot2)
library(psych)
library(qgraph)

## Estimation
data(bfi)
big5groups <- list(
  Agreeableness = 1:5,
  Conscientiousness = 6:10,
  Extraversion = 11:15,
  Neuroticism = 16:20,
  Openness = 21:25
)
## density
density_nonzero_edge <- function(pcor_matrix){
  N_nonzero_edge = (sum(pcor_matrix == 0) - ncol(pcor_matrix)) /2
  N_all_edge = ncol(pcor_matrix)*(ncol(pcor_matrix)-1)/2
  N_nonzero_edge/N_all_edge
}
density_nonzero_edge(EBICgraph)

### Method 1: EBICglasso
CorMat <- cor_auto(bfi[,1:25])
EBICgraph <- EBICglasso(CorMat, nrow(bfi), 0.5, threshold = TRUE)



### Method 2: Prune method in psychometric
PruneFit <- ggm(bfi[,1:25]) |> prune(alpha = .01)
density_nonzero_edge(getmatrix(PruneFit, "omega"))

### Method 3: BF method in BGGM
BGGMfit <- BGGM::explore(bfi[,1:25], type = "continuous", iter = 1000, analytic = FALSE) |> 
  select()
density_nonzero_edge(BGGMfit$pcor_mat_zero)

## Network structure
qgraph(EBICgraph, groups = big5groups)
prune_omega <- getmatrix(PruneFit, "omega")
colnames(prune_omega) <- colnames(bfi[,1:25])
qgraph(prune_omega, labels=colnames(bfi[,1:25]), groups = big5groups)
BGGMfit_omega <- BGGMfit$pcor_mat_zero
colnames(BGGMfit_omega) <- colnames(bfi[,1:25])
qgraph(BGGMfit_omega,  labels=colnames(bfi[,1:25]), groups = big5groups)

## Centrality - Strength
p1 <- centralityPlot(EBICgraph, print = FALSE) 
p2 <- centralityPlot(prune_omega, print = FALSE)
p3 <- centralityPlot(BGGMfit_omega, print = FALSE)
p1$layers[[2]] <- NULL
p2$layers[[2]] <- NULL
p3$layers[[2]] <- NULL
hl1 = !(colnames(bfi[,1:25])%in%c("C4", "E4"))
hl2 = !(colnames(bfi[,1:25])%in%c("C4", "E4"))
hl3 = !(colnames(bfi[,1:25])%in%c("N1", "C4"))
p1 + geom_point(aes(color = hl1), size = 10)+ theme(text = element_text(size = 30), legend.position="none")
p2 + geom_point(aes(color = hl2), size = 10)+ theme(text = element_text(size = 30), legend.position="none")
p3 + geom_point(aes(color = hl3), size = 10)+ theme(text = element_text(size = 30), legend.position="none")

p1 <- bridge(EBICgraph, communities = big5groups)[[1]]
p2 <- bridge(prune_omega, communities = big5groups)[[1]]
p3 <- bridge(BGGMfit$pcor_mat_zero, communities = big5groups)[[1]]

## Centrality - Bridge
bridge_plot <- function(p) {
  data.frame(
    Node = colnames(bfi[,1:25]),
    Bridge = as.numeric(p)
  ) |> 
    ggplot(aes(y = Node, x = Bridge)) +
    geom_path(group = 1) +
    geom_point(group = 1, size = 10) +
    theme_bw()+
    theme(text = element_text(size = 30), legend.position="none")
}

bridge_plot(p1)
bridge_plot(p2)
bridge_plot(p3)