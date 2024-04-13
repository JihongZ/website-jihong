data {
  
  // data specifications  =============================================================
  int<lower=0> nObs;                            // number of observations
  int<lower=0> nItems;                          // number of items
  int<lower=0> maxCategory;       // number of categories for each item
  
  // input data  =============================================================
  array[nItems, nObs] int<lower=1, upper=5>  Y; // item responses in an array

  // loading specifications  =============================================================
  int<lower=1> nFactors;                                       // number of loadings in the model
  array[nItems, nFactors] int<lower=0, upper=1> Qmatrix;
  
  // prior specifications =============================================================
  array[nItems] vector[maxCategory-1] meanThr;                // prior mean vector for intercept parameters
  array[nItems] matrix[maxCategory-1, maxCategory-1] covThr;  // prior covariance matrix for intercept parameters
  
  vector[nItems] meanLambda;         // prior mean vector for discrimination parameters
  matrix[nItems, nItems] covLambda;  // prior covariance matrix for discrimination parameters
  
  vector[nFactors] meanTheta;
}

transformed data{
  int<lower=0> nLoadings = 0;                                      // number of loadings in model
  
  for (factor in 1:nFactors){
    nLoadings = nLoadings + sum(Qmatrix[1:nItems, factor]);
  }

  array[nLoadings, 2] int loadingLocation;                     // the row/column positions of each loading
  int loadingNum=1;
  
  for (item in 1:nItems){
    for (factor in 1:nFactors){
      if (Qmatrix[item, factor] == 1){
        loadingLocation[loadingNum, 1] = item;
        loadingLocation[loadingNum, 2] = factor;
        loadingNum = loadingNum + 1;
      }
    }
  }


}

parameters {
  array[nObs] vector[nFactors] theta;                // the latent variables (one for each person)
  array[nItems] ordered[maxCategory-1] thr; // the item thresholds (one for each item category minus one)
  vector[nLoadings] lambda;             // the factor loadings/item discriminations (one for each item)
  cholesky_factor_corr[nFactors] thetaCorrL;
}

transformed parameters{
  matrix[nItems, nFactors] lambdaMatrix = rep_matrix(0.0, nItems, nFactors);
  matrix[nObs, nFactors] thetaMatrix;
  
  // build matrix for lambdas to multiply theta matrix
  for (loading in 1:nLoadings){
    lambdaMatrix[loadingLocation[loading,1], loadingLocation[loading,2]] = lambda[loading];
  }
  
  for (factor in 1:nFactors){
    thetaMatrix[,factor] = to_vector(theta[,factor]);
  }
  
}

model {
  
  lambda ~ multi_normal(meanLambda, covLambda); 
  thetaCorrL ~ lkj_corr_cholesky(1.0);
  theta ~ multi_normal_cholesky(meanTheta, thetaCorrL);    
  
  
  for (item in 1:nItems){
    thr[item] ~ multi_normal(meanThr[item], covThr[item]);            
    Y[item] ~ ordered_logistic(thetaMatrix*lambdaMatrix[item,1:nFactors]', thr[item]);
  }
  
  
}

generated quantities{ 
  array[nItems] vector[maxCategory-1] mu;
  corr_matrix[nFactors] thetaCorr;
   
  for (item in 1:nItems){
    mu[item] = -1*thr[item];
  }
  
  
  thetaCorr = multiply_lower_tri_self_transpose(thetaCorrL);
  
}
