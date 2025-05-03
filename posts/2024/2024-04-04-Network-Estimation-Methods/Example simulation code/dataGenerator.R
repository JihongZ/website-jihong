dataGenerator <- function(
  trueNet,
  sampleSize,
  data = c("normal","skewed","uniform ordered","skewed ordered"),
  nLevels = 4,
  missing = 0
){
  data <- match.arg(data)
  nNode <- ncol(trueNet)
  
  library("bootnet")
  
  if (data == "normal" || data == "skewed"){
    # Generator function:
    gen <- ggmGenerator()
    
    # Generate data:
    Data <- gen(sampleSize,trueNet)
    
    # Generate replication data:
    Data2 <- gen(sampleSize,trueNet)
    
    if (data == "skewed"){
      for (i in 1:ncol(trueNet)){
        Data[,i] <- exp(Data[,i])
        Data2[,i] <- exp(Data2[,i])
      }
    }
  
  } else {
    
    # Skew factor:
    skewFactor <- switch(data,
                         "uniform ordered" = 1,
                         "skewed ordered" = 2,
                         "very skewed ordered" = 4)
    
    # Generator function:
    gen <- ggmGenerator(ordinal = TRUE, nLevels = nLevels)
    
    # Make thresholds:
    thresholds <- lapply(seq_len(nNode),function(x)qnorm(seq(0,1,length=nLevels + 1)[-c(1,nLevels+1)]^(1/skewFactor)))
    
    # Generate data:
    Data <- gen(sampleSize, list(
      graph = trueNet,
      thresholds = thresholds
    ))
    
    # Generate replication data:
    Data2 <- gen(sampleSize, list(
      graph = trueNet,
      thresholds = thresholds
    ))
    
  }
  
  # Add missings:
  if (missing > 0){
    for (i in 1:ncol(Data)){
      Data[runif(sampleSize) < missing,i] <- NA
      Data2[runif(sampleSize) < missing,i] <- NA
    }
  }
  
  return(list(
    data1 = Data,
    data2 = Data2
  ))
}