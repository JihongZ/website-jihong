cor0 <- function(x,y,...){
  if (sum(!is.na(x)) < 2 || sum(!is.na(y)) < 2 || sd(x,na.rm=TRUE)==0 | sd(y,na.rm=TRUE) == 0){
    return(0)
  } else {
    return(cor(x,y,...))
  }
}

bias <- function(x,y) mean(abs(x-y),na.rm=TRUE)


### Inner function:
comparison_metrics <- function(real, est, name = "full"){
  
  # Output list:
  out <- list()
  
  # True positives:
  TruePos <- sum(est != 0 &  real != 0)
  
  # False pos:
  FalsePos <- sum(est != 0 & real == 0)
  
  # True Neg:
  TrueNeg <- sum(est == 0 & real == 0)
  
  # False Neg:
  FalseNeg <- sum(est == 0 & real != 0)
  
  # Sensitivity:
  out$sensitivity <- TruePos / (TruePos + FalseNeg)
  
  # Sensitivity top 50%:
  top50 <- which(abs(real) > median(abs(real[real!=0])))
  out[["sensitivity_top50"]] <- sum(est[top50]!=0 & real[top50] != 0) / sum(real[top50] != 0)
  
  # Sensitivity top 25%:
  top25 <- which(abs(real) > quantile(abs(real[real!=0]), 0.75))
  out[["sensitivity_top25"]] <- sum(est[top25]!=0 & real[top25] != 0) / sum(real[top25] != 0)
  
  # Sensitivity top 10%:
  top10 <- which(abs(real) > quantile(abs(real[real!=0]), 0.90))
  out[["sensitivity_top10"]] <- sum(est[top10]!=0 & real[top10] != 0) / sum(real[top10] != 0)
  
  # Specificity:
  out$specificity <- TrueNeg / (TrueNeg + FalsePos)
  
  # Precision (1 - FDR):
  out$precision <- TruePos / (FalsePos + TruePos)
  
  # precision top 50% (of estimated edges):
  top50 <- which(abs(est) > median(abs(est[est!=0])))
  out[["precision_top50"]] <- sum(est[top50]!=0 & real[top50] != 0) / sum(est[top50] != 0)
  
  # precision top 25%:
  top25 <- which(abs(est) > quantile(abs(est[est!=0]), 0.75))
  out[["precision_top25"]] <- sum(est[top25]!=0 & real[top25] != 0) / sum(est[top25] != 0)
  
  # precision top 10%:
  top10 <- which(abs(est) > quantile(abs(est[est!=0]), 0.90))
  out[["precision_top10"]] <- sum(est[top10]!=0 & real[top10] != 0) / sum(est[top10] != 0)
  
  # Signed sensitivity:
  TruePos_signed <- sum(est != 0 &  real != 0 & sign(est) == sign(real))
  out$sensitivity_signed <- TruePos_signed / (TruePos + FalseNeg)
  
  # Correlation:
  out$correlation <- cor0(est,real)
  
  # Correlation between absolute edges:
  out$abs_cor <- cor0(abs(est),abs(real))
  
  #
  out$bias <- bias(est,real)
  
  ## Some measures for true edges only:
  if (TruePos > 0){
    
    trueEdges <- est != 0 & real != 0
    
    out$bias_true_edges <- bias(est[trueEdges],real[trueEdges])
    out$abs_cor_true_edges <- cor0(abs(est[trueEdges]),abs(real[trueEdges]))
  } else {
    out$bias_true_edges <- NA
    out$abs_cor_true_edges <- NA
  }
  
  out$truePos <- TruePos
  out$falsePos <- FalsePos
  out$trueNeg <- TrueNeg
  out$falseNeg <- FalseNeg
  
  # Mean absolute weight false positives:
  false_edges <- (est != 0 &  real == 0) | (est != 0 & real != 0 & sign(est) != sign(real) )
  out$mean_false_edge_weight <- mean(abs(est[false_edges]))
  out$SD_false_edge_weight <- sd(abs(est[false_edges]))
  
  # Fading:
  out$maxfade_false_edge <- max(abs(est[false_edges])) / max(abs(est))
  out$meanfade_false_edge <- mean(abs(est[false_edges])) / max(abs(est))
  
  
  # Set naname
  if (name != ""){
    names(out) <- paste0(names(out),"_",name)  
  }
  out
}


# Replciation metrics:
replication_metrics <- function(est, rep, name = "full"){
  
  # Output list:
  out <- list()
  
  # Proportion of replicated edges:
  # Correlation between edge wegights:
  out$correlation_replication <- cor0(est, rep)
  
  # Percentage of edges in network 1 replicated in network 2:
  out$replicated_edges <- sum(est!=0 & rep!=0)/sum(est!=0)
  
  # top 50% replication
  est_top50 <- which(est > median(abs(est[est!=0])))
  rep_edges <- which(rep!=0)
  out$replicated_top50 <- sum(est_top50 %in% rep_edges)/length(est_top50)
  
  # top 25% replication
  est_top25 <- which(est > quantile(abs(est[est!=0]), 0.75))
  out$replicated_top25 <- sum(est_top25 %in% rep_edges)/length(est_top25)
  
  # top 10% replication
  est_top10 <- which(est > quantile(abs(est[est!=0]), 0.90))
  out$replicated_top10 <- sum(est_top10 %in% rep_edges)/length(est_top10)
  
  # Percentage of zeroes in network 1 replicated in network 2:
  out$replicated_zeroes <- sum(est==0 & rep==0)/sum(est==0)

  # Set name
  if (name != ""){
    names(out) <- paste0(names(out),"_",name)  
  }
  out
}


compareNetworks <- function(true,est, replication, directed = FALSE, groups){
  library("qgraph")
  if (!is.matrix(true) | !is.matrix(est)) stop("Input must be weights matrix")
  
  if (directed){
    realvec <- c(true)
    estvec <- c(est)
    if (!missing(replication)){
      repvec <- c(replication)
    }
  } else {
    realvec <- true[upper.tri(true,diag=FALSE)]
    estvec <- est[upper.tri(est,diag=FALSE)]
    if (!missing(replication)){
      repvec <- replication[upper.tri(replication,diag=FALSE)]
    }
  }        
  
  
  # Call inner function for full sample:
  out <- comparison_metrics(realvec, estvec, "")
  
  # Replication:
  if (!missing(replication)){
    out <- c(out, replication_metrics(est=estvec, rep=repvec, ""))
  }
  
  # Bridge edges:
  if (!missing(groups)){
    groupMat <- outer(groups,groups,"!=")
    
    
    if (directed){
      realvec <- c(true[groupMat])
      estvec <- c(est[groupMat])
      if (!missing(replication)){
        repvec <- c(replication[groupMat])
      }
    } else {
      realvec <- true[groupMat&upper.tri(true,diag=FALSE)]
      estvec <- est[groupMat&upper.tri(est,diag=FALSE)]
      if (!missing(replication)){
        repvec <- replication[groupMat & upper.tri(replication,diag=FALSE)]
      }
    }        
    
    out_bridge <- comparison_metrics(realvec, estvec, "bridge")
    out <- c(out,out_bridge)
    
    if (!missing(replication)){
      out <- c(out, replication_metrics(est=estvec, rep=repvec, "bridge"))
    }
  }
  
  # Centrality comparison:
  cent_true <- centrality(true)
  cent_est <- centrality(est)
  
  # Pearson correlations:
  out[['strength_correlation']] <- cor0(cent_true$OutDegree, cent_est$OutDegree)
  out[['closeness_correlation']] <- cor0(cent_true$Closeness, cent_est$Closeness)
  out[['betweenness_correlation']] <- cor0(cent_true$Betweenness, cent_est$Betweenness)
  
  # Rank order:
  out[['strength_correlation_kendall']] <- cor0(cent_true$OutDegree, cent_est$OutDegree, method = "kendall")
  out[['closeness_correlation_kendall']] <- cor0(cent_true$Closeness, cent_est$Closeness, method = "kendall")
  out[['betweenness_correlation_kendall']] <- cor0(cent_true$Betweenness, cent_est$Betweenness, method = "kendall")
  
  # Top 1:
  out[['strength_top1']] <- which.max(cent_true$OutDegree) == which.max(cent_est$OutDegree)
  out[['closeness_top1']] <- which.max(cent_true$Closeness) == which.max(cent_est$Closeness)
  out[['betweenness_top1']] <- which.max(cent_true$Betweenness) == which.max(cent_est$Betweenness)
  
  # Top 3:
  out[['strength_top3']] <- mean(order(cent_est$OutDegree, decreasing = TRUE)[1:3] %in% order(cent_true$OutDegree, decreasing = TRUE)[1:3])
  out[['closeness_top3']] <-  mean(order(cent_est$Closeness, decreasing = TRUE)[1:3] %in% order(cent_true$Closeness, decreasing = TRUE)[1:3])
  out[['betweenness_top3']] <-  mean(order(cent_est$Betweenness, decreasing = TRUE)[1:3] %in% order(cent_true$Betweenness, decreasing = TRUE)[1:3])
  
  # Top 5:
  out[['strength_top5']] <- mean(order(cent_est$OutDegree, decreasing = TRUE)[1:5] %in% order(cent_true$OutDegree, decreasing = TRUE)[1:5])
  out[['closeness_top5']] <-  mean(order(cent_est$Closeness, decreasing = TRUE)[1:5] %in% order(cent_true$Closeness, decreasing = TRUE)[1:5])
  out[['betweenness_top5']] <-  mean(order(cent_est$Betweenness, decreasing = TRUE)[1:5] %in% order(cent_true$Betweenness, decreasing = TRUE)[1:5])
  
  if (!missing(replication)){
    cent_rep <- centrality(replication)
    
    # Pearson correlations:
    out[['strength_correlation_replication']] <- cor0(cent_rep$OutDegree, cent_est$OutDegree)
    out[['closeness_correlation_replication']] <- cor0(cent_rep$Closeness, cent_est$Closeness)
    out[['betweenness_correlation_replication']] <- cor0(cent_rep$Betweenness, cent_est$Betweenness)
    
    # Rank order:
    out[['strength_correlation_kendall_replication']] <- cor0(cent_rep$OutDegree, cent_est$OutDegree, method = "kendall")
    out[['closeness_correlation_kendall_replication']] <- cor0(cent_rep$Closeness, cent_est$Closeness, method = "kendall")
    out[['betweenness_correlation_kendall_replication']] <- cor0(cent_rep$Betweenness, cent_est$Betweenness, method = "kendall")
    
    # Top 1:
    out[['strength_top1_replication']] <- which.max(cent_rep$OutDegree) == which.max(cent_est$OutDegree)
    out[['closeness_top1_replication']] <- which.max(cent_rep$Closeness) == which.max(cent_est$Closeness)
    out[['betweenness_top1_replication']] <- which.max(cent_rep$Betweenness) == which.max(cent_est$Betweenness)
  }
  
  return(out)
}